package edu.gmu.css.worldOrder;

import edu.gmu.css.agents.Process;
import edu.gmu.css.agents.*;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.data.DefaultWarParams;
import edu.gmu.css.entities.*;
import edu.gmu.css.queries.DataQueries;
import edu.gmu.css.service.*;
import org.apache.commons.math3.distribution.LogNormalDistribution;
import sim.engine.SimState;
import sim.engine.Stoppable;
import sim.util.distribution.Gamma;
import sim.util.distribution.Poisson;

import java.awt.*;
import java.util.List;
import java.util.*;

import static sim.engine.Schedule.EPOCH;


/**
 * Generator for Experiments on Order and Relations in a Global Environment (GEORGE) using the Multi-Agent
 * Simulation On Networks (MASON). ...also, there's this: https://youtu.be/ArNz8U7tgU4?t=10
 *  --or--
 * Simulation Environment of World Processes (SEWP).
 * In partial fulfillment of requirements for award of Doctor of Philosophy in Computational Social Science
 * from the Graduate College of Sciences, George Mason University, Fairfax, Virginia.
 *
 */

public class WorldOrder extends SimState {
    /**
     *
     *
     */
    public static void main(String[] args) {
        int jobs = 1;

        for (int job=0; job<jobs; job++) {
            seed = System.currentTimeMillis();
            WorldOrder worldOrder = new WorldOrder(seed, 1816);
            worldOrder.setJob(job);
            DIPEX = false;
            ALLIANCES = false;
            RECORDING = false;
            DEBUG = false;
            worldOrder.start();
            do
                if (!worldOrder.schedule.step(worldOrder))
                    break;
            while(worldOrder.schedule.getSteps() < worldOrder.getOverallDuration());
            System.out.println("The overall duration has been reached and the simulation will stop.");
            modelRun.setFinalDuration((int) worldOrder.schedule.getSteps());
            modelRun.setFinalWarLikelihood(worldOrder.getGlobalHostility().average());
            worldOrder.finish();
        }

//        int[] years = {1945, 1816, 1880, 1914, 1938};
//        boolean[] dip = {true, false};
//        boolean[] als = {true, false};
//        for (int y : years) {
//            for (boolean d : dip) {
//                for (boolean a : als) {
//                    for (int job = 0; job < jobs; job++) {
//                        seed = System.currentTimeMillis();
//                        WorldOrder worldOrder = new WorldOrder(seed, y);
//                        worldOrder.setJob(job);
//                        worldOrder.DIPEX = d;
//                        worldOrder.ALLIANCES = a;
//                        worldOrder.start();
//                        do
//                            if (!worldOrder.schedule.step(worldOrder))
//                                break;
//                        while(worldOrder.schedule.getSteps() < worldOrder.getOverallDuration());
//                        System.out.println("The overall duration has been reached and the simulation will stop.");
//                        modelRun.setFinalDuration((int)worldOrder.schedule.getSteps());
//                        modelRun.setFinalWarLikelihood(worldOrder.getGlobalHostility().average());
//                        worldOrder.finish();
//                    }
//                }
//            }
//        }
        System.exit(0);
    }

//    public static void main(String[] args) {
//        int jobs = 1;
//        for (int job = 0; job < jobs; job++) {
//            seed = System.currentTimeMillis();
//            WorldOrder worldOrder = new WorldOrder(seed, 1945);
//            worldOrder.setJob(job);
//            worldOrder.DEBUG = false;
//            worldOrder.RECORDING = false;
//            worldOrder.DIPEX = true;
//            worldOrder.ALLIANCES = true;
//            worldOrder.start();
//            do
//                if (!worldOrder.schedule.step(worldOrder))
//                    break;
//            while(worldOrder.schedule.getSteps() < worldOrder.getOverallDuration());
//            System.out.println("The overall duration has been reached and the simulation will stop.");
//            modelRun.setFinalDuration((int)worldOrder.schedule.getSteps());
//            modelRun.setFinalWarLikelihood(worldOrder.getGlobalHostility().average());
//            worldOrder.finish();
//        }
//    }

