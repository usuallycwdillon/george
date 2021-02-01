package edu.gmu.css.agents;

import com.uber.h3core.H3Core;
import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.data.World;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.service.H3IdStrategy;
import edu.gmu.css.data.DataTrend;

import edu.gmu.css.service.TileFactServiceImpl;
import edu.gmu.css.service.TileServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import one.util.streamex.DoubleStreamEx;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import javax.management.remote.rmi._RMIConnection_Stub;
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
//    @Transient
//    private double productivity;
    @Transient
    private double grossTileProduction;
    @Transient
    private double builtUpArea;
    @Transient
    private double taxPayment;
    @Transient // Seven year economic history using Joseph Kitchen (1923) Cycles and Trends in Economic Factors
    private final DataTrend memory = new DataTrend(365);  // memory of wealth, not gtp
    @Transient // maintain one year of gtp to measure annual gtp
    private final DataTrend gtp = new DataTrend(53);
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
        growPopulation(worldOrder);
        produce(worldOrder);
//        evenStep(worldOrder);
//        weal.step(simState);
//        updateProductivity();

    }

    private void growPopulation(WorldOrder wo) {
        // Population growth is a linear function of regional wealth (averaged over length of `memory`) and the proportion of the
        // population that is urban. It varies between 0.09795 for urban population with negative history of average wealth--
        // increasing toward 1.0 as proportion of urban population decreases--to 1.0205 for rural populations with positive
        // wealth history. These numbers hacked out crudely from @article {Cohen1995, author={Cohen, JE}, title={
        // Population growth and earth's human carrying capacity}, volume={269}, number={5222}, pages={341--346}, year={1995},
        // publisher = {American Association for the Advancement of Science}, URL={http://science.sciencemag.org/content/269/5222/341},
        // journal = {Science} } and a linear model: urbanization [0.0, 0.3, 0.8] x growth [0.02, 0.01, 0.003], lm(growth ~ urbanization)
        //
        WorldOrder worldOrder = wo;
        int w = worldOrder.weeksThisYear;
        double x = 1.0 / w;
        if (this.population == 0.0) return;
        double urbanization = this.urbanPopulation / this.population;
        double weeklyFactor = (Math.pow(1.0205, x) - 1.0) * urbanization;
        if (0.0 < urbanization && urbanization <= 1.0) {
            urbanization = urbanization * weeklyFactor;
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

    private void produce(WorldOrder wo) {
        // Crude Cobb-Douglass production function using urban/rural percentages to influence and capital and
        // labor elasticity based on estimates of employed population and estimated wealth available for production.
        WorldOrder worldOrder = wo;
        if (this.population <= 0.0) {
            this.population = 0.0;
            if (this.wealth <= 0.0) {
                this.wealth = 0.0;
            }
            return;
        }
        if (this.population > 0.0 && this.wealth == 0.0) {
            migrate();
            return;
        }
        EconomicPolicy p = linkedTerritory.getTerritory().getPolity().getEconomicPolicy();
        double ruralPop = this.population - this.urbanPopulation;
        double urbanization = this.population > 0.0 ? this.urbanPopulation / this.population : 0.0;
        double labor = (this.urbanPopulation * 0.75) + (ruralPop * 0.65);
        double laborElasticity = 0.6 + (urbanization * 0.1);
        double kapitalElasticity = 1 - laborElasticity;
        double production = Math.exp( (Math.log(this.wealth) * kapitalElasticity) + (Math.log(labor) * laborElasticity) );
        this.setGrossTileProduction(production);

        // Using Farris et al's $3/day min threshold as a minimum required for pop to survive and West's estimate that
        // urban dwellers require 11x the production of rural dwellers, urbanPop * 210 + pop * 21 is not taxable.
        // The Economic policy determines how much money becomes wealth and how much can be consumed as product.
        // Before any deductions, the whole of this week's gtp gets added to the memory. Remember money is in 1,000's.
        double survivalThreshold = this.population * 0.021;
        double savingsThreshold =  ((this.urbanPopulation * 0.280) + (this.population * 0.028));
        double sufficient = Math.max((production - survivalThreshold), 0.0);
        double excess = Math.max((production - savingsThreshold), 0.0);
        double sxRatio = excess > 0.0 ? sufficient / excess : sufficient / production;
        double wealthNow = this.wealth;

        double margin = 0.0;
        double x = 1.0/52.0;
        if (excess > 0.0) {
            margin = Math.min( (( Math.pow(1.15, x) ) - 1.0), sxRatio - 1.0 );
            setWealth(wealthNow + (margin * excess) );
            this.taxPayment = production * p.getTaxRate();
            // TODO: Add rules for increasing built environment and urbanization
        } else if (sufficient > 0.0) {
            margin = ( Math.pow(1.07, x) ) - 1.0;
            setWealth(wealthNow + (margin * excess) );
            this.taxPayment = sufficient * p.getTaxRate();
            // TODO: Add rules for increasing built environment and urbanization here too.
        } else {

        }
//        System.out.println(address + " has production: " + production + ", survival: " + survivalThreshold +
//                ", savingsAbove: " + savingsThreshold + ", with s-x ratio: " + sxRatio +
//                ". \nWealth changed from " + wealthNow + " to " + this.wealth + " (or " +
//                (this.wealth - wealthNow) +  " after tax of " + this.taxPayment + ")");

        if(this.taxPayment == 0.0 && this.population > 50.0) {
            System.out.println("\n" + this.address + " has a pop but no $$\n");
        }
    }


    // External (State) agents takes taxes
    public Double payTaxes(double taxRate) {
        double taxBill = this.grossTileProduction * taxRate;
        if (this.taxPayment >= taxBill) {
            taxPayment -= taxBill;
        } else {
            double loss = taxBill - this.taxPayment;
            double payment = Math.min(loss, this.wealth);
            this.wealth -= payment;
            this.taxPayment = 0.0;
            taxBill = payment;
        }
        return taxBill;
    }

    public double supplySoldiers(double ratio) {
        if (this.population > 250.0) {
            double numSoldiers = (ratio * this.population);
            this.population -= numSoldiers;
            return numSoldiers;
        } else {
            return 0.0;
        }
    }

    public void migrate() {
        double capacity = this.getGrossTileProduction() / 0.021;
        double migrants = Math.min((this.population - capacity), 50.0);
        getNeighbors();
        Tile richest = neighbors.get(0);
        for (Tile n : neighbors) {
            double gtp = n.grossTileProduction;
            if (gtp > richest.getGrossTileProduction()) richest = n;
        }
        richest.setPopulation(richest.getPopulation() + migrants);
        this.population -= migrants;
    }

    public void takeInvestment(double d) {
        double investment = this.population * d;
        if (this.builtUpArea > 0.0) {
            double rate = builtUpArea / wealth;
            double construction = rate * investment;
            this.builtUpArea += construction;
        }
        this.wealth += investment;
    }

    public String getAddress() {
        return address;
    }

    public Long getH3Id() {return h3Id; }

    public List<Tile> getNeighbors() {
        if(neighbors==null || neighbors.size()==0) {
            (new TileServiceImpl().findNeighbors(this)).forEach(neighbors::add);
        }
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
        memory.add(wealth);
    }

    public double getGrossTileProduction() {
        return this.grossTileProduction;
    }

    public double getGrossTileProductionLastYear() {
        double annualGtp = gtp.pastYearTotal();
        this.gtp.clear();
        return annualGtp;
    }

    public void setGrossTileProduction(double grossTileProduction) {
        this.grossTileProduction = grossTileProduction;
        gtp.add(grossTileProduction);

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
            growth.add(p);
            getNeighbors();
            return true;
        } else {
            return false;
        }
    }

    private boolean loadFacts() {

        return false;
    }

    // weal
    //   this.weal = new TileWeal(this);
}
