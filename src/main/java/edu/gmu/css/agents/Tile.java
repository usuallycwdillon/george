package edu.gmu.css.agents;

import com.uber.h3core.H3Core;
import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.data.World;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.service.H3IdStrategy;
import edu.gmu.css.data.DataTrend;

import edu.gmu.css.service.TileFactServiceImpl;
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
    @Transient
    private int year;
    @Transient
    private double urbanPopulation;
    @Transient
    private double population;
    @Transient
    private int products;
    @Transient
    private int naturalResources;
    @Transient
    private double wealth;
    @Transient
    private double productivity;
    @Transient
    private double grossTileProduction;
    @Transient
    private double builtUpArea;
    @Transient
    private final TileFactServiceImpl svc = new TileFactServiceImpl();
    @Transient // Seven year economic history using Joseph Kitchen (1923) Cycles and Trends in Economic Factors
    private final DataTrend memory = new DataTrend(365);
    @Transient // Fifteen year population history; half a generation according to Tremblay and Vézina (2000) New estimates of intergenerational time levels...
    private final DataTrend growth = new DataTrend(783);
    @Property
    private List<Long>neighborIds = new ArrayList<>();
    @Relationship(type="ABUTS", direction = Relationship.UNDIRECTED)
    private final List<Tile> neighbors = new ArrayList<>();
    @Relationship(type="INCLUDES", direction = "INCOMING")
    private Inclusion linkedTerritory;


    public Tile() {
    }

    public Tile(Long id) {
        this.h3Id = id;
        learnNeighborhood();
    }

    public void step(SimState simState) {
        // There are some private functions to a tile that happen inside the tile. Right now, these are
        // * growPopulation()
        // * produce()
        // Each function records its data for the tile
        WorldOrder worldOrder = (WorldOrder) simState;
        updateProductivity();
        growPopulation(worldOrder.weeksThisYear);
        produce(linkedTerritory.getTerritory().getPolity().getEconomicPolicy());
//        evenStep(worldOrder);
//        weal.step(simState);

    }

    private void growPopulation(int w) {
        // Population growth is a linear function of regional wealth (averaged over length of `memory`) and the proportion of the
        // population that is urban. It varies between 0.09795 for urban population with negative history of average wealth--
        // increasing toward 1.0 as proportion of urban population decreases--to 1.0205 for rural populations with positive
        // wealth history. These numbers hacked out crudely from @article {Cohen1995, author={Cohen, JE}, title={
        // Population growth and earth's human carrying capacity}, volume={269}, number={5222}, pages={341--346}, year={1995},
        // publisher = {American Association for the Advancement of Science}, URL={http://science.sciencemag.org/content/269/5222/341},
        // journal = {Science} } and a linear model: urbanization [0.0, 0.3, 0.8] x growth [0.02, 0.01, 0.003], lm(growth ~ urbanization)
        //
        double urbanization = this.urbanPopulation / this.population;
        double weeklyFactor = (Math.pow(1.0205, (1.0 / w)) - 1.0) * urbanization;
        if (0.0 < urbanization && urbanization <= 1.0) {
            urbanization = Math.pow(urbanization, 0.85);
        }
        if (growth.size() > 26) {
            double trend = DoubleStreamEx.of(memory).pairMap((a, b) -> b - a).sum();
            if (trend < 0) {
                this.population -= weeklyFactor * this.population;
                this.urbanPopulation -= weeklyFactor * this.urbanPopulation;
                // TODO: Make urbanization increase by powerlaw
            } else {
                this.population += weeklyFactor * this.population;
                this.urbanPopulation += urbanization * this.population;
            }
        }
        growth.add(this.population);
    }

    private void produce(EconomicPolicy economicPolicy) {
        // Crude Cobb-Douglass production function using urban/rural percentages to influence and capital and
        // labor elasticity based on estimates of employed population and estimated wealth available for production.
        EconomicPolicy p = economicPolicy;
        double ruralPop = this.population - this.urbanPopulation;
        double urbanization = this.population > 0.0 ? this.urbanPopulation / this.population : 0.0;
        double labor = (this.urbanPopulation * 0.75) + (ruralPop * 0.65);
        double laborElasticity = 0.6 + (urbanization * 0.1);
        double kapitalElasticity = 1 - laborElasticity;
        double production = Math.exp( (Math.log(this.wealth) * kapitalElasticity) + (Math.log(labor) * laborElasticity) );
        // Using Farris et al's $3/day min threshold as a minimum required for pop to survive and West's estimate that
        // urban dwellers require 11x the production of rural dwellers, urbanPop * 210 + pop * 21 is not taxable.
        // The Economic policy determines how much money becomes wealth and how much can be consumed as product.
        // Before any deductions, the whole of this week's gtp gets added to the memory. Remember money is in 1,000's.
        this.setGrossTileProduction(production);
        double survivalThreshold = ((this.urbanPopulation * 0.210) + (this.population * 0.021));
        double savingsThreshold =  this.population * (75.0 / 52);
        double minimumProduction = survivalThreshold + ((production - survivalThreshold) * p.getTaxRate());
        if (production - minimumProduction > savingsThreshold) {
            double excess = production - savingsThreshold;
            this.wealth += 1.07 * excess;
//            if (WorldOrder.DEBUG) {
//                debugProduction(excess);
//            }
            // TODO: Add rules for increasing built environment and urbanization
        } else if (production > minimumProduction) {
            double margin = 1.03 * (production - minimumProduction);
            this.wealth += margin;
//            if (WorldOrder.DEBUG) {
//                debugProduction(margin);
//            }
            // TODO: Add rules for increasing built environment and urbanization here too.
        }
        this.memory.add(production);
    }

    public void debugProduction(double newWealth) {
        if (this.address.equals("840d99bffffffff")) {
            System.out.println(this.address + " added " + newWealth + " and grew wealth by " + newWealth / this.wealth);
        }
    }

    // External (State) agents takes taxes
    public Double payTaxes(double taxRate) {
        Double taxes = 0.0;
        if (population > 0.0) {
            double latest = Math.max(memory.mostRecent(), 0.0);
            double survivalThreshold = ((this.urbanPopulation * 0.210) + (this.population * 0.021));
            taxes = Math.max((latest - survivalThreshold) * taxRate, 0.0);
            wealth -= taxes;
            if (taxes.isNaN()) {
                System.out.println("This one");
            }
        }
        return taxes;
    }

    public double payTaxes(double taxRate, long s) {
        double increase =  Math.max(memory.latestDiff(), 0.0);
        double taxes = increase * taxRate;
        wealth -= taxes;
        if (this.address.equals("840d99bffffffff") && s > 26L) {
            System.out.println("This one");
        }
        return taxes;
    }


    public double recruitSoldiers(double portion) {
        double numSoldiers = (portion * this.population);
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

    public double getPopulation() {
        return population;
    }

    public void setPopulation(double population) {
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

    public double getGrossTileProduction() {
        return grossTileProduction;
    }

    public double getGrossTileProductionLastYear() {
        return memory.pastYearTotal();
    }

    public void setGrossTileProduction(double grossTileProduction) {
        this.grossTileProduction = grossTileProduction;
    }

    public double getBuiltUpArea() {
        return builtUpArea;
    }

    public void setBuiltUpArea(double builtUpArea) {
        this.builtUpArea = builtUpArea;
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

    public double getUrbanPopulation() {
        return urbanPopulation;
    }

    public void setUrbanPopulation(double uPop) {
        this.urbanPopulation = uPop;
    }

    public DataTrend getMemory() {
        return memory;
    }

    public DataTrend getGrowth() {
        return growth;
    }

    public int getTerritoryYear() {
        return getLinkedTerritory().getTerritoryYear();
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

//    public double getTaxRate() {
//        return taxRate;
//    }
//
//    public void setTaxRate(double taxRate) {
//        this.taxRate = taxRate;
//    }

//    public Double guageSupport(Entity e) {
//        return weal.considerSupport(e);
//    }

    private boolean evenStep(WorldOrder wo) {
        return wo.getStepNumber() % 2 == 1;
    }

    public boolean loadFacts(Map<String, Object> data) {
        Long a = ((Number) data.get("a")).longValue();
        Double p = ((Number) data.get("p")).doubleValue();
        Double u = ((Number) data.get("u")).doubleValue();
        Double w = ((Number) data.get("w")).doubleValue();
        Double g = ((Number) data.get("g")).doubleValue();
        Double b = ((Number) data.get("b")).doubleValue();
        if (Objects.equals(a, this.h3Id)) {
            this.setPopulation(p);
            this.setUrbanPopulation(u);
            this.setWealth(w);
            this.setGrossTileProduction(g);
            this.setBuiltUpArea(b);
            memory.add(g);
            growth.add(p);
            return true;
        } else {
            return false;
        }
    }



        // weal
//        this.weal = new TileWeal(this);

        // DataTrend elements 0 and 1

}