    // The simulation singleton
    public WorldOrder(long seed) {
        super(seed);
        WorldOrder.seed = seed;
        setup();
    }

    public WorldOrder(long seed, int y) {
        super(seed);
        WorldOrder.seed = seed;
        setup(y);
    }
    public WorldOrder() {
        super(seed);
        seed = System.currentTimeMillis();
        WorldOrder worldOrder = new WorldOrder(seed, 1816);
        worldOrder.setJob(1);
        DIPEX = false;
        ALLIANCES = false;
        RECORDING = false;
        DEBUG = false;
    }

    /**
     * Select a year for baseline data and initialize the global environment with empirical descriptions of States,
     * States have a territory, treasury, securityStrategy, economicStrategy, institutions, processes;
     * A territory represents a time-boxed collection of tiles, which also track the sums of tile attributes;
     * Tiles contain a population, natural resources, economic production, according to HYDE/ data. You can set the
     * 'resetBaselines' flag to true if you want to generate (simulate) new data for the tiles.
     *
     * Set the debugging flag to true to print out comments about what the setup is doing.
     * false
    */
    public static boolean DEBUG = false;
    public static boolean RECORDING = true;
    public static boolean DIPEX = false;
    public static boolean ALLIANCES = false;
    public static boolean RANDOM = false;
    public static boolean CONQUEST = false;
    public static boolean SCHISM = false;
    public static boolean ENTRES = false;
    public static boolean REINVEST = true;
    public static boolean SETUP = true;
    private int fromYear; // Choices are 1816, 1880, 1914, 1938, 1945, 1994
    private int untilYear; // Depending on how generic you're willing to be, can be just below next year
    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    // and globalHostility is the collection of that data.
    public int overallDuration;
    public int stabilityDuration;
    public double initializationPeriod;
    public DataTrend globalHostility;
    public double globalWarLikelihood; // based on 136 wars in 10,017 weeks
    public static double institutionInfluence;
    public static double institutionStagnationRate;
    public static Poisson poisson;
    public static Gamma gamma;
    public static LogNormalDistribution lognormal;
    private static Long seed;
    public static Dataset modelRun;
    public Year dataYear;
    public int weeksThisYear;
    public long dateIndex;
    public double weekExp;
    public int marchingPace;
    public Map<String, State> allTheStates = new HashMap<>();
    public Color[] colorGradients;
    public List<Leadership> allTheLeaders = new ArrayList<>();
    public Map<String, Territory> territories = new HashMap<>();
    public static Set<Territory> tileTerritories = new HashSet<>(); // just temporary, to collect tile territories
    public Set<War> allTheWars = new HashSet<>();
    public Set<Process> allTheProcs = new HashSet<>();
    public Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public Set<WarProcess> allTheWarProcs = new HashSet<>();
    public Map<String, Tile> tiles = new HashMap<>();
    public Dataset spatialDataset;
    public Map<Long, Integer> warCountHistory = new HashMap<>();
    public Set<Institution> allTheInstitutions = new HashSet<>();
    public boolean configChosen = false;
    public ProbabilisticCausality conflictCause;
    public static long stepNo;
    public double foRelMultiplier;
    public int ruralTiles;
    public Stoppable externalWarStopper;
    public long simStartTime;
    private World world;


    public boolean setup() {
        setup(1816,1818);
        return false;
    }

    public boolean setup(int fy) {
        setup(fy, fy + 2);
        return false;
    }

