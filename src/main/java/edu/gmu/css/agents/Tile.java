package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.entities.Grid;
import edu.gmu.css.entities.*;
import edu.gmu.css.service.AddressYearStrategy;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.service.GridServiceImpl;
import edu.gmu.css.service.TileServiceImpl;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.util.MTFWrapper;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.distribution.LogNormalDistribution;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.*;


@NodeEntity
public class Tile extends Entity implements Serializable, Steppable {
    /**
     * Tiles are implemented as hexagonal (and 12 pentagonal) territorial units defined by Uber H3 Hierarchical Discrete
     * Global Grid object boundaries. Only land tiles are implemented (though, undefined and unmanaged tiles along the
     * coastlines get created as a side-effect.
     */
    @Id @GeneratedValue (strategy = AddressYearStrategy.class)
    private String addressYear;
    @Property private String address;
    @Property private int year;
    @Property private Double urbanPop = 0.0;
    @Property private Double population = 0.0;
    @Property private Double wealth = 0.0;
    @Property private Double weeklyGTP = 0.0;
    @Property private Double builtArea = 0.0;
    @Property private Double initialPopRate = 0.0;
    @Transient private Double urbanGrowthRate = 0.0;
    @Transient private Double taxPayment = 0.0;
    @Transient // Seven year economic history using Joseph Kitchen (1923) Cycles and Trends in Economic Factors
    private final DataTrend memory = new DataTrend(365);  // memory of wealth, not gtp
    @Transient // maintain one year of gtp to measure annual gtp
    private final DataTrend weeklyTrendGTP = new DataTrend(53);
    @Transient // Fifteen year population history; half a generation according to Tremblay and Vézina (2000) New estimates of intergenerational time levels...
    private final DataTrend growth = new DataTrend(783);
    @Transient private Double pgRate = initialPopRate;
    @Transient private double satisfaction = 0.0;
    @Property private final List<Long>neighborIds = new ArrayList<>();
    @Relationship(type="ABUTS")
    private final List<Tile> neighbors = new ArrayList<>();
    @Relationship(type="INCLUDES", direction = Relationship.INCOMING)
    private Territory linkedTerritory;
    @Relationship(type="ON_R4GRID")
    private Grid grid;


    public Tile() {

    }

    public Tile(String addressYear) {
        this.addressYear = addressYear;
    }


    @Override
    public void step(SimState simState) {
        // There are some private functions to a tile that happen inside the tile. Right now, these are
        // * growPopulation()
        // * produce()
        // Each function records its data for the tile
        WorldOrder worldOrder = (WorldOrder) simState;
//        if(this.addressYear.equals("840d837ffffffff.1816")) {
//            System.out.println(this.toString());
//        }
        if(grid == null) this.grid = new GridServiceImpl().findGridForTile(this.address);
        if (this.population <= 0.0) {
            this.population = 0.0;
            if (this.wealth <= 0.0) {
                this.wealth = 0.0;
            }
            return;
        }
        if(this.pgRate == 0.0 || (this.pgRate == 0.0 && worldOrder.getStepNumber() < 2L)) {
            if(this.initialPopRate==0.0) {
                calculatePopGrowthRate(worldOrder);
            } else {
                this.pgRate = 1.0 + this.initialPopRate;
            }
        }
        if(this.population > 0.0) {
            growPopulation(worldOrder);
            produce(worldOrder);
            estimateTax();
            consumeSaveAssessSatisfaction();
        }
//        updateProductivity();

    }

    private void growPopulation(WorldOrder wo) {
        double ex = 1.0 / wo.getWeeksThisYear();
        double newPopulation = this.population * Math.pow(this.pgRate, ex);
        // The population only grows if there is enough wealth to support it.
        if (this.wealth > findMinimumWealth(newPopulation)) {
            this.population = newPopulation;
        }
        growth.add(this.population);
        if (this.urbanPop > 0.0) {
            double urbRate = ((wo.random.nextDouble() * 0.001) + 1.00269135) * pgRate;
            double estimate = this.urbanPop * Math.pow(urbRate, ex);
            this.urbanPop = Math.min(estimate, population);
            if(this.builtArea > 0.0) {
                build(urbRate, ex);
            }
        }
        if(this.population < 2.0) migrate(wo.random);
    }

