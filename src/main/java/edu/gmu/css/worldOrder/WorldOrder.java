package edu.gmu.css.worldOrder;

import com.uber.h3core.H3Core;
import edu.gmu.css.App;
//import edu.gmu.css.agents.PeaceProcess;
//import edu.gmu.css.entities.State;
import edu.gmu.css.agents.*;
import edu.gmu.css.agents.Process;
import edu.gmu.css.entities.*;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.service.TerritoryServiceImpl;
import lombok.ToString;
import org.neo4j.ogm.config.Configuration;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;
import org.neo4j.ogm.model.Result;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.session.SessionFactory;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;


import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

public class WorldOrder extends SimState {
    /**
     *
     * @param seed
     *
     */
    // The simulation singleton self-manifest
    public WorldOrder(long seed) {
        super(seed);
        // Some default values to boostrap some values, globally
    }

    public static Double EFFECT = 0.001;

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
    public static double RISK_PUNIISH = 0.01;
    public static double RISK_COERCE = 0.01;
    public static double RISK_DEFEAT = 0.01;
    public static double RISK_CONQUER = 0.01;

    public static Dataset modelRun;
//    public static TerminalAgent terminalAgent = new TerminalAgent();

    /**
     * Select a year for baseline data and initialize the global environment with empirical descriptions of States,
     * States have a territory, treasury, securityStrategy, economicStrategy, institutions, processes;
     * A territory represents a time-boxed collection of tiles and track the sums of tile attributes;
     * Tiles contain a population, natural resources, economic production;
     *
     */
    private static int startYear = 1816; // Choices are 1816, 1880, 1914, 1938, 1945, 1994
    public static int getStartYear() {return startYear;}

    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    public int stabilityDuration;
    public History globalHostility = new History(stabilityDuration);    // how far back to look for stability; not simulation Run time.
    public double warCostFactor;                                        // The maximum % GDP that any one war can cost
    public double globalWarLikelihood;

    public static List<State> allTheStates = new ArrayList<>();
    public static Set<War> allTheWars = new HashSet<>();
    public static Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public static Set<WarProcess> allTheWarProcs = new HashSet<>();
    public static List<Tile> tiles = new ArrayList<>();
    public static List<Territory> territories = new ArrayList<>();
    public static Dataset spatialDataset;

    public void start() {
        super.start();
        modelRun = new Dataset(seed());
        // Set initial parameters, at least for testing
        stabilityDuration = 25 * 52;
        warCostFactor = 0.10;
        globalWarLikelihood = 0.100;

        // TODO: Add calls to clear the primary elements: system, globe, Bags/Sets, etc.
        allTheStates.clear();
        territories.clear();


        // TODO: Make sure the graphdb is presesnt and has tiles, wars and other COW-like things.
        String datasetQuery = "MATCH (d:Dataset{name:\"world 1816\"}) RETURN d";

        Filter popFilter = new Filter("year", ComparisonOperator.EQUALS, startYear);
        territories.addAll(Neo4jSessionFactory.getInstance().getNeo4jSession().loadAll(Territory.class, popFilter, 1));
        territories.forEach(Territory::loadBaselinePopulation);

        for (Territory t : territories) {
            if (t.getGovernment(getStepNumber())==null) {
                System.out.println(t.getMapKey() + " doesn't have a government.");
            } else {
                State s = (State) t.getGovernment(getStepNumber());
                s.setTerritory(t);
                allTheStates.add(s);
            }
        }

        for (State s : allTheStates) {
            Leadership l = new Leadership();
            schedule.scheduleRepeating(l);
            s.setLeadership(l);
            s.setResources(StateQueries.getMilResources(s, startYear));
        }


        // TODO: Add Steppables to the Schedule
        for (Tile t : tiles) {
            schedule.scheduleRepeating(t);
        }

        Steppable historysMarch = new Steppable() {
            @Override
            public void step(SimState simState) {
                /**
                 *
                 */
                // Record the global probability of war whether it's prescribed or calculated
//              globalHostility.add(globalWarLikelihood);
                long stepNo = getStepNumber();
                if(stepNo % 52 == 0) {
                    for (Polity p : allTheStates) {
                        Territory t = p.getTerritory();
                        t.updateTotals();
                        System.out.println("At step number " + stepNo + " the population of " + t.getName() + " is "
                                + t.getPopulation());
                    }
                }
                double r = random.nextGaussian();
                if (r <= globalWarLikelihood) {
                    int numStates = allTheStates.size();
                    int instigator = random.nextInt(numStates);
                    int target = random.nextInt(numStates);
                    if (target != instigator) {
                        Polity p = allTheStates.get(instigator);
                        p.getLeadership().initiateWarProcess(allTheStates.get(target), simState);
                    }
                }


                // End the simulation if the global probability of war is stagnate or stable at zero
                if (globalWarLikelihood <= 0) {
                    System.exit(0);
                }
                if (globalHostility.average() == globalWarLikelihood) {
                    System.exit(0);
                }
            }
        };
        schedule.scheduleRepeating(historysMarch);

    }

    // Primary sequence of the simulation

    public WorldOrder getWorldOrderSimState() {
        return this;
    }


    public long getStepNumber() {
        return this.schedule.getSteps();
    }


    public int getStabilityDuration() {
        return this.stabilityDuration;
    }

    public static Dataset getModelRun() {
        return modelRun;
    }

    public History getGlobalHostility() {
        return globalHostility;
    }

    public double getWarCostFactor() {
        return warCostFactor;
    }

    public double getGlobalWarLikelihood() {
        return globalWarLikelihood;
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

    public static List<Tile> getTiles() {
        return tiles;
    }

    public static List<Territory> getTerritories() {
        return territories;
    }

    public static Dataset getSpatialDataset() {
        return spatialDataset;
    }
}