    public boolean setup(int fy, int uy) {
        // new dataset node in graph to track this data will be saved only if this run get started.
        // set model run parameters
        long startTime = System.nanoTime();
        System.out.println("Setup began at " + startTime / 10000000.0 );

        fromYear = fy;
        untilYear = uy;
        overallDuration = 20085;    // about 385 years
        stabilityDuration = 10439;  // about 200 years
        initializationPeriod = 52.0;
        globalWarLikelihood = DataQueries.getWarAndConflictAverages().get("onset");
        globalHostility = new DataTrend(stabilityDuration);
        institutionInfluence = 0.000001;
        institutionStagnationRate  = 0.99980863; // 1.01^(1.0/52.0)
        foRelMultiplier = 0.10;
        allTheStates.clear();
        dataYear = new YearServiceImpl().getYearFromIntVal(fromYear);
        weeksThisYear = dataYear.getWeeksThisYear();
        weekExp = 1.0 / weeksThisYear;
        marchingPace  = this.pickMarchingPace(fromYear);
        dateIndex = dataYear.getBegan();
        ruralTiles = 0;
        long first = System.nanoTime();
        tiles = new TileServiceImpl().loadAll(fromYear);
//        tiles.values().spliterator().forEachRemaining(tile -> tile.calculatePopGrowthRate(this));
        long second = System.nanoTime();
        long diff12 = second - first;
        allTheStates = new StateServiceImpl().loadSystemMemberStatesAndTerritories(this);
        territories.values().spliterator().forEachRemaining(Territory::findCommonWeal);
        for (State s : allTheStates.values()) s.gatherInstitutionPartners(this);
        for (State s : allTheStates.values()) allTheLeaders.add(s.getLeadership());
        long third = System.nanoTime();
        long diff23 = third - second;
        territories.putAll(new TerritoryServiceImpl().loadWaterTerritories(fromYear));
        colorGradients = allTheStates.values().stream().map(Polity::getPolColor).toArray(Color[]::new);
        simStartTime = System.nanoTime();
        long diff04 = simStartTime - simStartTime;
        System.out.println("All told, it took " + (diff04 / 10000000.0) + " to pull data from the WOKG. ");
        modelRun = new Dataset(this);
        System.out.println("Data saved to " + modelRun.getName());
        modelRun.setWarParameters(new DefaultWarParams().getWarParams());
        modelRun.setTileHydrationTime(diff12/10000000L);
        modelRun.setPolityHydrationTime(diff23/10000000L);
        world = new World();
        SETUP = false;
        return true;
    }


    public void start() {
        super.start();
        long startstart = System.nanoTime();
        // new dataset node in graph to track this data
        // save this model run to the database for later
        if (RECORDING) new DatasetServiceImpl().createOrUpdate(modelRun);
        // Put it all the steppables on the schedule
        for (State s : allTheStates.values()) {
            Territory tt = s.getTerritory();
            for (Tile tile : tt.getTileLinks(this)) {
//                tiles.put(tile.getAddressYear(), tile);
                schedule.scheduleRepeating(EPOCH,0, tile,1);
//                tile.findGrid();
                if (tile.getUrbanPopTrans() == 0.0 ) ruralTiles++;
            }
            tt.updateTotals();
//            s.establishEconomicPolicy(this);
            s.setWarParams(getModelRunWarParameters());
            schedule.scheduleRepeating(s.getLeadership(), 1,1);
            schedule.scheduleRepeating(s, 2, 1);
        }

        // increment the marching pace every 30 years
        schedule.scheduleRepeating(new Technology(), 1564);
        // stochastically-generated issues may cause conflicts
        conflictCause = new ProbabilisticCausality(this);
        externalWarStopper = schedule.scheduleRepeating(initializationPeriod, conflictCause);
        conflictCause.setStopper(externalWarStopper);
        // the agent of other changes in the world
        schedule.scheduleRepeating(world);

        long endstart = System.nanoTime();
        System.out.println("Start proc took " + (endstart - startstart)/10000000.0 + " to load agents onto the schedule");
    }


    public Long getWeekNumber() {
        return dateIndex + getStepNumber();
    }

    public static long getSeed() {
        return seed;
    }

    public void updatePoisson() {
        poisson = new Poisson(globalWarLikelihood, random);
    }

    public WorldOrder getWorldOrderSimState() {
        return this;
    }

    public Year getDataYear() {
        return this.dataYear;
    }

    public int getFromYear() {return fromYear;}

    public int getUntilYear() {return untilYear;}

    public long getStepNumber() {
        return this.schedule.getSteps();
    }

    public int getStabilityDuration() {
        return stabilityDuration;
    }

    public Dataset getModelRun() {
        return modelRun;
    }

    public Color[] getGradients() {
        return colorGradients;
    }

    public DataTrend getGlobalHostility() {
        return globalHostility;
    }