    private void produce(WorldOrder wo) {
        // Crude Cobb-Douglass production function using urban/rural percentages to influence and capital and
        // labor elasticity based on estimates of employed population and estimated wealth available for production.
        WorldOrder worldOrder = wo;
//        if(worldOrder.DEBUG && this.addressYear.equals("8444eabffffffff.1816") && wo.getStepNumber() > 100) {
//            System.out.println("This is that tile that is rich but pays no taxes.");
//        }
        if (this.population < 2.0 && (
                this.wealth <= this.population * 0.021 || this.wealth.isNaN() || this.wealth.isInfinite())
        ) {
            migrate(worldOrder.random);
            return;
        }

        double ruralPop = this.population - this.urbanPop;
        double urbanization = this.population > 0.0 ? this.urbanPop / this.population : 0.0;
        double labor = (this.urbanPop * 0.75) + (ruralPop * 0.65);
        double laborElasticity = 0.6 + (urbanization * 0.1);
        double kapitalElasticity = 1 - laborElasticity;
        Double production = Math.exp((Math.log(this.wealth) * kapitalElasticity) + (Math.log(labor) * laborElasticity));
        if (production.isNaN() || production.isInfinite()) {
            System.out.println(addressYear + " has a problem in production");
        }
        if(production < this.population * 0.021 || production.isNaN() || production.isInfinite()) migrate(worldOrder.random);
        this.setWeeklyGrossTileProduction(production);
    }

    private double findMinimumWealth() {
        return findMinimumWealth(this.population);
    }

    private double findMinimumWealth(double pop) {
        double minWealth = 0.0;
        double minGTP = pop * 21;
        double urbanization = pop > 0.0 ? this.urbanPop / pop : 0.0;
        double ruralPop = pop - this.urbanPop;
        double ruralLabor = ruralPop * 0.65;
        double urbanLabor = this.urbanPop * 0.75;
        double alpha = 0.6 + (urbanization * 0.1);
        double beta = 1.0 - alpha;
        double totalLabor = ruralLabor + urbanLabor;
        double logGtp = Math.log(minGTP);
        double logLabor = Math.log(totalLabor);
        double logWealth = (logGtp - (alpha * logLabor)) / beta;
        minWealth = Math.exp(logWealth);
        return minWealth;
    }

    private void estimateTax() {
        // Using Farris et al's $3/day min threshold as a minimum required for pop to survive.
        // Remember money is in 1,000's.
        double rate = linkedTerritory.getPolity().getEconomicPolicy().getTaxRate();
        double taxBurden = this.weeklyGTP * rate;
        double survival = this.population * 0.021;
        double excess = Math.max(this.weeklyGTP - survival, 0.0);
        this.taxPayment = Math.min(excess, taxBurden);
        if(this.taxPayment == 0.0 && this.population > 50.0) {
            System.out.println("\n" + this.address + " has a pop but no $$\n");
        }
    }

    private void consumeSaveAssessSatisfaction() {
        // Consumption = weekly gtp - (savings + tax payment)
        // Using and West's estimate that urban dwellers require (on average) 11x the production of rural dwellers, the
        // savings threshold is urbanPop * 280 + pop * 28.
        double savingsThreshold = (this.population * 0.028) + (this.urbanPop * 0.28); // $4/person + x11 city multiplier
        double satisfactionThreshold = this.population * 1.34615; // $70k/year (by thousands, remember)
        this.satisfaction = Math.min(((this.weeklyGTP - savingsThreshold) / satisfactionThreshold), 1.0);
        double savingsRate = (this.satisfaction * (Math.pow(1.15, 0.01923077) - 1.0)); // maximum 15% savings/yr
        double savings = savingsRate * this.wealth; // savings rate could be less than zero
        setWealth(this.wealth + savings);
    }

    public void build(double uRate, double ex) {
        double bRate = 1.0 + (-0.0018078408 + ((uRate - 1.0) * 0.9194060347));
        double estimate = Math.pow(bRate, ex) * this.builtArea;
        this.builtArea = Math.min(estimate, this.grid.getKm2());
    }

