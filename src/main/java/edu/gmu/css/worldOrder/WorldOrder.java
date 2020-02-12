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
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.InstitutionParticipation;
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

import static sim.engine.Schedule.MAXIMUM_INTEGER;

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
        setup();
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
    private static int fromYear; // Choices are 1816, 1880, 1914, 1938, 1945, 1994
    private static int untilYear; // Depending on how generic you're willing to be, can be just below next year
    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    // and globalHostility is the collection of that data.
    public static int overallDuration;
    public static int stabilityDuration;
    public static long initializationPeriod;
    public DataTrend globalHostility;
    public double globalWarLikelihood; // based on 136 wars in 10,017 weeks
    public double institutionInfluence;
    public static Poisson poisson;
    private static Long seed;
    public Dataset modelRun;
    public Year dataYear;
    public int weeksThisYear;
    public long dateIndex;
    public List<State> allTheStates = new ArrayList<>();
    public Color[] colorGradients;
    public List<Leadership> allTheLeaders = new ArrayList<>();
    public Map<String, Territory> territories;
    public Set<War> allTheWars = new HashSet<>();
    public Set<Process> allTheProcs = new HashSet<>();
    public Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public Set<WarProcess> allTheWarProcs = new HashSet<>();
    public Map<Long, Tile> tiles = new HashMap<>();
    public Dataset spatialDataset;
    public Map<Long, Integer> warCountHistory = new HashMap<>();
    public Set<Institution> allTheInstitutions = new HashSet<>();
    public boolean configChosen = false;
    public ProbabilisticCausality conflictCause;

    /**
     * Some parameters for war strategy thresholds.
     * RED is the opposing force size while BLUE is own force size
     * THREAT is the opposing military expenditures while RISK is own military expenditures
     * Goals for each conflict are PUNISH, COERCE, DEFEAT, or CONQUER
     * A polity uses these coefficients to plan their offensive war strategies
     * The four strategies roughly correspond to military activities: strike, show of force, swiftly defeat,
     * and win decisively
     */
    public boolean setup() {
        setup(1816,1818);
        return false;
    }

    public boolean setup(int fy) {
        setup(fy, fy + 2);
        return true;
    }

    public boolean setup(int fy, int uy) {
        // new dataset node in graph to track this data will be saved only if this run get started.
        fromYear = fy;
        untilYear = uy;
        allTheStates.clear();
        dataYear = TimelineQueries.getYearFromIntVal(fromYear);
        weeksThisYear = dataYear.getWeeksThisYear();
        dateIndex = TimelineQueries.getFirstWeek(dataYear).getStepNumber();
        territories = TerritoryQueries.getStateTerritories(fromYear, this);
        territories.values().forEach(Territory::loadTileFacts);
        territories.values().forEach(Territory::initiateGraph);
        // allTheStates gets loaded inside the territories query stream and their institution and leadership data gets
        // loaded, too. AFTER that, we add water territories so that no new Polity() is made for them.
        territories.putAll(TerritoryQueries.getWaterTerritories());
        colorGradients = allTheStates.stream().map(Polity::getPolColor).toArray(Color[]::new);

        // set model run parameters
        modelRun = new Dataset(seed());
        modelRun.setWarParameters(new DefaultWarParams().getWarParams());
        overallDuration = 500 * 52;
        stabilityDuration = 80 * 52;
        initializationPeriod = 10 * 52;
        globalWarLikelihood = DataQueries.getWarAndConflictAverages().get("onset");
        globalHostility = new DataTrend(stabilityDuration);
        institutionInfluence = 0.0001;

        return true;
    }


    public void start() {
        super.start();
        if (configChosen) {
            setup(fromYear, untilYear);
        } else {
            setup();
        }
        // new dataset node in graph to track this data
        // save this model run to the database for later analysis
//        Neo4jSessionFactory.getInstance().getNeo4jSession().save(modelRun, 0);

        // Put it all the steppables on the schedule
        for (State s : allTheStates) {
            schedule.scheduleRepeating(s);
            schedule.scheduleRepeating(s.getLeadership());
            for (InstitutionParticipation ip : s.getInstitutionList()) {
                schedule.scheduleRepeating(ip.getInstitution());
            }
            for (Inclusion i : s.getTerritory().getTileLinks()) {
                schedule.scheduleRepeating(i.getTile());
            }
        }

        // TODO: Add Data Collection to the Schedule
        conflictCause = new ProbabilisticCausality(this);
        Stoppable externalWarStopper = schedule.scheduleRepeating(conflictCause);
        conflictCause.setStopper(externalWarStopper);

        Steppable world = new Steppable() {
            /**
             *
             */
            @Override
            public void step(SimState simState) {
                WorldOrder worldOrder = (WorldOrder) simState;

                // Record the global probability of war whether it's prescribed or calculated
                globalHostility.add(globalWarLikelihood);
                long stepNo = getStepNumber();
                // TODO: set this equal the current step count minus the last week of the current year.
                if ((worldOrder.getStepNumber() + dataYear.getBegan() - dataYear.getLast()) == 0) {
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
        this.institutionInfluence = institutionInfluence;
    }

    public Set<Institution> getAllTheInstitutions() {
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

}