    public double getGlobalWarLikelihood() {
        return globalWarLikelihood;
    }

    public void setGlobalWarLikelihood(double l) {
        globalWarLikelihood = l;
    }

    public void adjustGlobalWarLikelihood(double l) {
        this.globalWarLikelihood += l;
    }

    public void updateGlobalWarLikelihood(double effect) {
        globalWarLikelihood += effect;
    }

    public Map<String, State> getAllTheStates() {
        return allTheStates;
    }

    public Set<War> getAllTheWars() {
        return allTheWars;
    }

    public Set<PeaceProcess> getAllThePeaceProcs() {
        return allThePeaceProcs;
    }

    public Set<WarProcess> getAllTheWarProcs() {
        return allTheWarProcs;
    }

    public Set<Process> getAllTheProcs() {
        return allTheProcs;
    }

    public void addProc(Process p) {
        allTheProcs.add(p);
    }

    public Map<String, Tile> getTiles() {
        return tiles;
    }

    public Map<String, Territory> getTerritories() {
        return territories;
    }

    public Dataset getSpatialDataset() {
        return spatialDataset;
    }

    public double getInstitutionInfluence() {
        return institutionInfluence;
    }

    public Stoppable getExternalWarStopper() {
        return externalWarStopper;
    }

    public void setExternalWarStopper(Stoppable externalWarStopper) {
        this.externalWarStopper = externalWarStopper;
    }

    public Set<Institution> getAllTheInstitutions() {
        return allTheInstitutions;
    }

    public static boolean isDEBUG() {
        return DEBUG;
    }

    public static void setDEBUG(boolean DEBUG) {
        WorldOrder.DEBUG = DEBUG;
    }

    public static boolean isRECORDING() {
        return RECORDING;
    }

    public int getOverallDuration() {
        return overallDuration;
    }

    public void setOverallDuration(int overallDuration) {
        this.overallDuration = overallDuration;
    }

    public void setStabilityDuration(int stabilityDuration) {
        this.stabilityDuration = stabilityDuration;
    }

    public void setInitializationPeriod(double initializationPeriod) {
        this.initializationPeriod = initializationPeriod;
    }

    public void setGlobalHostility(DataTrend globalHostility) {
        this.globalHostility = globalHostility;
    }

    public static Poisson getPoisson() {
        return poisson;
    }

    public static void setPoisson(Poisson poisson) {
        WorldOrder.poisson = poisson;
    }

    public static void setModelRun(Dataset modelRun) {
        WorldOrder.modelRun = modelRun;
    }

    public void setDataYear(Year dataYear) {
        this.dataYear = dataYear;
    }

    public int getWeeksThisYear() {
        return weeksThisYear;
    }

    public void setWeeksThisYear(int weeksThisYear) {
        this.weeksThisYear = weeksThisYear;
    }

    public double getWeekExp() {
        return weekExp;
    }

    public void setWeekExp(double weekExp) {
        this.weekExp = weekExp;
    }

    public long getDateIndex() {
        return dateIndex;
    }

    public void setDateIndex(long dateIndex) {
        this.dateIndex = dateIndex;
    }

    public void setAllTheStates(Map<String, State> allTheseStates) {
        this.allTheStates = allTheseStates;
    }

    public Color[] getColorGradients() {
        return colorGradients;
    }

    public void setColorGradients(Color[] colorGradients) {
        this.colorGradients = colorGradients;
    }

    public List<Leadership> getAllTheLeaders() {
        return allTheLeaders;
    }

    public void setAllTheLeaders(List<Leadership> allTheLeaders) {
        this.allTheLeaders = allTheLeaders;
    }

    public void setTerritories(Map<String, Territory> territories) {
        this.territories = territories;
    }

    public void setAllTheWars(Set<War> allTheWars) {
        this.allTheWars = allTheWars;
    }

    public void setAllTheProcs(Set<Process> allTheProcs) {
        this.allTheProcs = allTheProcs;
    }

    public void setAllThePeaceProcs(Set<PeaceProcess> allThePeaceProcs) {
        this.allThePeaceProcs = allThePeaceProcs;
    }

