package edu.gmu.css.worldOrder;

import edu.gmu.css.agents.*;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Annum;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.entities.*;
import edu.gmu.css.queries.DataQueries;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.queries.TerritoryQueries;

import edu.gmu.css.service.Neo4jSessionFactory;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;
import sim.util.distribution.Poisson;

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
        worldOrder.nameThread();
        for (int job = 0; job < jobs; job++) {
            worldOrder.setJob(job);
            worldOrder.start();
            do
                if (!worldOrder.schedule.step(worldOrder))
                    break;
            while(worldOrder.schedule.getSteps() < 52 * 300);
            worldOrder.finish();
        }
        System.exit(0);
    }


    // The simulation singleton self-manifest
    public WorldOrder(long seed) {
        super(seed);
        // Some default values to boostrap some values, globally
    }

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
    public static boolean DEBUG = true;
    public static boolean NEW_BASELINE = false;

    private static int startYear = 1816; // Choices are 1816, 1880, 1914, 1938, 1945, 1994
    private static int untilYear = 1820; // Depending on how sloppy you're willing to be, can be just below next year
    public static int getStartYear() {return startYear;}
    public static int getUntilYear() {return untilYear;}

    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    // and globalHostility is the collection of that data.
    public static int stabilityDuration;
    public static long initializationPeriod;
    public static DataTrend globalHostility;
    public static double warCostFactor;       // The maximum % GDP that any one war can cost
    public static double globalWarLikelihood; // based on 136 wars in 10,017 weeks
    public static double institutionInfluence;

    public static Poisson poisson;

    public static List<State> allTheStates = new ArrayList<>();
    public static Set<War> allTheWars = new HashSet<>();
    public static Set<Process> allTheProcs = new HashSet<>();
    public static Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public static Set<WarProcess> allTheWarProcs = new HashSet<>();
    public static Map<Long, Tile> tiles = new HashMap<>();
    public static Map<String, Territory> territories = new HashMap<>();
    public static Dataset spatialDataset;
    public static Map<Long, Integer> warCountHistory = new HashMap<>();
    public static Set<Institution> allTheInstitutions = new HashSet<>();

    // Some parameters for war strategy thresholds.
    // RED is the opposing force size while BLUE is own force size
    // THREAT is the opposing military expenditures while RISK is own military expenditures
    // Goals for each conflict are PUNISH, COERCE, DEFEAT, or CONQUER
    // A polity uses these coefficients to plan their offensive war strategies
    public static double RED_PUNISH = 0.2;
    public static double RED_COERCE = 0.33;
    public static double RED_DEFEAT = 0.5;
    public static double RED_CONQUER = 1.0;
    public static double BLUE_PUNISH = 0.1;
    public static double BLUE_COERCE = 0.1;
    public static double BLUE_DEFEAT = 0.66;
    public static double BLUE_CONQUER = 1.0;
    public static double THREAT_PUNISH = 0.1;
    public static double THREAT_COERCE = 0.2;
    public static double THREAT_DEFEAT = 0.33;
    public static double THREAT_CONQUER = 0.5;
    public static double RISK_PUNISH = 0.01;
    public static double RISK_COERCE = 0.01;
    public static double RISK_DEFEAT = 0.01;
    public static double RISK_CONQUER = 0.01;

    public static Dataset modelRun;
    private static Long seed;
    public static Annum annum;


    public void start() {
        super.start();
        // new dataset node in graph to track this data
        modelRun = new Dataset(seed());
        Neo4jSessionFactory.getInstance().getNeo4jSession().save(modelRun, 0);
        annum = new Annum();
        schedule.scheduleRepeating(annum);

        // set model parameters
        stabilityDuration = 80 * 52;
        initializationPeriod = 10 * 52;
        //  warCostFactor = 0.25;                               // Not used
        globalWarLikelihood = 0.185312622886355;
        globalHostility = new DataTrend(stabilityDuration);
        institutionInfluence = 0.001;
        warCountHistory = new DataQueries().getWeeklyWarsCount();

        // Import territories from WorldOrderData
        territories = TerritoryQueries.getStateTerritories(startYear);
        for (String t : territories.keySet()) {
            String mapKey = territories.get(t).getMapKey();
            Territory territory = TerritoryQueries.loadWithRelations(mapKey);
            territories.put(t, territory);
        }

        // add water territories AFTER creating the list of states because
        territories.putAll(TerritoryQueries.getWaterTerritories());

        // Each territory is controlled by a Polity, which may be a State
        // TODO: Create Polity Coordination objects to represent underdeveloped & unrecognized polities; until then,
        //       they get a placeholder polity object.
        for (String k : territories.keySet()) {
            // if there isn't a state/polity assigned, double-check whether there should be one, otherwise make another
            Territory t = territories.get(k);
            if (t.getGovernment() == null) {
                System.out.println(t.getMapKey() + " is not a known state government; creating a blank polity.");
                Polity p = new Polity();
                p.setTerritory(t);
                t.setGovernment(p, getStepNumber());
            } else {
                if (t.getGovernment().getClass()==State.class) {
                    State s = (State) t.getGovernment();
                    s.setTerritory(t);
                    allTheStates.add(s);
                }
            }
        }

        if (NEW_BASELINE) {
            territories.values().forEach(Territory::loadBaselinePopulation);
        }

        allTheStates.forEach(p -> p.loadInstitutionData(startYear));

        for (State s : allTheStates) {
            Leadership l = new Leadership(this);
            schedule.scheduleRepeating(l);
            s.setLeadership(l);
            l.setPolity(s);
            // update military resources or invent some if there aren't any
            s.setResources(StateQueries.getMilResources(s, startYear));
            if (s.getResources()==null) {
                // make something up
                s.setResources(new Resources.ResourceBuilder().pax(10000).treasury(100000.0).build());
                System.out.println("I made up some military resources for " + s.getName());
            }
            if (!s.findPolityData(startYear)) {
                s.setNeutralPolityFact();
                System.out.println("No polity fact for " + s.getName());
            }
            s.getTerritory().initiateGraph();
            schedule.scheduleRepeating(s);
        }

        // TODO: Add Data Collection to the Schedule

        tiles.values().forEach(tile -> schedule.scheduleRepeating(tile));

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
                if(annum.getWeeksThisYear() == 0) {
                    territories.values().forEach(Territory::updateTotals);
                }

//                if (stepNo == stabilityDuration) {
//                    externalWarStopper.stop();
//                }

                // End the simulation if the global probability of war is stagnate or stable at zero
                if (globalWarLikelihood <= 0) {
                    System.exit(0);
                }
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

    public void updatePoisson() {
        poisson = new Poisson(globalWarLikelihood, random);
    }

    public WorldOrder getWorldOrderSimState() {
        return this;
    }

    public long getStepNumber() {
        return this.schedule.getSteps();
    }

    public int getStabilityDuration() {
        return stabilityDuration;
    }

    public static Dataset getModelRun() {
        return modelRun;
    }

    public DataTrend getGlobalHostility() {
        return globalHostility;
    }

    public double getWarCostFactor() {
        return warCostFactor;
    }

    public double getGlobalWarLikelihood() {
        return globalWarLikelihood;
    }

    public void setGlobalWarLikelihood(double effect) {
        globalWarLikelihood += effect;
    }

    public static List<State> getAllTheStates() {
        return allTheStates;
    }

    public static Set<War> getAllTheWars() {
        return allTheWars;
    }

    public static Set<PeaceProcess> getAllThePeaceProcs() {
        return allThePeaceProcs;
    }

    public static Set<WarProcess> getAllTheWarProcs() {
        return allTheWarProcs;
    }

    public static Set<Process> getAllTheProcs() {
        return allTheProcs;
    }

    public void addProc(Process p) {
        allTheProcs.add(p);
    }

    public static Map<Long, Tile> getTiles() {
        return tiles;
    }

    public static Map<String, Territory> getTerritories() {
        return territories;
    }

    public static Dataset getSpatialDataset() {
        return spatialDataset;
    }

    public static double getInstitutionInfluence() {
        return institutionInfluence;
    }

    public static void setInstitutionInfluence(double institutionInfluence) {
        WorldOrder.institutionInfluence = institutionInfluence;
    }

    public static Set<Institution> getAllTheInstitutions() {
        return allTheInstitutions;
    }

    public static void addInstitution(Institution i) {
        allTheInstitutions.add(i);
    }

    public static void removeInstitution(Institution i) {
        allTheInstitutions.remove(i);
    }

    public static long getInitializationPeriod() {
        return initializationPeriod;
    }

}
