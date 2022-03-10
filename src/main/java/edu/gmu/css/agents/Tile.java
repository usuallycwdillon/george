package edu.gmu.css.agents;

import edu.gmu.css.data.DataTrend;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Grid;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.AddressYearStrategy;
import edu.gmu.css.service.GridServiceImpl;
import edu.gmu.css.service.TileServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.*;

import static edu.gmu.css.worldOrder.WorldOrder.*;


@NodeEntity
public class Tile extends Entity implements Serializable, Steppable {
    /**
     * Tiles are implemented as hexagonal (and 12 pentagonal) territorial units defined by Uber H3 Hierarchical Discrete
     * Global Grid object boundaries. Only land tiles are implemented (though unmanaged tiles along the
     * coastlines get created as a side-effect.
     */
    @Id @GeneratedValue (strategy = AddressYearStrategy.class)
    private String addressYear;
//    @Id @GeneratedValue private long id;
//    @Property private String addressYear;
    @Property private String address;
    @Property private String territory;
    @Property private int year;
    @Property private final Double urbanPop = 0.0;
    @Property private final Double population = 0.0;
    @Property private final Double wealth = 0.0;
    @Property private final Double weeklyGTP = 0.0;
    @Property private final Double builtArea = 0.0;
    @Property private Double initialPopRate = 1.00007421;
    @Property private boolean isStateTile;
    @Transient private final Double urbanGrowthRate = 0.0;
    @Transient private final Double taxPayment = 0.0;
    @Transient private Double urbanPopTrans = 0.0;
    @Transient private Double populationTrans = 0.0;
    @Transient private Double wealthTrans = 0.0;
    @Transient private Double weeklyGTPTrans = 0.0;
    @Transient private Double builtAreaTrans = 0.0;
    @Transient private Double urbanGrowthRateTrans = 0.0;
    @Transient private Double taxPaymentTrans = 0.0;
    @Transient private final Double annualGTP = 0.0;
    @Transient private double recruitedPop = 0.0;
    @Transient private double recruitablePop;
    @Transient private Double savingsRate = 0.01923077;
    @Transient // Seven year economic history using Joseph Kitchen (1923) Cycles and Trends in Economic Factors
    private final DataTrend<Double> memory = new DataTrend<Double>(365);  // memory of wealth, not gtp
    @Transient // maintain one year of gtp to measure annual gtp
    private final DataTrend<Double> weeklyTrendGTP = new DataTrend<Double>(52);
    @Transient // Fifteen year population history; half a generation according to Tremblay and Vézina (2000) New estimates of intergenerational time levels...
    private final DataTrend<Double> growth = new DataTrend<Double>(783);
    @Transient // Temporary datatrend for collecting pop growth rates
    private final DataTrend<Double> popGrowthRates = new DataTrend<>(224);
    @Transient private Double weeklyPopGrowthRate;
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
        this.weeklyPopGrowthRate = this.initialPopRate;
        this.memory.add(this.wealthTrans);
        this.growth.add(this.populationTrans);
        this.weeklyTrendGTP.add(this.weeklyGTPTrans);
        this.popGrowthRates.add(this.weeklyPopGrowthRate);
    }


    @Override
    public void step(SimState simState) {
        // There are some private functions to a tile that happen inside the tile. Right now, these are
        // * growPopulation()
        // * produce()
        // Each function records its data for the tile
        WorldOrder worldOrder = (WorldOrder) simState;

//       if (this.getLinkedTerritory().getMapKey() == "Sweden of 1816") {
//           System.out.println("Watch Swedish tiles carefully! ");
//       }

        if (this.populationTrans + this.wealthTrans == 0.0) return;
        if (this.populationTrans < 0.0) {
            this.populationTrans = 0.0;
            return;
        }
        if (this.wealthTrans < 0.0) {
            this.wealthTrans = 0.0;
            return;
        }
//        if (Objects.isNull(this.weeklyPopGrowthRate) || this.weeklyPopGrowthRate == 0.0) {
//            if (this.populationTrans > 4.0 && growth.size() > 1 && growth.average() > 0.0) {
//                this.weeklyPopGrowthRate = growth.averageChangeRate();
//            } else {
//                calculatePopGrowthRate(worldOrder);
//            }
//        }

        this.recruitablePop = (0.25 - (0.05 * urbanPopTrans / populationTrans)) * growth.average();

        if (this.populationTrans > 0.0) {
            growPopulation(worldOrder);
            produce(worldOrder);
            estimateTax();
            consumeSaveAssessSatisfaction();
        }
    }

    private boolean growPopulation(WorldOrder wo) {
        if (Objects.isNull(this.weeklyPopGrowthRate) || this.weeklyPopGrowthRate.isNaN() || this.weeklyPopGrowthRate == 0.0) {
            this.weeklyPopGrowthRate = this.calculatePopGrowthNow(wo.getWeekExp(), wo.getDataYear().getIntYear());
        }
//        boolean step = wo.getStepNumber() > 0L;
        double ex = wo.getWeekExp();
        double newPopulation = this.populationTrans * this.weeklyPopGrowthRate;

        // The population only grows if there is enough wealth to support it.
        double minWealth = findMinimumWealth(newPopulation);
        if (this.wealthTrans > minWealth) {
            this.populationTrans = newPopulation;
        }
        growth.add(this.populationTrans);

        if (this.urbanPopTrans > 0.0) {
            double ran = wo.random.nextDouble();
            double urbRate = ((ran * 0.0025) + 1.00269135) * this.weeklyPopGrowthRate;
            double estimate = this.urbanPopTrans * Math.pow(urbRate, ex);
            this.urbanPopTrans = Math.min(estimate, this.populationTrans);
            if(this.builtAreaTrans > 0.0) {
                build(urbRate, ex);
            }
        }
        if(this.populationTrans < 4.0 && this.populationTrans > 0.0) {
            migrate(wo);
        }
        if (wo.getWeekNumber() % 13 == 0) {
            this.weeklyPopGrowthRate = this.grid.calculatePopGrowthNow(this, wo.getWeekExp());
            this.popGrowthRates.add(this.weeklyPopGrowthRate);
        }
        return this.populationTrans > 0.0;
    }

    private boolean produce(WorldOrder wo) {
        // Crude Cobb-Douglass production function using urban/rural percentages to influence and capital and
        // labor elasticity based on estimates of employed population and estimated wealth available for production.
        WorldOrder worldOrder = wo;
        if (this.populationTrans < 4.0) {
            migrate(worldOrder);
            return false;
        }

        double ruralPop = this.populationTrans - this.urbanPopTrans;
        double urbanization = this.populationTrans > 0.0 ? this.urbanPopTrans / this.populationTrans : 0.0;
        double labor = ((this.urbanPopTrans * 0.75) + (ruralPop * 0.65)) - this.recruitedPop;
        double laborElasticity = (0.6 + (urbanization * 0.1) ) - (0.1 * (this.recruitedPop / this.recruitablePop));
        double kapitalElasticity = 1.0 - laborElasticity;

        Double production = 0.0;
        double usableWealth = this.wealthTrans * (1.0 - (0.5 * this.recruitedPop / this.recruitablePop));
        Double logProduction;
        if (usableWealth > 0.0 && labor > 0.0) {
            logProduction = (Math.log(usableWealth) * kapitalElasticity) + (Math.log(labor) * laborElasticity);
        } else {
            logProduction = 1.0;
        }
        if (!logProduction.isNaN() && !logProduction.isInfinite()) {
            production = Math.exp(logProduction);
        }

//
        this.setWeeklyGrossTileProduction(production);
//        if (production > weeklyGTP * 10) {
//            System.out.println("production grew large");
//        }

//        if (this.weeklyTrendGTP.average() < this.growth.average() * 0.021) {
//            migrate(worldOrder);
//        }

        return !production.isNaN() && !production.isInfinite() && production != 0.0;
    }

    private double findMinimumWealth() {
        return findMinimumWealth(this.populationTrans);
    }

    private double findMinimumWealth(double pop) {
        Double minWealth = 0.0;
        double minGTP = pop * 0.021;
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
        if (DEBUG && (minWealth.isInfinite() || minWealth.isNaN())) {
            System.out.println(this.addressYear + " minimum wealth calculation returns garbage");
        }
        return minWealth;
    }

    private void estimateTax() {
        // Using Farris et al's $3/day min threshold as a minimum required for pop to survive.
        // Remember money is in 1,000's.
        double rate;
        if (linkedTerritory==null) {
            System.out.println(this.addressYear + " has no linked territory");
        }
        if (linkedTerritory.getPolity()==null) {
            System.out.println(linkedTerritory.getMapKey() + " no polity");
        }
        if (linkedTerritory.getPolity().getEconomicPolicy() != null) {
            rate = linkedTerritory.getPolity().getEconomicPolicy().getTaxRate();
        } else {
            System.out.println(linkedTerritory.getPolity().getName() + " has no economic policy");
            rate = 0.00025;
        }
        double taxBurden = this.weeklyGTPTrans * rate;
        double survival = this.populationTrans * 0.021;
        double excess = Math.max(this.weeklyGTPTrans - survival, 0.0);
        Double payment = Math.min(excess, taxBurden);
        if ((payment.isNaN() || payment.isInfinite()) && DEBUG) {
            System.out.println(this.addressYear + " generated tax is " + payment );
        }
        this.taxPaymentTrans = payment;
    }

    private void consumeSaveAssessSatisfaction() {
        // Consumption = weekly gtp - (savings + tax payment)
        // Using and West's estimate that urban dwellers require (on average) 11x the production of rural dwellers, the
        // savings threshold is urbanPop * 280 + pop * 28.
        // Goldsmith 1962 found a average 3.5% annual increase in US private wealth in 1947-59 (13 years inclusive)
        // so I'm using a range of -3% growth at 0% satisfaction and 14% at 100% satisfaction, because national trends
        // do not represent the heterogeneity of the tile economies.
        double newWealth = 0.0;
        if (this.populationTrans > 0.0) {
            double savingsThreshold = (this.populationTrans * 0.028) + (this.urbanPopTrans * 0.28); // $4/person + x11 city multiplier
            double satisfactionThreshold = this.populationTrans * 1.34615; // $70k/year (by thousands, remember)
            // Satisfaction depends on disposable income after paying taxes
            double consumable = this.weeklyGTPTrans - (savingsThreshold + this.taxPaymentTrans);
            if (consumable > 0.0) {
                this.satisfaction = Math.min( (consumable / satisfactionThreshold), 1.1 );
            } else {
                this.satisfaction = 0.0;
            }
            double annualGrowth = 0.97 + (this.satisfaction * 0.17);
            this.savingsRate = (Math.pow(annualGrowth, 0.01923077) - 1.0); // maximum wealth increase of 1.04% per year, based on (Goldsmith 1962)
            double expectedSavings  = this.wealthTrans * this.savingsRate;
            double savings = Math.min(expectedSavings, consumable); // savings rate could be less than zero
            newWealth = this.wealthTrans + savings;
            this.setWealthTrans(newWealth);
        } else {
            this.satisfaction = 0.0;
        }
        memory.add(newWealth);
    }

    public void build(double uRate, double ex) {
        double bRate = 1.0 + (-0.0018078408 + ((uRate - 1.0) * 0.9194060347));
        double estimate = Math.pow(bRate, ex) * this.builtAreaTrans;
        this.builtAreaTrans = Math.min(estimate, this.grid.getKm2());
    }

    // External (State) agents takes taxes ...and some wealth (if there is any) if the tile cannot pay its full tax
    public Double payTaxes(double taxRate) {
        double taxBill = (this.weeklyGTPTrans - (this.populationTrans * 0.021)) * taxRate;
        if (this.taxPaymentTrans >= taxBill) {
//            double extra = this.taxPaymentTrans - taxBill;
//            this.wealthTrans += extra;
            this.taxPaymentTrans = 0.0;
        } else {
            double balance = taxBill - this.taxPaymentTrans;
            double tileLoss = Math.min((this.wealthTrans - this.findMinimumWealth()), balance) * 0.5;
            double payment = this.taxPaymentTrans + tileLoss;
            this.wealthTrans -= tileLoss;
            this.taxPaymentTrans = 0.0;
            taxBill = Math.max(payment, 0.0);
        }
        return taxBill;
    }

    public double supplySoldiers(double ratio) {
        // new version
        double provided = 0.0;
        if (this.populationTrans > 99.0) {
            double requested = ratio * this.populationTrans;
            double available = recruitablePop - recruitedPop;
            provided = Math.min(requested, available);
            this.recruitedPop += provided;
            if (this.urbanPopTrans > 0.5 * available) {
                this.urbanPopTrans -= 0.5 * provided;
                this.populationTrans -= 0.5 * provided;
            } else {
                this.populationTrans -= provided;
            }
        }
        return provided;
    }

    public void migrate(WorldOrder wo) {
        // a random number of people (1 - 10%) migrate and
        // take with them up to 25% of their 'share' of the wealth (can't take the built environment).
        WorldOrder worldOrder = wo;
        if(this.populationTrans.isInfinite() || this.populationTrans.isNaN()) {
            this.populationTrans = growth.average();
        }
        double migrants = 0.0;
        double wealthMigration = 0.0;
        if(this.populationTrans < 4.0 && this.populationTrans > 0.0) {
            migrants = this.populationTrans;
            if (this.wealthTrans > 0.0) wealthMigration = this.wealthTrans * 0.25;
        } else {
            double r = wo.random.nextDouble();
            double departPart = r * 0.1;
            double wealthPart = r * 0.25;
            double capacity = this.weeklyTrendGTP.average() * 0.021;
            migrants = (Math.max((this.populationTrans - capacity), 0.0)) * departPart;
            if (this.wealthTrans > 0.0 && this.populationTrans > 0.0) {
                wealthMigration = (this.wealthTrans / this.populationTrans) * wealthPart * migrants;
            } else {
                wealthMigration = 0.0;
            }
        }
        List<Tile> neighbors = getNeighbors(worldOrder);
        Tile richest = neighbors.get(0);
        for (Tile n : neighbors) {
            double gtp = n.weeklyGTPTrans;
            if (gtp > richest.getWeeklyGTPTrans()) richest = n;
        }
        richest.setPopulationTrans(richest.getPopulationTrans() + migrants);
        if (richest.getUrbanPopTrans() > 0.0) richest.setUrbanPopTrans(richest.getUrbanPopTrans() + (0.8 * migrants));
        richest.setWealthTrans(richest.getWealthTrans() + wealthMigration);
        this.populationTrans -= migrants;
        this.wealthTrans -= wealthMigration;
    }

    private boolean migrateWealth(WorldOrder wo) {
        boolean migrated = false;
        for (Tile n : this.getNeighbors(wo)) {
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
        this.wealthTrans += investment * 2 * this.savingsRate * this.satisfaction;
        if (this.builtAreaTrans > 0.0) {
            double rate = builtAreaTrans / wealthTrans;
            double construction = rate * investment * 2 * this.savingsRate * this.satisfaction;
            this.builtAreaTrans += construction;
        }
    }

    public String getAddress() {
        return address;
    }

    public int getYear() {
        return year;
    }

    public Double getUrbanPop() {
        return urbanPop;
    }

    public Double getPopulation() {
        return population;
    }

    public Double getWealth() {
        return wealth;
    }

    public Double getWeeklyGTP() {
        return weeklyGTP;
    }

    public Double getBuiltArea() {
        return builtArea;
    }

    public Double getInitialPopRate() {
        return initialPopRate;
    }

    public boolean isStateTile() {
        return isStateTile;
    }

    public List<Tile> getNeighbors() {
        return neighbors;
    }

    public Double getUrbanGrowthRateTrans() {
        return urbanGrowthRateTrans;
    }

    public void setUrbanGrowthRateTrans(Double urbanGrowthRateTrans) {
        this.urbanGrowthRateTrans = urbanGrowthRateTrans;
    }

    public String getAddressYear() {
        return this.addressYear;
    }

    public List<Tile> getNeighbors(WorldOrder wo) {
        if(neighbors==null || neighbors.size()==0) {
            (new TileServiceImpl().findNeighbors(this, wo)).forEach(neighbors::add);
        }
        return neighbors;
    }

    public Double getBuiltAreaTrans() {
        return builtAreaTrans;
    }

    public void addNeighbor(Tile n) {
        this.neighbors.add(n);
    }

    public Double getWeeklySDP() {
        Double sdp = this.weeklyGTPTrans - (this.populationTrans * 0.021);
        return sdp;
    }

    public Double getSavingsRate() {
        return savingsRate;
    }

    public void setSavingsRate(Double savingsRate) {
        this.savingsRate = savingsRate;
    }

    public void calculatePopGrowthRate(WorldOrder wo) {
        // do we even care what the pop growth rate is?
        if (!this.isStateTile) {
            return;
        }
        WorldOrder worldOrder = wo;
        int yearNow = worldOrder.getDataYear().getIntYear();
        if (Objects.isNull(this.grid)) {
            this.findGrid();
        }
        if (Objects.isNull(this.grid.getPopGrowthIntercept()) || this.grid.getPopGrowthIntercept()==0.0) {
            this.weeklyPopGrowthRate = this.grid.modelPopGrowth(worldOrder, this);
//            new GridServiceImpl().createOrUpdate(this.grid);
            if (DEBUG) System.out.println("Tile " + this.addressYear + " had to recalculate its grid's pop growth regression model.");
        }
        if (Objects.isNull(this.weeklyPopGrowthRate) || this.weeklyPopGrowthRate == 0.0) {
            this.weeklyPopGrowthRate = this.calculatePopGrowthNow(worldOrder.getWeekExp(), yearNow);
        }
        if (Objects.isNull(this.weeklyPopGrowthRate) || this.weeklyPopGrowthRate == 0.0) {
            if (SETUP) {
                this.weeklyPopGrowthRate = this.initialPopRate;
            } else {
                this.weeklyPopGrowthRate = 1.00007421;
            }
        }
    }

    public boolean isSafeToSave() {
        boolean soFar = false;
        if (this.year==1816 || this.year==1880 || this.year==1914 || this.year==1938 ||this.year==1945 || this.year==1994) {
            soFar = this.populationTrans == this.population &&
                    this.wealthTrans == this.wealth &&
                    this.urbanPopTrans == this.urbanPop &&
                    this.weeklyGTPTrans == this.weeklyGTP &&
                    this.builtAreaTrans == this.builtArea;
        } else {
            soFar = false;
        }
        return soFar;
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

    public Double getWeeklyPopGrowthRate() {
        return this.weeklyPopGrowthRate;
    }

    /**
     * Only use this method to change the default, persisted initial population growth rate, preserved in the database
     * @param d
     */
    public void setInitialPopRate(Double d) {
        this.initialPopRate = d;
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

//    public void updatePopGrowthRate(double exp, int y) {
//        this.weeklyPopGrowthRate = calculatePopGrowthNow(exp, y + 1);
//        this.urbanGrowthRateTrans = this.weeklyPopGrowthRate * 1.015;
//    }

    public void updatePopGrowthRate(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        double diff = 0.0;
        double sd = Objects.isNull(grid.getSdPopGrowth()) ? 0.00037019143163728984 : grid.getSdPopGrowth();
        double min = Objects.isNull(grid.getMinPopGrowth()) ? 0.9997138694066504 : grid.getMinPopGrowth();
        double max = Objects.isNull(grid.getMaxPopGrowth()) ? 1.0013409416751313 : grid.getMaxPopGrowth();
        double mean = Objects.isNull(grid.getMeanPopGrowth()) ? 1.0001995919067956 : grid.getMeanPopGrowth();
        double sigma = worldOrder.random.nextDouble(true, true) * sd;
        double urbanization = this.urbanPopTrans / this.populationTrans;
        boolean plusminus = worldOrder.random.nextBoolean(0.55);

        if (this.getPopDensity() > 0.64880055) {
            if (this.satisfaction < 1.0) {
                diff = max - min;
                if (plusminus) {
                    this.weeklyPopGrowthRate = min + (this.satisfaction * diff) + sigma;
                } else {
                    this.weeklyPopGrowthRate = min + (this.satisfaction * diff) - sigma;
                }
            } else {
                diff = mean - min;
                if (plusminus) {
                    this.weeklyPopGrowthRate = mean - ((this.satisfaction - 1.0) * diff) + sigma;
                } else {
                    this.weeklyPopGrowthRate = mean - ((this.satisfaction - 1.0) * diff) - sigma;
                }
            }
        } else {
            diff = max - min;
            if (plusminus) {
                this.weeklyPopGrowthRate = min + (this.satisfaction * diff) + sigma;
            } else {
                this.weeklyPopGrowthRate = min + (this.satisfaction * diff) - sigma;
            }
        }
        double urbanS = 0.00269135 * worldOrder.random.nextDouble();
        // TODO: figure out distro of urbanization rates by population growth rates
        this.urbanGrowthRateTrans = Math.pow(this.weeklyPopGrowthRate, 1.00269135);
    }

    public Double calculatePopGrowthNow(double x, int y) {
        int yearNow = y;
        if (DEBUG && (this.weeklyPopGrowthRate.isNaN() || this.weeklyPopGrowthRate.isInfinite())) {
            System.out.println(this.addressYear + " has a bogus population growth rate, even before calculation");
        }
        double uPopCoef = Objects.isNull(grid.getPopUrbanPopCoef()) ? 0.0 : grid.getPopUrbanPopCoef();
        double pgBaCoef = Objects.isNull(grid.getPopBuiltAreaCoef()) ? 0.0 : grid.getPopBuiltAreaCoef();
        double km2 = grid.getKm2();
        int matrixStatus = grid.getMatrixStatus();

//        if (y==1817) {
//            System.out.println("pause here for a break");
//        }

        double ex = x;
        Double r = 1.00007421;
        Double maxRate = Math.pow(1.15, ex);
        if (matrixStatus == 3) {
            Double baseRate = grid.getPopGrowthIntercept() + (
                    grid.getPopGrowthGtpCoef() * Math.log10(this.getWeeklyGTPTrans() + 1.0)) + (
                    grid.getPopDensityCoef() * this.getPopulationTrans() / km2) + (
                    grid.getPopYearCoef() * yearNow);
            baseRate = getRateWithinParameters(baseRate);
            r = Math.max(Math.pow(baseRate, ex),maxRate);
            if (r.isNaN() || r.isInfinite()) {
                if (DEBUG) System.out.println(this.addressYear + " now has a bogus population growth rate");
            }
        } else if (matrixStatus == 4) {
            Double urbanRate = grid.getPopGrowthIntercept() + (
                    grid.getPopGrowthGtpCoef() * Math.log10(this.getWeeklyGTPTrans() + 1.0)) + (
                    grid.getPopDensityCoef() * this.getPopulationTrans() / km2) + (
                    grid.getPopYearCoef() * yearNow) + (
                    uPopCoef * this.getUrbanPopTrans());
            urbanRate = getRateWithinParameters(urbanRate);
            r = Math.max(Math.pow(urbanRate, ex),maxRate);
            if (r.isNaN() || r.isInfinite()) {
                if (DEBUG) System.out.println(this.addressYear + " now has a bogus population growth rate");
            }
        } else if (matrixStatus == 5) {
            Double builtRate = grid.getPopGrowthIntercept() + (
                    grid.getPopGrowthGtpCoef() * Math.log10(this.getWeeklyGTPTrans() + 1.0)) + (
                    grid.getPopDensityCoef() * this.getPopulationTrans() / km2) + (
                    grid.getPopYearCoef() * yearNow) + (
                    pgBaCoef * this.getBuiltAreaTrans());
            builtRate = getRateWithinParameters(builtRate);
            r = Math.max(Math.pow(builtRate, ex),maxRate);
            if (r.isNaN() || r.isInfinite()) {
                if (DEBUG) System.out.println(this.addressYear + " now has a bogus population growth rate");
            }
        } else if (matrixStatus == 6) {
            Double biltUrbanRate = grid.getPopGrowthIntercept() + (
                    grid.getPopGrowthGtpCoef() * Math.log10(this.getWeeklyGTPTrans() + 1.0)) + (
                    grid.getPopDensityCoef() * this.getPopulationTrans() / km2) + (
                    grid.getPopYearCoef() * yearNow) + (
                    uPopCoef * this.getUrbanPopTrans()) + (
                    pgBaCoef * this.getBuiltAreaTrans());
            biltUrbanRate = getRateWithinParameters(biltUrbanRate);
            r = Math.max(Math.pow(biltUrbanRate, ex),maxRate);
            if (r.isNaN() || r.isInfinite()) {
                if (DEBUG) System.out.println(this.addressYear + " now has a bogus population growth rate");
            }
        } else {
            r = 1.00007421; // something like global average from 1800-2000, approx 1.0387% annually
        }
        if (r.isNaN() || r.isInfinite()) {
            r = 1.00007421;
            if (DEBUG) System.out.println(this.addressYear + " now has a bogus population growth rate");
        }
        return r;
    }

    private Double getRateWithinParameters(Double r) {
        Double rate = r;
        if (DEBUG && (rate.isNaN()||rate.isInfinite()) ) {
            System.out.println("Something is already wrong with the unchecked rate");
        }
        if (rate < 0.85) {
            rate = 0.85;
        } else if (rate > 1.15) {
            rate = 1.15;
        }
        return rate;
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
        if (o == null) return false;
        if (this == o) return true;
        if (((Tile) o).getAddressYear().equals(this.getAddressYear())) return true;
        if (!(o instanceof Tile)) return false;

        Tile tile = (Tile) o;

        return getAddressYear().equals(tile.getAddressYear());
    }

//    public boolean equals(Object o) {
//        if (this == o) return true;
//        if (((State) o).getId().equals(this.getId())) return true;
//        if (!(o instanceof State)) return false;
//
//        State state = (State) o;
//
//        if (getId() != null ? !getId().equals(state.getId()) : state.getId() != null) return false;
//        if (!cowcode.equals(state.cowcode)) return false;
//        return getCowcode() != null ? getCowcode().equals(state.getCowcode()) : state.getCowcode() == null;
//    }

    @Override
    public int hashCode() {
        return getAddressYear().hashCode();
    }

    @Override
    public String toString() {
        return "Tile{" +
                "addressYear:" + addressYear +
                ", address:" + address +
                ", year:" + year +
                ", urbanPop:" + urbanPopTrans +
                ", population:" + populationTrans +
                ", wealth:" + wealthTrans +
                ", weeklyGTP:" + weeklyGTPTrans +
                ", builtArea:" + builtAreaTrans +
                ", neighbors:" + neighbors +
                ", linkedTerritory:" + linkedTerritory +
                ", grid:" + grid +
                '}';
    }
}
