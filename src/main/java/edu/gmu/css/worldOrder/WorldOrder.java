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
        int jobs = 5;
        for (int job = 0; job < jobs; job++) {
            seed = System.currentTimeMillis();
            SimState worldOrder = new WorldOrder(seed, 1945);
            worldOrder.setJob(job);
            worldOrder.start();
            do
                if (!worldOrder.schedule.step(worldOrder))
                    break;
                while(worldOrder.schedule.getSteps() < overallDuration);
            worldOrder.finish();
        }
        System.exit(0);
    }


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

    /**
     * Select a year for baseline data and initialize the global environment with empirical descriptions of States,
     * States have a territory, treasury, securityStrategy, economicStrategy, institutions, processes;
     * A territory represents a time-boxed collection of tiles, which also track the sums of tile attributes;
     * Tiles contain a population, natural resources, economic production, according to HYDE/ data. You can set the
     * 'resetBaselines' flag to true if you want to generate (simulate) new data for the tiles.
     *
     * Set the debugging flag to true to print out comments about what the setup is doing.
     *
    */
    public static boolean DEBUG = false;
    public static boolean RECORDING = true;
    public static boolean DIPEX = true;
    public static boolean ALLIANCES = true;
    public static boolean RANDOM = false;
    private int fromYear; // Choices are 1816, 1880, 1914, 1938, 1945, 1994
    private int untilYear; // Depending on how generic you're willing to be, can be just below next year
    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    // and globalHostility is the collection of that data.
    public static int overallDuration;
    public static int stabilityDuration;
    public static double initializationPeriod;
    public DataTrend globalHostility;
    public double globalWarLikelihood; // based on 136 wars in 10,017 weeks
    public double institutionInfluence;
    public double institutionStagnationRate = 0.99980863; // 1.01^(1.0/52.0)
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


    /**
     * Some parameters for war strategy thresholds.
     * RED is the opposing force size while BLUE is the state's own force size
     * THREAT is the opposing military expenditures while RISK is own military expenditures
     * Goals for each conflict are PUNISH, COERCE, DEFEAT, or CONQUER
     * A polity uses these coefficients to plan their offensive war strategies
     * The four strategies roughly correspond to military missions: strike, show of force, swiftly defeat,
     * and win decisively
     */
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
        modelRun = new Dataset(this);
        System.out.println("Data saved to " + modelRun.getName());
        modelRun.setWarParameters(new DefaultWarParams().getWarParams());
        overallDuration = 20085;    // about 385 years
        stabilityDuration = 10439;  // about 200 years
        initializationPeriod = 52.0;
        globalWarLikelihood = DataQueries.getWarAndConflictAverages().get("onset");
        globalHostility = new DataTrend(stabilityDuration);
        institutionInfluence = 0.000001;
        foRelMultiplier = 0.10;
        fromYear = fy;
        untilYear = uy;
        allTheStates.clear();
        dataYear = new YearServiceImpl().getYearFromIntVal(fromYear);
        weeksThisYear = dataYear.getWeeksThisYear();
        weekExp = 1.0 / weeksThisYear;
        marchingPace  = this.pickMarchingPace(fromYear);
        dateIndex = dataYear.getBegan();
        ruralTiles = 0;
        long first = System.nanoTime();
//        territories = TerritoryQueries.getStateTerritories(fromYear, this);
        tiles = new TileServiceImpl().loadAll(fromYear);
        tiles.values().spliterator().forEachRemaining(tile -> tile.calculatePopGrowthRate(this));
        long second = System.nanoTime();
        System.out.println("1st, ALL the " + fromYear + " tiles fully hydrated in  " +
                (second - first)/1000000000.0);
        allTheStates = new StateServiceImpl().loadSystemMemberStatesAndTerritories(this);
        territories.values().spliterator().forEachRemaining(Territory::findCommonWeal);
        for (State s : allTheStates.values()) allTheLeaders.add(s.getLeadership());
        long third = System.nanoTime();
        System.out.println("2nd, common weals loaded with leadership, leaders, people, institutions... in " +
                (third - second)/1000000000.0);
        territories.putAll(new TerritoryServiceImpl().loadWaterTerritories(fromYear));
        colorGradients = allTheStates.values().stream().map(Polity::getPolColor).toArray(Color[]::new);
        simStartTime = System.nanoTime();
        System.out.println("All told, it took " + (simStartTime - startTime) / 1000000000.0 + " to pull data from the WOKG. ");
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
            for (Tile tile : s.getTerritory().getTileLinks()) {
                tiles.put(tile.getAddressYear(), tile);
                schedule.scheduleRepeating(EPOCH,0, tile,1);
                tile.findGrid();
                if (tile.getUrbanPopTrans() == 0.0 ) ruralTiles++;
            }
            s.establishEconomicPolicy(this);
            s.setWarParams(getModelRunWarParameters());
            schedule.scheduleRepeating(s.getLeadership(), 1,1);
            schedule.scheduleRepeating(s, 2, 1);
        }

        for (Territory t : territories.values()) {
                t.updateTotals();
                // schedule after the tile and every half-year after that
//                schedule.scheduleRepeating(t, 1, weeksThisYear);
        }

        // increment the marching pace every 30 years
        schedule.scheduleRepeating(new Technology(), 1564);

        conflictCause = new ProbabilisticCausality(this);
        externalWarStopper = schedule.scheduleRepeating(initializationPeriod, conflictCause);
        conflictCause.setStopper(externalWarStopper);

        World world = new World();
        schedule.scheduleRepeating(world);

        long endstart = System.nanoTime();
        System.out.println("Start proc took " + (endstart - startstart)/1000000000.0 + " to load agents onto the schedule");
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

    public void setInstitutionInfluence(double institutionInfluence) {
        this.institutionInfluence = institutionInfluence;
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

    public static int getOverallDuration() {
        return overallDuration;
    }

    public static void setOverallDuration(int overallDuration) {
        WorldOrder.overallDuration = overallDuration;
    }

    public static void setStabilityDuration(int stabilityDuration) {
        WorldOrder.stabilityDuration = stabilityDuration;
    }

    public static void setInitializationPeriod(double initializationPeriod) {
        WorldOrder.initializationPeriod = initializationPeriod;
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

    //    public void addInstitution(Institution i) {
//        allTheInstitutions.add(i);
//    }
//
//    public void removeInstitution(Institution i) {
//        allTheInstitutions.remove(i);
//    }

//    public Collection<Institution> copyOverInstitutions(List<InstitutionParticipation> ipl) {
//        return ipl.stream().map(InstitutionParticipation::getInstitution)
//                .collect(Collectors.toCollection(ArrayList::new));
//    }

    public double getInitializationPeriod() {
        return initializationPeriod;
    }

    public static Map<String, Double> getModelRunWarParameters(){
        return modelRun.getWarParameters();
    }


}
