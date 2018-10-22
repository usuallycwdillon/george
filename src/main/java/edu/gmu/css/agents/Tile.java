package edu.gmu.css.agents;

import com.uber.h3core.H3Core;
import com.uber.h3core.util.GeoCoord;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.service.H3IdStrategy;

import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.IOException;
import java.io.Serializable;
import java.util.*;


@NodeEntity
public class Tile extends Entity implements Steppable, Serializable {
    /**
     * Tiles are implemented as hexagonal (and 12 pentagonal) territorial units defined by Uber H3 Hierarchical Discrete
     * Global Grid object boundaries. Only land tiles are implemented.
     */
    @Id @GeneratedValue (strategy = H3IdStrategy.class)
    private Long id;
    private Long h3Id;
    @Index(unique = true)
    private String address;
//    private GeoCoord center;
    private double urbanization;
    private double productivity = 1.03;
    private double economicPolicy [] = {0.5, 0.5};
    private int population;
    private int products;
    private int naturalResources;
    private double wealth;
    private double wealthLastStep;

//    private History themTimes = new History(52 * 4); // Four year history

     // anonymous H3Core class instantiation


    @Relationship(type="ABUTS", direction = Relationship.UNDIRECTED)
    private Set<Tile> neighbors = new HashSet<>();

    private List<Long>neighborIds = new ArrayList<>();

    public Tile() {
    }

    public Tile(Long h3Id) {
        this.h3Id = h3Id;
        learnNeighborhood();
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
//        double trend = DoubleStreamEx.of(themTimes).pairMap((a,b) -> b - a).sum();
//        if (trend < 0) {
//            rate = 1.0 - (urbanization * -0.0205);
//            rate = 1.0 - ((1.0 - rate) / 52);
//        } else {
//            rate = 1.02 + (urbanization * -0.0205);
//            rate = ((rate - 1.0) / 52) + 1.0;
//        }
//       this.population = (int) (this.population * rate);
    }

    private void produce() {
        // Crude Cobb-Douglass production function using urban/rural percentages as beta/alpha and population/wealth for
        // capital and labor. The constant is ~ 1.0 +- normal random 10%
        double production = (productivity * (
                Math.pow(population, (1 - urbanization)) * Math.pow(wealth, urbanization)));
        this.products += this.products + ((int) (production * economicPolicy[0]));
        this.wealth += this.wealth + (production * economicPolicy[1]);
    }

    // External (State) agents demand taxes and draft soldiers.
    public double payTaxes(double rate) {
        double amount = rate * this.wealth;
        this.wealth =- amount;
        return amount;
    }

    public int recruitSoldiers(double portion) {
        int numSoldiers = (int) portion * this.population;
        this.population =- numSoldiers;
        return numSoldiers;
    }

    public void step(SimState simState) {
//        themTimes.add(this.wealth);     // Wealth gets recorded before any increase from current production
        produce();
        growPopulation();
    }

    public String getAddress() {
        return address;
    }

    public Long getH3Id() {return h3Id; }

//    public GeoCoord getCenter() {
//        return center;
//    }

    public List<GeoCoord> getBoundary() {
        List<GeoCoord> boundary = new ArrayList<>();
        try {
            H3Core h3 = H3Core.newInstance();
            boundary = h3.h3ToGeoBoundary(address);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return boundary;
    }

    public Set<Tile> getNeighbors() {
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

//    private void setCenter() {
//        try {
//            H3Core h3 = H3Core.newInstance();
//            this.center = h3.h3ToGeo(address);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }

//    @Override
//    public String toString() {
//        final StringBuilder sb = new StringBuilder("Tile{");
//        sb.append("id=").append(id);
//        sb.append("address=").append(address);
////        sb.append("center=").append(center.toString());
//        sb.append("urbanization=").append(urbanization);
//        sb.append("productivity=").append(productivity);
//        sb.append("economicPolicy=").append(economicPolicy);
//        sb.append("population=").append(population);
//        sb.append("products=").append(products);
//        sb.append("naturalResources=").append(naturalResources);
//        sb.append("wealth=").append(wealth);
//        sb.append("wealthLastStep=").append(wealthLastStep);
//        return sb.toString();
//    }
}
