package edu.gmu.css.worldOrder;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.*;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.DefaultWarParams;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.entities.*;
import edu.gmu.css.queries.DataQueries;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.queries.TerritoryQueries;

import edu.gmu.css.queries.TimelineQueries;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;
import sim.util.distribution.Poisson;

import java.awt.*;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Generator for Experiments on the Order and Relations in a Global Environment (GEORGE) using the Multi-Agent
 * Simulation On Networks (MASON). ...also, there's this: https://youtu.be/ArNz8U7tgU4?t=10
 *
 * In partial fulfillment of requirements for award of Doctor of Philosophy in Computational Social Science
 * from the Graduate College of Sciences, George Mason University, Fairfax, Virginia.
 *
 */

public class WorldOrder extends SimState {
    /**
     *
     * @param args
     */
    public static void main(String[] args) {
        int jobs = 1;
        seed = System.currentTimeMillis();
        SimState worldOrder = new WorldOrder(seed);
        for (int job = 0; job < jobs; job++) {
            worldOrder.setJob(job);
            worldOrder.start();
            do
                if (!worldOrder.schedule.step(worldOrder))
                    break;
            while(worldOrder.schedule.getSteps() < 52 * 400);
            worldOrder.finish();
        }
        System.exit(0);
    }


    // The simulation singleton self-manifest
    public WorldOrder(long seed) {
        super(seed);
        WorldOrder.seed = seed;
    }

    public static boolean DEBUG = true;

    /**
     * Select a year for baseline data and initialize the global environment with empirical descriptions of States,
     * States have a territory, treasury, securityStrategy, economicStrategy, institutions, processes;
     * A territory represents a time-boxed collection of tiles, which also track the sums of tile attributes;
     * Tiles contain a population, natural resources, economic production, according to NMC data. You can set the
     * 'resetBaselines' flag to true if you want to generate (simulate) new data for the tiles.
     *
     * Set the debugging flag to true to print out comments about what the setup is doing.
     *
     */
    private static int fromYear = 1816; // Choices are 1816, 1880, 1914, 1938, 1945, 1994
    private static int untilYear = 1818; // Depending on how sloppy you're willing to be, can be just below next year
    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    // and globalHostility is the collection of that data.
    public static int overallDuration = 400 * 52;
    public static int stabilityDuration = 80 * 52;
    public static long initializationPeriod = 10 * 52;
    public static DataTrend globalHostility = new DataTrend(stabilityDuration);
//    public static double warCostFactor;       // The maximum % GDP that any one war can cost
    public static double globalWarLikelihood = 0.185312622886355; // based on 136 wars in 10,017 weeks
    public static double institutionInfluence = 0.0001;
    public static Poisson poisson;
    private static Long seed;
    private static Color[] colorGradients;
    public Dataset modelRun;
    public Year dataYear;
    public int weeksThisYear;
    public long dateIndex;
    public static List<State> allTheStates = new ArrayList<>();
    public static List<Leadership> allTheLeaders = new ArrayList<>();
    public static Map<String, Territory> territories;
    public static Set<War> allTheWars = new HashSet<>();
    public static Set<Process> allTheProcs = new HashSet<>();
    public static Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public static Set<WarProcess> allTheWarProcs = new HashSet<>();
    public static Map<Long, Tile> tiles = new HashMap<>();
    public static Dataset spatialDataset;
    public static Map<Long, Integer> warCountHistory = new HashMap<>();
    public static Set<Institution> allTheInstitutions = new HashSet<>();
    /**
     * Some parameters for war strategy thresholds.
     * RED is the opposing force size while BLUE is own force size
     * THREAT is the opposing military expenditures while RISK is own military expenditures
     * Goals for each conflict are PUNISH, COERCE, DEFEAT, or CONQUER
     * A polity uses these coefficients to plan their offensive war strategies
     * The four strategies roughly correspond to military activities: strike, show of force, swiftly defeat,
     * and win decisively
     */
    private double RED_PUNISH;
    private double RED_COERCE;
    private double RED_DEFEAT;
    private double RED_CONQUER;
    private double BLUE_PUNISH;
    private double BLUE_COERCE;
    private double BLUE_DEFEAT;
    private double BLUE_CONQUER;
    private double THREAT_PUNISH;
    private double THREAT_COERCE;
    private double THREAT_DEFEAT;
    private double THREAT_CONQUER;
    private double RISK_PUNISH;
    private double RISK_COERCE;
    private double RISK_DEFEAT;
    private double RISK_CONQUER;




