package edu.gmu.css.agents;

import com.sun.javafx.geom.Vec2d;
import com.uber.h3core.H3Core;

import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.TileWeal;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.service.H3IdStrategy;
import edu.gmu.css.data.DataTrend;

import edu.gmu.css.worldOrder.WorldOrder;
import one.util.streamex.DoubleStreamEx;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import java.io.IOException;
import java.io.Serializable;
import java.util.*;


@NodeEntity
public class Tile extends Entity implements Serializable, Steppable {
    /**
     * Tiles are implemented as hexagonal (and 12 pentagonal) territorial units defined by Uber H3 Hierarchical Discrete
     * Global Grid object boundaries. Only land tiles are implemented (though, undefined and unmanaged tiles along the
     * coastlines get created as a side-effect.
     */
    @Id @GeneratedValue (strategy = H3IdStrategy.class)
    private Long h3Id;
    @Property
    @Index(unique = true)
    private String address;
    @Property
    private double urbanization;
    @Property
    private int population;
    @Transient
    private int products;
    @Transient
    private int naturalResources;
    @Transient
    private double wealth;
    @Transient
    private double wealthLastStep;
    @Transient
    private double productivity = 1.01;
    @Transient
    private EconomicPolicy economicPolicy = new EconomicPolicy(0.5, 0.5);
    @Transient
    private double taxRate = 0.00;
    @Transient
    private TileWeal weal;
    @Transient
    private DataTrend memory = new DataTrend(52 * 7); // Seven year economic history
    @Transient
    private DataTrend growth = new DataTrend(52 * 14); // Fourteen year population history
    @Property
    private List<Long>neighborIds = new ArrayList<>();
    @Relationship(type="ABUTS", direction = Relationship.UNDIRECTED)
    private List<Tile> neighbors = new ArrayList<>();
    @Relationship(type="INCLUDES", direction = "INCOMING")
    private Inclusion linkedTerritory;


    public Tile() {
    }

    public Tile(Long id) {
        this.h3Id = id;
        learnNeighborhood();
        weal = new TileWeal(this);
    }

    public void step(SimState simState) {
        memory.add(this.wealth);     // Wealth gets recorded before any increase from current production
        growth.add(this.population);
        updateProductivity();
        produce();
        growPopulation();
        weal.step(simState);
    }


    // There are some private functions to a tile that happen inside the tile. Right now, these are
    // * growPopulation()
    // * produce()

    // Population growth is a linear function of regional wealth (averaged over themTimes) and the proportion of the
    // population that is urban. It varies between 0.098 for urban population with negative history of average wealth--
    // increasing toward 1.0 as proportion of urban population decreases--to 1.02 for rural populations with positive
    // wealth history. These numbers hacked out crudely from @article {Cohen1995, author={Cohen, JE}, title={
    // Population growth and earth's human carrying capacity}, volume={269}, number={5222}, pages={341--346}, year={1995},
    // publisher = {American Association for the Advancement of Science}, URL={http://science.sciencemag.org/content/269/5222/341},
    // journal = {Science} } and a linear model: urbanPopulation [0.0, 0.3, 0.8] x growth [0.02, 0.01, 0.003], lm(growth ~ uP)
    private void growPopulation() {
        double rate;
        double trend = DoubleStreamEx.of(memory).pairMap((a, b) -> b - a).sum();
        if (trend < 0) {
            rate = 1.0 - (urbanization * -0.0205);
            rate = 1.0 - ((1.0 - rate) / 52);
        } else {
            rate = 1.02 + (urbanization * -0.0205);
            rate = ((rate - 1.0) / 52) + 1.0;
        }
       this.population = (int) (this.population * rate);
    }

    private void produce() {
        // Crude Cobb-Douglass production function using urban/rural percentages as beta/alpha and population/wealth for
        // capital and labor. The constant is ~ 1.0
        double agLabor = (1 - urbanization) * 0.8;
        double kpLabor = 1 - agLabor;
        double production = (productivity * (
                Math.pow(population, agLabor) * Math.pow(wealth, kpLabor)));
        // the Economic policy determines how much money becomes wealth and how much gets consumed as product
        this.products += this.products + ((int) (production * economicPolicy.getCapital()));
        this.wealth += this.wealth + (production * economicPolicy.getLabor());
    }

    // External (State) agents demand taxes and draft soldiers.
    public double payTaxes() {
        double weeklyTaxRate = taxRate / WorldOrder.annum.getWeeksThisYear();
        double amount = weeklyTaxRate * this.wealth;
        this.wealth =- amount;
        return amount;
    }

    public int recruitSoldiers(double portion) {
        int numSoldiers = (int) portion * this.population;
        this.population =- numSoldiers;
        return numSoldiers;
    }

    public String getAddress() {
        return address;
    }

    public Long getH3Id() {return h3Id; }

    public List<Tile> getNeighbors() {
        return neighbors;
    }

    public void addNeighbor(Tile n) {
        this.neighbors.add(n);
    }

    private void learnNeighborhood() {
        try {
            H3Core h3 = H3Core.newInstance();
            this.neighborIds = h3.kRing(h3Id, 1);
            this.neighborIds.remove(h3Id);
            // unrelated, but I'm taking advantage of having already initiated an H3 instance
            this.address = h3.h3ToString(h3Id);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public List<Long> getNeighborIds() {
        return this.neighborIds;
    }

    public int getPopulation() {
        return population;
    }

    public void setPopulation(int population) {
        this.population = population;
    }

    public int getProducts() {
        return products;
    }

    public void setProducts(int products) {
        this.products = products;
    }

    public double getWealth() {
        return wealth;
    }

    public void setWealth(double wealth) {
        this.wealth = wealth;
    }

    public int getNaturalResources() {
        return naturalResources;
    }

    public void setNaturalResources(int naturalResources) {
        this.naturalResources = naturalResources;
    }

    public Inclusion getLinkedTerritory() {
        return linkedTerritory;
    }

    public void setLinkedTerritory(Inclusion territories) {
        this.linkedTerritory = territories;
    }

    public double getUrbanization() {
        return urbanization;
    }

    public void setUrbanization(int uPop) {
        if (uPop != 0 && population != 0) {
            urbanization = (double)uPop / (double)population ;
        } else {
            urbanization = 0.0;
        }
    }

    public double getProductivity() {
        return productivity;
    }

    public void setProductivity(double productivity) {
        this.productivity = productivity;
    }

    private void updateProductivity() {
        double trend = productivity / (memory.average());
    }

    public double getTaxRate() {
        return taxRate;
    }

    public void setTaxRate(double taxRate) {
        this.taxRate = taxRate;
    }

    public Double guageSupport(Entity e) {
        return weal.considerSupport(e);
    }
}
