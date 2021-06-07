package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Grid;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.AddressYearStrategy;
import edu.gmu.css.service.GridServiceImpl;
import edu.gmu.css.service.TileServiceImpl;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.distribution.LogNormalDistribution;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;


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
    @Property private final Double urbanPop = 0.0;
    @Property private final Double population = 0.0;
    @Property private final Double wealth = 0.0;
    @Property private final Double weeklyGTP = 0.0;
    @Property private final Double builtArea = 0.0;
    @Property private Double initialPopRate = 0.0;
    @Transient private final Double urbanGrowthRate = 0.0;
    @Transient private final Double taxPayment = 0.0;
    @Transient private Double urbanPopTrans = 0.0;
    @Transient private Double populationTrans = 0.0;
    @Transient private Double wealthTrans = 0.0;
    @Transient private Double weeklyGTPTrans = 0.0;
    @Transient private Double builtAreaTrans = 0.0;
    @Transient private Double initialPopRateTrans = 0.0;
    @Transient private Double urbanGrowthRateTrans = 0.0;
    @Transient private Double taxPaymentTrans = 0.0;
    @Transient private final Double annualGTP = 0.0;
    @Transient // Seven year economic history using Joseph Kitchen (1923) Cycles and Trends in Economic Factors
    private final DataTrend memory = new DataTrend(365);  // memory of wealth, not gtp
    @Transient // maintain one year of gtp to measure annual gtp
    private final DataTrend weeklyTrendGTP = new DataTrend(53);
    @Transient // Fifteen year population history; half a generation according to Tremblay and Vézina (2000) New estimates of intergenerational time levels...
    private final DataTrend growth = new DataTrend(783);
    @Transient private Double pgRate = initialPopRateTrans;
    @Transient private double satisfaction = 0.0;
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

    @PostLoad
    public void adoptValues(){
        this.populationTrans = this.population;
        this.builtAreaTrans = this.builtArea;
        this.urbanPopTrans = this.urbanPop;
        this.wealthTrans = this.wealth;
        this.weeklyGTPTrans = this.weeklyGTP;
        this.initialPopRateTrans = this.initialPopRate;
    }


    @Override
    public void step(SimState simState) {
        // There are some private functions to a tile that happen inside the tile. Right now, these are
        // * growPopulation()
        // * produce()
        // Each function records its data for the tile
        WorldOrder worldOrder = (WorldOrder) simState;
        if (this.population + this.wealth == 0.0) return;
//        if(this.addressYear.equals("841f261ffffffff.1945")) {
//            System.out.println(this.toString());
//        }

        if (this.populationTrans < 0.0) {
            this.populationTrans = 0.0;
            return;
        }
        if (this.wealthTrans < 0.0) {
            this.wealthTrans = 0.0;
            return;
        }
        if (this.pgRate == 0.0 || (this.pgRate == 0.0 && worldOrder.getStepNumber() < 2L)) {
            if(this.initialPopRateTrans == 0.0) {
                calculatePopGrowthRate(worldOrder);
            } else {
                this.pgRate = 1.0 + this.initialPopRateTrans;
            }
        }
        if (this.populationTrans > 0.0) {
            growPopulation(worldOrder);
            produce(worldOrder);
            estimateTax();
            consumeSaveAssessSatisfaction();
        }

    }

    private void growPopulation(WorldOrder wo) {
        double ex = wo.getWeekExp();
        double newPopulation = this.populationTrans * this.pgRate;
        // The population only grows if there is enough wealth to support it.
        if (this.wealthTrans > findMinimumWealth(newPopulation)) {
            this.populationTrans = newPopulation;
        }
        growth.add(this.populationTrans);
        if (this.urbanPopTrans > 0.0) {
            double urbRate = ((wo.random.nextDouble() * 0.001) + 1.00269135) * pgRate;
            double estimate = this.urbanPopTrans * Math.pow(urbRate, ex);
            this.urbanPopTrans = Math.min(estimate, populationTrans);
            if(this.builtAreaTrans > 0.0) {
                build(urbRate, ex);
            }
        }
        if(this.populationTrans < 2.0 && this.populationTrans > 0.0) migrate(wo.random);
    }

    private void produce(WorldOrder wo) {
        // Crude Cobb-Douglass production function using urban/rural percentages to influence and capital and
        // labor elasticity based on estimates of employed population and estimated wealth available for production.
        WorldOrder worldOrder = wo;

        if (this.populationTrans < 4.0) {
            migrate(worldOrder.random);
            if (this.wealthTrans > 0.0) {
                this.migrateWealth();
                return;
            }
        }

        double ruralPop = this.populationTrans - this.urbanPopTrans;
        double urbanization = this.populationTrans > 0.0 ? this.urbanPopTrans / this.populationTrans : 0.0;
        double labor = (this.urbanPopTrans * 0.75) + (ruralPop * 0.65);
        double laborElasticity = 0.6 + (urbanization * 0.1);
        double kapitalElasticity = 1 - laborElasticity;
        Double production = 0.0;
        Double logProduction = (Math.log(this.wealthTrans) * kapitalElasticity) + (Math.log(labor) * laborElasticity);
        if (!logProduction.isNaN() && !logProduction.isInfinite()) {
            production = Math.exp(logProduction);
        } else {
            if (DEBUG) System.out.println(addressYear + " has a problem in production");
        }
        if (production.isNaN()) {
            System.out.println();
        }
        if (this.wealth.isNaN()) {
            System.out.println();
        }
        if(production < this.populationTrans * 0.021) migrate(worldOrder.random);
        this.setWeeklyGrossTileProduction(production);
    }

    private double findMinimumWealth() {
        return findMinimumWealth(this.populationTrans);
    }

    private double findMinimumWealth(double pop) {
        double minWealth = 0.0;
        double minGTP = pop * 21;
        double urbanization = pop > 0.0 ? this.urbanPopTrans / pop : 0.0;
        double ruralPop = pop - this.urbanPopTrans;
        double ruralLabor = ruralPop * 0.65;
        double urbanLabor = this.urbanPopTrans * 0.75;
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
        double taxBurden = this.weeklyGTPTrans * rate;
        double survival = this.populationTrans * 0.021;
        double excess = Math.max(this.weeklyGTPTrans - survival, 0.0);
        this.taxPaymentTrans = Math.min(excess, taxBurden);
        if(DEBUG && this.taxPaymentTrans == 0.0 && this.populationTrans > 50.0) {
            System.out.println("\n" + this.address + " has a pop but no $$\n");
        }
    }

    private void consumeSaveAssessSatisfaction() {
        // Consumption = weekly gtp - (savings + tax payment)
        // Using and West's estimate that urban dwellers require (on average) 11x the production of rural dwellers, the
        // savings threshold is urbanPop * 280 + pop * 28.
        double savingsThreshold = (this.populationTrans * 0.028) + (this.urbanPopTrans * 0.28); // $4/person + x11 city multiplier
        double satisfactionThreshold = this.populationTrans * 1.34615; // $70k/year (by thousands, remember)
        this.satisfaction = Math.min(((this.weeklyGTPTrans - savingsThreshold) / satisfactionThreshold), 1.0);
        double savingsRate = (this.satisfaction * (Math.pow(1.075, 0.01923077) - 1.0)); // maximum 15% savings/yr
        double savings = savingsRate * this.wealthTrans; // savings rate could be less than zero
        double newWealth = this.wealthTrans + savings;
        setWealthTrans(newWealth);
        memory.add(newWealth);
    }

    public void build(double uRate, double ex) {
        double bRate = 1.0 + (-0.0018078408 + ((uRate - 1.0) * 0.9194060347));
        double estimate = Math.pow(bRate, ex) * this.builtAreaTrans;
        this.builtAreaTrans = Math.min(estimate, this.grid.getKm2());
    }

    // External (State) agents takes taxes ...and some wealth (if there is any) if the tile cannot pay its full tax
    public Double payTaxes(double taxRate) {
        double taxBill = this.weeklyGTPTrans * taxRate;
        if (this.taxPaymentTrans >= taxBill) {
            double extra = this.taxPaymentTrans - taxBill;
            this.wealthTrans += extra;
            this.taxPaymentTrans = 0.0;
        } else {
            double balance = taxBill - this.taxPaymentTrans;
            double tileLoss = Math.min((this.wealthTrans - this.findMinimumWealth()), balance);
            double payment = this.taxPaymentTrans + tileLoss;
            this.wealthTrans -= tileLoss;
            this.taxPaymentTrans = 0.0;
            taxBill = Math.max(payment,0.0);
        }
        return taxBill;
    }

    public double supplySoldiers(double ratio) {
        if (this.populationTrans > 250.0) {
            double numSoldiers = (ratio * this.populationTrans);
            this.populationTrans -= numSoldiers;
            return numSoldiers;
        } else {
            return 0.0;
        }
    }

    public void migrate(MersenneTwisterFast r) {
        // a random number of people (1 - 10%) migrate and
        // take with them up to 25% of their 'share' of the wealth (can't take the built environment).
        if(this.populationTrans.isInfinite() || this.populationTrans.isNaN()) {
            this.populationTrans = 0.0;
        }
        double migrants = 0.0;
        double wealthMigration = 0.0;
        if(this.populationTrans < 2.0 && this.populationTrans > 0.0) {
            migrants = populationTrans;
            if (this.wealthTrans > 0.0) wealthMigration = this.wealthTrans / migrants * 0.75;
        } else {
            MersenneTwisterFast random = r;
            double departPart = random.nextDouble() * 0.1;
            double wealthPart = random.nextDouble() * 0.25;
            double capacity = this.getWeeklyGTPTrans() / 0.021;
            migrants = (Math.max((this.populationTrans - capacity), 0.0)) * departPart;
            if (this.wealthTrans > 0.0 && this.populationTrans > 0.0) {
                wealthMigration = (this.wealthTrans / this.populationTrans) * wealthPart * migrants;
            } else {
                wealthMigration = 0.0;
            }
        }
        List<Tile> neighbors = getNeighbors();
        Tile richest = neighbors.get(0);
        for (Tile n : neighbors) {
            double gtp = n.weeklyGTPTrans;
            if (gtp > richest.getWeeklyGTPTrans()) richest = n;
        }
        richest.setPopulationTrans(richest.getPopulationTrans() + migrants);
        richest.setWealthTrans(richest.getWealthTrans() + wealthMigration);
        this.populationTrans -= migrants;
        this.wealthTrans -= wealthMigration;
    }

    private boolean migrateWealth() {
        boolean migrated = false;
        for (Tile n : this.getNeighbors()) {
            if (n.getPopulationTrans() > 0.0) {
                migrated = true;
                double w = this.wealthTrans * 0.1;
                n.setWealthTrans(n.getWealthTrans() + w);
                this.setWealthTrans(this.wealthTrans - w);
            }
        }
        return migrated;
    }

    public void takeInvestment(double d) {
        double investment = this.populationTrans * d;
        if (this.builtAreaTrans > 0.0) {
            double rate = builtAreaTrans / wealthTrans;
            double construction = rate * investment;
            this.builtAreaTrans += construction;
        }
        this.wealthTrans += investment;
    }

    public String getAddress() {
        return address;
    }