    public void start() {
        super.start();
        // new dataset node in graph to track this data
        modelRun = new Dataset(seed());
        modelRun.setWarParameters(new DefaultWarParams().getWarParams());
//        Neo4jSessionFactory.getInstance().getNeo4jSession().save(modelRun, 0);
        dataYear = TimelineQueries.getYearFromIntVal(fromYear);
        weeksThisYear = dataYear.getWeeksThisYear();
        dateIndex = TimelineQueries.getFirstWeek(dataYear).getStepNumber();
        territories = TerritoryQueries.getStateTerritories(fromYear, this);
        territories.values().forEach(Territory::loadTileFacts);
        territories.values().forEach(Territory::initiateGraph);
        // allTheStates gets loaded inside the territories query stream and their institution data gets loaded, too.
        // AFTER that, we add water territories so that no new Polity() is made for them
        territories.putAll(TerritoryQueries.getWaterTerritories());
        colorGradients = allTheStates.stream().map(Polity::getPolColor).toArray(Color[]::new);

        RED_PUNISH = modelRun.getWarParameters().get("RED_PUNISH");
        RED_COERCE = modelRun.getWarParameters().get("RED_COERCE");
        RED_DEFEAT = modelRun.getWarParameters().get("RED_DEFEAT");
        RED_CONQUER = modelRun.getWarParameters().get("RED_CONQUER");
        BLUE_PUNISH = modelRun.getWarParameters().get("BLUE_PUNISH");
        BLUE_COERCE = modelRun.getWarParameters().get("BLUE_COERCE");
        BLUE_DEFEAT = modelRun.getWarParameters().get("BLUE_DEFEAT");
        BLUE_CONQUER = modelRun.getWarParameters().get("BLUE_CONQUER");
        THREAT_PUNISH = modelRun.getWarParameters().get("THREAT_PUNISH");
        THREAT_COERCE = modelRun.getWarParameters().get("THREAT_COERCE");
        THREAT_DEFEAT = modelRun.getWarParameters().get("THREAT_DEFEAT");
        THREAT_CONQUER = modelRun.getWarParameters().get("THREAT_CONQUER");
        RISK_PUNISH = modelRun.getWarParameters().get("RISK_PUNISH");
        RISK_COERCE = modelRun.getWarParameters().get("RISK_COERCE");
        RISK_DEFEAT = modelRun.getWarParameters().get("RISK_DEFEAT");
        RISK_CONQUER = modelRun.getWarParameters().get("RISK_CONQUER");

        // set model run parameters
        stabilityDuration = 80 * 52;
        initializationPeriod = 10 * 52;
        globalWarLikelihood = DataQueries.getWarAndConflictAverages().get("onset"); // 0.185312622886355 mean wars per week
        globalHostility = new DataTrend(stabilityDuration);
        institutionInfluence = 0.0001;
        warCountHistory = new DataQueries().getWeeklyWarHistory();
//       warCostFactor = 0.25;                           // Not used
        allTheStates.stream().forEach(s -> schedule.scheduleRepeating(s));
        allTheLeaders.stream().forEach(l -> schedule.scheduleRepeating(l));
        tiles.values().forEach(tile -> schedule.scheduleRepeating(tile));

        // TODO: Add Data Collection to the Schedule
        ProbabilisticCausality warCause = new ProbabilisticCausality(this);
        Stoppable externalWarStopper = schedule.scheduleRepeating(warCause);
        warCause.setStopper(externalWarStopper);

        Steppable world = new Steppable() {
            @Override
            public void step(SimState simState) {
                WorldOrder worldOrder = (WorldOrder) simState;
                /**
                 *
                 */
                // Record the global probability of war whether it's prescribed or calculated
                globalHostility.add(globalWarLikelihood);
                long stepNo = getStepNumber();
                // TODO: set this equal the current step count minus the last week of the current year.
                if (worldOrder.getStepNumber() - dataYear.getLast() == 0) {
                    dataYear = dataYear.getNextYear();
                    territories.values().stream().filter(t -> t.getMapKey() == "World Oceans")
                            .forEach(Territory::updateTotals);
                }
                // End the simulation after (about) 400 years
                if (stepNo == overallDuration) {
                    externalWarStopper.stop();
                }
                // End the simulation if the global probability of war is stagnate or stable at zero
                if (globalWarLikelihood <= 0) {
                    System.exit(0);
                }
                // End the simulation if hostility gets stuck in a local minimum/maximum
                if (globalHostility.average() == globalWarLikelihood && stepNo > stabilityDuration) {
                    System.exit(0);
                }
                // Count Procs
                Map<String, Long> procCounts =
                        allTheProcs.stream().collect(Collectors.groupingBy(e -> e.getName(), Collectors.counting()));
                Map<String, Long> instCounts =
                        allTheInstitutions.stream().collect(Collectors.groupingBy(e -> e.getName(), Collectors.counting()));

                System.out.println(procCounts  + " : " + instCounts + " : " + globalWarLikelihood);

            }
        };
        schedule.scheduleRepeating(world);
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

    public static int getFromYear() {return fromYear;}

    public static int getUntilYear() {return untilYear;}

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

//    public double getWarCostFactor() {
//        return warCostFactor;
//    }

    public double getGlobalWarLikelihood() {
        return globalWarLikelihood;
    }

    public void setGlobalWarLikelihood(double l) {
        globalWarLikelihood = l;
    }

    public void updateGlobalWarLikelihood(double effect) {
        globalWarLikelihood += effect;
    }

    public List<State> getAllTheStates() {
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

    public Map<Long, Tile> getTiles() {
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
        WorldOrder.institutionInfluence = institutionInfluence;
    }

    public static Set<Institution> getAllTheInstitutions() {
        return allTheInstitutions;
    }

    public void addInstitution(Institution i) {
        allTheInstitutions.add(i);
    }

    public void removeInstitution(Institution i) {
        allTheInstitutions.remove(i);
    }

    public long getInitializationPeriod() {
        return initializationPeriod;
    }

    public double getRED_PUNISH() {
        return RED_PUNISH;
    }

    public double getRED_COERCE() {
        return RED_COERCE;
    }

    public double getRED_DEFEAT() {
        return RED_DEFEAT;
    }

    public double getRED_CONQUER() {
        return RED_CONQUER;
    }

    public double getBLUE_PUNISH() {
        return BLUE_PUNISH;
    }

    public double getBLUE_COERCE() {
        return BLUE_COERCE;
    }

    public double getBLUE_DEFEAT() {
        return BLUE_DEFEAT;
    }

    public double getTHREAT_CONQUER() {
        return THREAT_CONQUER;
    }

    public double getBLUE_CONQUER() {
        return BLUE_CONQUER;
    }

    public double getTHREAT_PUNISH() {
        return THREAT_PUNISH;
    }

    public double getTHREAT_COERCE() {
        return THREAT_COERCE;
    }

    public double getTHREAT_DEFEAT() {
        return THREAT_DEFEAT;
    }

    public double getRISK_PUNISH() {
        return RISK_PUNISH;
    }

    public double getRISK_COERCE() {
        return RISK_COERCE;
    }

    public double getRISK_DEFEAT() {
        return RISK_DEFEAT;
    }

    public double getRISK_CONQUER() {
        return RISK_CONQUER;
    }
}
