package edu.gmu.css.worldOrder;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.*;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.DefaultWarParams;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.*;
import edu.gmu.css.queries.DataQueries;
import edu.gmu.css.queries.TerritoryQueries;
import edu.gmu.css.queries.TimelineQueries;
//import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.service.*;
import org.apache.commons.math3.distribution.LogNormalDistribution;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;
import sim.util.distribution.Gamma;
import sim.util.distribution.Poisson;
import java.awt.*;
import java.util.*;
import java.util.List;

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
        seed = System.currentTimeMillis();
        SimState worldOrder = new WorldOrder(seed, 1816);
        for (int job = 0; job < jobs; job++) {
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
    public static Poisson poisson;
    public static Gamma gamma;
    public static LogNormalDistribution lognormal;
    private static Long seed;
    public static Dataset modelRun;
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


    /**
     * Some parameters for war strategy thresholds.
     * RED is the opposing force size while BLUE is own force size
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
        overallDuration = 26096;    // about 500 years
        stabilityDuration = 10439;  // about 200 years
        initializationPeriod = 52.0;
        globalWarLikelihood = DataQueries.getWarAndConflictAverages().get("onset");
        globalHostility = new DataTrend(stabilityDuration);
        institutionInfluence = 0.000001;
        foRelMultiplier = 0.10;
        fromYear = fy;
        untilYear = uy;
        allTheStates.clear();
        dataYear = TimelineQueries.getYearFromIntVal(fromYear);
        weeksThisYear = dataYear.getWeeksThisYear();
        dateIndex = dataYear.getBegan();
        ruralTiles = 0;
        long first = System.nanoTime();
//        territories = TerritoryQueries.getStateTerritories(fromYear, this);
        tiles = new TileServiceImpl().loadAll(fromYear);
        territories = new TerritoryServiceImpl().getStateTerritories(fromYear, this);
        for(Territory t : territories.values()) {
//            t.setTileLinks(new TileServiceImpl().loadIncludedTiles(t));
            State s = new StateServiceImpl().findStateForTerritory(t);
            t.setPolity(s, 0L);
            CommonWeal cw = new CommonWealServiceImpl().findTerritoryCommonWeal(t);
            cw = new CommonWealServiceImpl().find(cw.getId());
            t.setCommonWeal(cw);
            Leadership l = cw.getLeadership();
            l.setCommonWeal(cw);
            l.setPolity(s);
            cw.loadPersonMap();
            s.setLeadership(l);
            s.setTerritory(t);
            Resources r = new Resources.ResourceBuilder()
                    .pax(((MilPerFact)(new FactServiceImpl().getMilPerFact(getDataYear().getName(), s))).getValue())
                    .treasury(((MilExFact)(new FactServiceImpl().getMilExFact(getDataYear().getName(), s))).getValue())
                    .build();
            s.setResources(r);
            s.setSecurityStrategy(r);
            s.setEconomicPolicy(new EconomicPolicy(0.6, 0.4, (
                    (TaxRateFact) (new FactServiceImpl().getInitialTaxRate(s, fromYear))).getValue() * 1.1));
            s.setWarParams(getModelRun().getWarParameters());
            allTheStates.add(s);
            allTheLeaders.add(l);
        }
        long second = System.nanoTime();

        System.out.println("1st, territories loaded in  " +
                (second - first)/1000000000.0);
//        territories.values().spliterator().forEachRemaining(Territory::loadCommonWeal);
//        long third = System.nanoTime();
//        System.out.println("2nd, common weals loaded with leadership, leaders, people in " +
//                (third - second)/1000000000.0);
        allTheStates.stream().forEach(s -> s.loadInstitutionData(fy,this));
//        long fourth = System.nanoTime();
//        System.out.println("3rd, Institions loaded in  " +
//                (fourth - third)/1000000000.0);
        territories.putAll(new TerritoryServiceImpl().loadWaterTerritories(fromYear));
//        long sixth = System.nanoTime();
//        System.out.println("4th, Water loaded after " +
//                (sixth - fourth)/1000000000.0);
        colorGradients = allTheStates.stream().map(Polity::getPolColor).toArray(Color[]::new);
        System.out.println("All told, it took " + (System.nanoTime() - startTime) / 1000000000.0 + " to pull data from the WOKG. ");
        return true;
    }


    public void start() {
        super.start();
        long startstart = System.nanoTime();
        // new dataset node in graph to track this data
        // save this model run to the database for later
//        new DatasetServiceImpl().createOrUpdate(modelRun);
        // Put it all the steppables on the schedule
        for (State s : allTheStates) {
            for (Tile tile : s.getTerritory().getTileLinks()) {
//                if(tile.getAddressYear().equals("840d837ffffffff.1816")) {
//                    System.out.println(tile.toString());
//                }
                tiles.put(tile.getAddressYear(), tile);
                schedule.scheduleRepeating(EPOCH,0, tile,1);
                tile.findGrid();
                if (tile.getUrbanPop() == 0.0 ) ruralTiles++;
            }
            s.establishEconomicPolicy(this);
            schedule.scheduleRepeating(s.getLeadership(), 1,1);
            schedule.scheduleRepeating(s, 2, 1);
//            schedule.scheduleRepeating(s.getLeadership());
//            for (BorderFact bf : s.getBordersWith()) {
//                schedule.scheduleRepeating(bf.getBorder());
//            }
//            for (AllianceParticipationFact ap : s.getAlliances()) {
//            }
        }

        for (Territory t : territories.values()) {
                t.updateTotals();
                // schedule after the tile and every half-year after that
                schedule.scheduleRepeating(t, 1, 26);
        }

        // TODO: Add Data Collection to the Schedule
        conflictCause = new ProbabilisticCausality(this);
        externalWarStopper = schedule.scheduleRepeating(initializationPeriod, conflictCause);
        conflictCause.setStopper(externalWarStopper);

        World world = new World();
        schedule.scheduleRepeating(world);

        long endstart = System.nanoTime();
        System.out.println("Start proc took " + (endstart - startstart)/1000000000);
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

    public long getDateIndex() {
        return dateIndex;
    }

    public void setDateIndex(long dateIndex) {
        this.dateIndex = dateIndex;
    }

    public void setAllTheStates(List<State> allTheStates) {
        this.allTheStates = allTheStates;
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