    public void setAllTheWarProcs(Set<WarProcess> allTheWarProcs) {
        this.allTheWarProcs = allTheWarProcs;
    }

    public void setTiles(Map<String, Tile> tiles) {
        this.tiles = tiles;
    }

    public void setSpatialDataset(Dataset spatialDataset) {
        this.spatialDataset = spatialDataset;
    }

    public Map<Long, Integer> getWarCountHistory() {
        return warCountHistory;
    }

    public void setWarCountHistory(Map<Long, Integer> warCountHistory) {
        this.warCountHistory = warCountHistory;
    }

    public void setAllTheInstitutions(Set<Institution> allTheInstitutions) {
        this.allTheInstitutions = allTheInstitutions;
    }

    public boolean isConfigChosen() {
        return configChosen;
    }

    public void setConfigChosen(boolean configChosen) {
        this.configChosen = configChosen;
    }

    public ProbabilisticCausality getConflictCause() {
        return conflictCause;
    }

    public void setConflictCause(ProbabilisticCausality conflictCause) {
        this.conflictCause = conflictCause;
    }

    public static long getStepNo() {
        return stepNo;
    }

    public static void setStepNo(long stepNo) {
        WorldOrder.stepNo = stepNo;
    }

    public double getFoRelMultiplier() {
        return foRelMultiplier;
    }

    public void setFoRelMultiplier(double foRelMultiplier) {
        this.foRelMultiplier = foRelMultiplier;
    }

    public int getRuralTiles() {
        return ruralTiles;
    }

    public void setRuralTiles(int ruralTiles) {
        this.ruralTiles = ruralTiles;
    }

    public void updateGlobalHostility() {
        globalHostility.add(globalWarLikelihood);
    }

    public double getInstitutionStagnationRate() {
        return institutionStagnationRate;
    }

    public int getMarchingPace() {
        return this.marchingPace;
    }

    public void setMarchingPace(int i) {
        this.marchingPace = i;
    }

    public void incrementMarchingPace() {
        this.marchingPace++;
    }

    public World getWorld() {
        return this.world;
    }

    public long getCountdown() {
        return world.getCountdown();
    }

    public static void setRECORDING(boolean RECORDING) {
        WorldOrder.RECORDING = RECORDING;
    }

    public static boolean isDIPEX() {
        return DIPEX;
    }

    public static void setDIPEX(boolean DIPEX) {
        WorldOrder.DIPEX = DIPEX;
    }

    public static boolean isALLIANCES() {
        return ALLIANCES;
    }

    public static void setALLIANCES(boolean ALLIANCES) {
        WorldOrder.ALLIANCES = ALLIANCES;
    }

    public static boolean isCONQUEST() {
        return CONQUEST;
    }

    public static void setCONQUEST(boolean CONQUEST) {
        WorldOrder.CONQUEST = CONQUEST;
    }

    public static boolean isSCHISM() {
        return SCHISM;
    }

    public static void setSCHISM(boolean SCHISM) {
        WorldOrder.SCHISM = SCHISM;
    }

    public static boolean isENTRES() {
        return ENTRES;
    }

    public static void setENTRES(boolean ENTRES) {
        WorldOrder.ENTRES = ENTRES;
    }

    public static boolean isRANDOM() {
        return RANDOM;
    }

    public static void setRANDOM(boolean RANDOM) {
        WorldOrder.RANDOM = RANDOM;
    }

    public void setInstitutionStagnationRate(double institutionStagnationRate) {
        WorldOrder.institutionStagnationRate = institutionStagnationRate;
    }

    public long getSimStartTime() {
        return simStartTime;
    }

    private int pickMarchingPace(int y) {
        int pace = 6;
        switch(y) {
            case 1816:
                return 6;
            case 1880:
                return 8;
            case 1914:
                return 9;
            case 1938:
                return 10;
            case 1945:
                return 11;
            case 1994:
                return 12;
        }
        return pace;
    }

    public double getInitializationPeriod() {
        return initializationPeriod;
    }

    public static Map<String, Double> getModelRunWarParameters(){
        return modelRun.getWarParameters();
    }


}