//    public Long getH3Id() {return h3Id; }


    public Double getUrbanGrowthRateTrans() {
        return urbanGrowthRateTrans;
    }

    public void setUrbanGrowthRateTrans(Double urbanGrowthRateTrans) {
        this.urbanGrowthRateTrans = urbanGrowthRateTrans;
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

    public Double getInitialPopRateTrans() {
        return initialPopRateTrans;
    }

    public void setInitialPopRateTrans(Double initialPopRateTrans) {
        this.initialPopRateTrans = initialPopRateTrans;
    }

    public void calculatePopGrowthRate(WorldOrder wo) {
        this.findGrid();
        double ex = wo.getWeekExp();
        double rate;
        if( (this.initialPopRateTrans == null || this.initialPopRateTrans == 0.0) &&
                this.populationTrans > 4.0 && this.weeklyGTPTrans > 0.0 ) {
            if (grid.getPgntrcpt() != null && grid.getdPopCoef() != null) {
                if ((this.urbanPopTrans == null || this.urbanPopTrans == 0.0)) {
                    rate = grid.getPgntrcpt() + (grid.getwGTPCoef() * Math.log(weeklyGTPTrans) ) +
                            (grid.getdPopCoef() * (this.populationTrans / grid.getKm2() ) );
                } else {
                    rate = grid.getPgntrcpt() + (grid.getwGTPCoef() * Math.log(weeklyGTPTrans) ) +
                            (grid.getdPopCoef() * (this.populationTrans / grid.getKm2() ) ) +
                            (grid.getdUrbCoef() * (this.urbanPopTrans / grid.getKm2()) );
                }
                this.initialPopRateTrans = rate;
                this.pgRate = Math.pow(1.0 + rate, ex);
            } else {
                // this should be lognormal(0.04169315, 0.07970476)**(1.0/52.0), from the R analysis, but...
                rate = 0.025 * wo.random.nextDouble(false,true);
                this.initialPopRateTrans = rate;
                this.pgRate = Math.pow(1.0 + rate, ex);
            }
//
//            LogNormalDistribution ld = new LogNormalDistribution(new MTFApache(wo.random), 0.04169315, 0.07970476);
        } else if (this.populationTrans < 4.0 && this.populationTrans > 0.0
                && this.weeklyGTPTrans <= (0.021 * this.populationTrans)) {
            migrate(wo.random);
        } else {
            this.initialPopRate = 0.00011131; // a couple has 2.5 children in 70 years then dies; +0.5 persons / couple
            this.pgRate = 1.00011131;
        }
        if (this.pgRate > 1.1) {
            this.pgRate = Math.pow(pgRate, ex);
        }
    }

    public double getPopDensity() {
        double d = this.populationTrans / this.grid.getKm2();
        return d;
    }

    public double getUpopDensity() {
        if(this.urbanPopTrans > 0.0 && this.builtAreaTrans > 0.0) {
            double d = this.urbanPopTrans / this.builtAreaTrans;
            return d;
        }
        return 0.0;
    }

    public double getPopulationTrans() {
        return populationTrans;
    }

    public void setPopulationTrans(double populationTrans) {
        this.populationTrans = populationTrans;
    }

    public double getWealthTrans() {
        if (this.wealthTrans.isNaN()) {
            return 0.0;
        } else {
            return wealthTrans;
        }
    }

    public void setWealthTrans(double wealthTrans) {
        this.wealthTrans = wealthTrans;
    }

    public double getWeeklyGTPTrans() {
        if (this.weeklyGTPTrans ==null || this.weeklyGTPTrans.isNaN() || this.weeklyGTPTrans.isInfinite()) {
            this.weeklyGTPTrans = 0.0;
        }
        return this.weeklyGTPTrans;
    }

    public double getEstimatedGTP() {
        return this.weeklyGTPTrans * 52;
    }

    public double getGrossTileProductionLastYear() {
        double annualGtp = weeklyTrendGTP.pastYearTotal();
//        this.weeklyTrendGTP.clear();
        return annualGtp;
    }

    public double getTotalGtpThisYear(int w) {
        double annualGtp = weeklyTrendGTP.pastYearTotal(w);
        return annualGtp;
    }

    public void setWeeklyGrossTileProduction(double grossTileProduction) {
        this.weeklyGTPTrans = grossTileProduction;
        weeklyTrendGTP.add(grossTileProduction);

    }

    public void takeDamage(double p, double b) {
        this.populationTrans -= p;
        this.builtAreaTrans -= b;
    }

    public double getBuiltUpArea() {
        return builtAreaTrans;
    }

    public void setBuiltUpArea(double builtUpArea) {
        this.builtAreaTrans = builtUpArea;
    }

    public Territory getLinkedTerritory() {
        return linkedTerritory;
    }

    public void setLinkedTerritory(Territory territory) {
        this.linkedTerritory = territory;
    }

    public double getUrbanPopTrans() {
        return urbanPopTrans;
    }

    public void setUrbanPopTrans(double uPop) {
        this.urbanPopTrans = uPop;
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
        if (Objects.isNull(this.grid)) {
            this.grid = new GridServiceImpl().findGridForTile(this);
        }
        if(this.grid.getKm2()==null) {
            this.grid.loadGridInfo();
        }
    }

    public Double getSatisfaction() {
        return satisfaction;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Tile tile = (Tile) o;

        return getAddressYear().equals(tile.getAddressYear());
    }

    @Override
    public int hashCode() {
        return getAddressYear().hashCode();
    }

    @Override
    public String toString() {
        return "Tile{" +
                "addressYear='" + addressYear + '\'' +
                ", address='" + address + '\'' +
                ", year=" + year +
                ", urbanPop=" + urbanPopTrans +
                ", population=" + populationTrans +
                ", wealth=" + wealthTrans +
                ", weeklyGTP=" + weeklyGTPTrans +
                ", builtArea=" + builtAreaTrans +
                ", neighbors=" + neighbors +
                ", linkedTerritory=" + linkedTerritory +
                ", grid=" + grid +
                '}';
    }
}