    // External (State) agents takes taxes ...and some wealth (if there is any) if the tile cannot pay its full tax
    public Double payTaxes(double taxRate) {
        double taxBill = this.weeklyGTP * taxRate;
        if (this.taxPayment >= taxBill) {
            double extra = this.taxPayment - taxBill;
            this.wealth += extra;
            this.taxPayment = 0.0;
        } else {
            double balance = taxBill - this.taxPayment;
            double tileLoss = Math.min((this.wealth - this.findMinimumWealth()), balance);
            double payment = this.taxPayment + tileLoss;
            this.wealth -= tileLoss;
            this.taxPayment = 0.0;
            taxBill = Math.max(payment,0.0);
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

    public void migrate(MersenneTwisterFast r) {
        // a random number of people (1 - 10%) migrate and
        // take with them up to 25% of their 'share' of the wealth (can't take the built environment).
        if(this.population.isInfinite() || this.population.isNaN()) {
            this.population = 0.0;
        }
        double migrants = 0.0;
        double wealthMigration = 0.0;
        if(this.population < 2.0) {
            migrants = population;
            wealthMigration = this.wealth * 0.25;
        } else {
            MersenneTwisterFast random = r;
            double departPart = random.nextDouble() * 0.1;
            double wealthPart = random.nextDouble() * 0.25;
            double capacity = this.getWeeklyGrossTileProduction() / 0.021;
            migrants = (Math.max((this.population - capacity), 0.0)) * departPart;
            wealthMigration = (this.wealth / this.population) * wealthPart * migrants;
        }
        List<Tile> neighbors = getNeighbors();
        Tile richest = neighbors.get(0);
        for (Tile n : neighbors) {
            double gtp = n.weeklyGTP;
            if (gtp > richest.getWeeklyGrossTileProduction()) richest = n;
        }
        richest.setPopulation(richest.getPopulation() + migrants);
        richest.setWealth(richest.getWealth() + wealthMigration);
        this.population -= migrants;
        this.wealth -= wealthMigration;
    }

    public void takeInvestment(double d) {
        double investment = this.population * d;
        if (this.builtArea > 0.0) {
            double rate = builtArea / wealth;
            double construction = rate * investment;
            this.builtArea += construction;
        }
        this.wealth += investment;
    }

    public String getAddress() {
        return address;
    }

//    public Long getH3Id() {return h3Id; }


    public Double getUrbanGrowthRate() {
        return urbanGrowthRate;
    }

    public void setUrbanGrowthRate(Double urbanGrowthRate) {
        this.urbanGrowthRate = urbanGrowthRate;
    }

    public String getAddressYear() {
        return this.addressYear;
    }

    public List<Tile> getNeighbors() {
        if(neighbors==null || neighbors.size()==0) {
            (new TileServiceImpl().findNeighbors(this)).forEach(neighbors::add);
        }
        return neighbors;
    }

    public void addNeighbor(Tile n) {
        this.neighbors.add(n);
    }

    public Double getInitialPopRate() {
        return initialPopRate;
    }

    public void setInitialPopRate(Double initialPopRate) {
        this.initialPopRate = initialPopRate;
    }

    private void calculatePopGrowthRate(WorldOrder wo) {
        if( (this.initialPopRate==null || this.initialPopRate == 0.0) &&
                this.population > 2.0 && this.weeklyGTP > 0.0 &&
                grid.getwGTPCoef() != null && grid.getPgntrcpt() != null) {
            int wks = wo.getDataYear().getWeeksThisYear();
            double ex;
            if (wks == 53) {
                ex = 1.0 / 53.0;
            } else {
                ex = 1.0 / 52.0;
            }
            double rate;
            if ((this.urbanPop == null || this.urbanPop == 0.0)) {
                rate = grid.getPgntrcpt() + (grid.getwGTPCoef() * Math.log(weeklyGTP) ) +
                        (grid.getdPopCoef() * (this.population / grid.getKm2() ) );
            } else {
                rate = grid.getPgntrcpt() + (grid.getwGTPCoef() * Math.log(weeklyGTP) ) +
                        (grid.getdPopCoef() * (this.population / grid.getKm2() ) ) +
                        (grid.getdUrbCoef() * (this.urbanPop / grid.getKm2()) );
            }
            this.initialPopRate = Math.pow(rate, ex);
            this.pgRate = 1.0 +  Math.pow(rate, ex);
//            lognormal(0.04169315, 0.07970476)**(1.0/52.0)
            LogNormalDistribution ld = new LogNormalDistribution(new MTFApache(wo.random), 0.04169315, 0.07970476);
        } else if (this.population < 2.0 && this.weeklyGTP < (0.021 * this.population)) {
            migrate(wo.random);

        }
    }

    public double getPopDensity() {
        double d = this.population / this.grid.getKm2();
        return d;
    }

    public double getUpopDensity() {
        if(this.urbanPop > 0.0 && this.builtArea > 0.0) {
            double d = this.urbanPop / this.builtArea;
            return d;
        }
        return 0.0;
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

    public double getWealth() {
        return wealth;
    }

    public void setWealth(double wealth) {
        this.wealth = wealth;
        memory.add(wealth);
    }

    public double getWeeklyGrossTileProduction() {
        if (this.weeklyGTP==null || this.weeklyGTP.isNaN() || this.weeklyGTP.isInfinite()) {
            this.weeklyGTP = 0.0;
        }
        return this.weeklyGTP;
    }

    public double getEstimatedGTP() {
        return this.weeklyGTP * 52;
    }

    public double getGrossTileProductionLastYear() {
        double annualGtp = weeklyTrendGTP.pastYearTotal();
//        this.weeklyTrendGTP.clear();
        return annualGtp;
    }

    public void setWeeklyGrossTileProduction(double grossTileProduction) {
        this.weeklyGTP = grossTileProduction;
        weeklyTrendGTP.add(grossTileProduction);

    }

    public double getBuiltUpArea() {
        return builtArea;
    }

    public void setBuiltUpArea(double builtUpArea) {
        this.builtArea = builtUpArea;
    }

    public Territory getLinkedTerritory() {
        return linkedTerritory;
    }

    public void setLinkedTerritory(Territory territory) {
        this.linkedTerritory = territory;
    }

    public double getUrbanPop() {
        return urbanPop;
    }

    public void setUrbanPop(double uPop) {
        this.urbanPop = uPop;
    }

    public DataTrend getMemory() {
        return memory;
    }

    public DataTrend getGrowth() {
        return growth;
    }

    public Grid getGrid() {
        return grid;
    }

    public void findGrid() {
        this.grid = new GridServiceImpl().findGridForTile(this);
        if(this.grid.getKm2()==null) {
            this.grid.loadGridInfo();
        }
    }

    public int getTerritoryYear() {
        return linkedTerritory.getYear();
    }

    private boolean evenStep(WorldOrder wo) {
        return wo.getStepNumber() % 2 == 1;
    }

//    public boolean loadFacts(Map<String, Object> data) {
//        Long a = ((Number) data.get("a")).longValue();
//        Double p = ((Number) data.get("p")).doubleValue();
//        Double u = ((Number) data.get("u")).doubleValue();
//        Double w = ((Number) data.get("w")).doubleValue();
//        Double g = ((Number) data.get("g")).doubleValue();
//        Double b = ((Number) data.get("b")).doubleValue();
//        if (Objects.equals(a, this.h3Id)) {
//            this.setPopulation(p);
//            this.setUrbanPopulation(u);
//            this.setWealth(w);
//            this.setGrossTileProduction(g);
//            this.setBuiltUpArea(b);
//            growth.add(p);
//            getNeighbors();
//            return true;
//        } else {
//            return false;
//        }
//    }

//    private void growPopulation(WorldOrder wo) {
//        // Population growth is a linear function of regional wealth (averaged over length of `memory`) and the proportion of the
//        // population that is urban. It varies between 0.09795 for urban population with negative history of average wealth--
//        // increasing toward 1.0 as proportion of urban population decreases--to 1.0205 for rural populations with positive
//        // wealth history. These numbers hacked out crudely from @article {Cohen1995, author={Cohen, JE}, title={
//        // Population growth and earth's human carrying capacity}, volume={269}, number={5222}, pages={341--346}, year={1995},
//        // publisher = {American Association for the Advancement of Science}, URL={http://science.sciencemag.org/content/269/5222/341},
//        // journal = {Science} } and a linear model: urbanization [0.0, 0.3, 0.8] x growth [0.02, 0.01, 0.003], lm(growth ~ urbanization)
//        //
//        if (this.population == 0.0) return;
//
//        WorldOrder worldOrder = wo;
//        int w = worldOrder.weeksThisYear;
//        double trend = 1.0;
//        if (growth.size() > 26) {
//            trend = DoubleStreamEx.of(memory).pairMap((a, b) -> b - a).sum();
//        } else {
//            trend = 1.0;
//        }
//        double x = 1.0 / w;
//        double gtppct = weeklyGTP > 0 ? ((weeklyGTP / population)/21) : 1.0;
//        double factor = 1.019 - (0.001 * Math.log(gtppct));
//        double weeklyFactor = Math.pow(factor, x);
//
//        if (trend < 0) {
//            this.population = (-weeklyFactor/2) * this.population;
//            this.urbanPop = (-weeklyFactor/4) * this.urbanPop;
//        } else {
//            this.population = weeklyFactor * this.population;
//        }
//        growth.add(this.population);
//    }

    private boolean loadFacts() {
        return false;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Tile)) return false;
        if (!super.equals(o)) return false;

        Tile tile = (Tile) o;

        if (year != tile.year) return false;
        if (!getAddressYear().equals(tile.getAddressYear())) return false;
        return getAddress().equals(tile.getAddress());
    }

    @Override
    public int hashCode() {
        int result = getAddressYear().hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "Tile{" +
                "addressYear='" + addressYear + '\'' +
                ", address='" + address + '\'' +
                ", year=" + year +
                ", urbanPop=" + urbanPop +
                ", population=" + population +
                ", wealth=" + wealth +
                ", weeklyGTP=" + weeklyGTP +
                ", builtArea=" + builtArea +
                ", neighbors=" + neighbors +
                ", linkedTerritory=" + linkedTerritory +
                ", grid=" + grid +
                '}';
    }
}
