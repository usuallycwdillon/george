package edu.gmu.css.worldOrder;

import com.uber.h3core.H3Core;
import edu.gmu.css.App;
//import edu.gmu.css.agents.PeaceProcess;
//import edu.gmu.css.entities.State;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.*;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.service.TerritoryServiceImpl;
import org.neo4j.ogm.config.Configuration;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;
import org.neo4j.ogm.model.Result;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.session.SessionFactory;
import sim.engine.SimState;
import sim.engine.Steppable;


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
    }

    /**
     * Select a year for baseline data and initialize the global environment with empirical descriptions of States,
     * States have a territory, treasury, securityStrategy, economicStrategy, institutions, processes;
     * A territory represents a time-boxed collection of tiles and track the sums of tile attributes;
     * Tiles contain a population, natural resources, economic production;
     *
     */
    int startYear = 1816; // Choices are 1816, 1880, 1914, 1938, 1945, 1994



    public Set<State> allTheStates = new HashSet<>();
//    public Set<War> allTheWars = new HashSet<>();
//    public Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public static Collection<Tile> tiles;
    public static Collection<Territory> territories;
    public static Dataset spatialDataset;



    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    public int stabilityDuration;                             // 25  years
//    public History globalHostility = new History(stabilityDuration);    // how far back to look for stability; not simulation Run time.
    public double warCostFactor;                                 // The maximum % GDP that any one war can cost
    public double globalWarLikelihood;


    public void start() {
        super.start();
        // Set initial parameters, at least for testing
        stabilityDuration = 25 * 52;
        warCostFactor = 0.10;
        globalWarLikelihood = 0.00;

        // TODO: Add calls to clear the primary elements: system, globe, Bags/Sets, etc.
//        allTheStates.clear();
//        tiles.clear();
//        territories.clear();


        // TODO: Make sure the graphdb is presesnt and has tiles, wars and other COW-like things.
        String datasetQuery = "MATCH (d:Dataset{name:\"world 1816\"}) RETURN d";

        tiles = Neo4jSessionFactory.getInstance().getNeo4jSession().loadAll(Tile.class, 0);
        System.out.println("Loaded " + tiles.size() + " tile into the simulation.");

//        Filter popFilter = new Filter("year", ComparisonOperator.EQUALS, startYear);
//        territories = Neo4jSessionFactory.getInstance().getNeo4jSession().loadAll(Territory.class, popFilter);
//        territories.forEach(Territory::loadBaselinePopulation);

        // TODO: Setup the global system of states
        allTheStates = new StateQueries().getStates("Expanded State System", 1816);
        System.out.println(allTheStates.size());


        // TODO: Add Steppables to the Schedule

    }

    // Primary sequence of the simulation
    Steppable historysMarch = new Steppable() {
        @Override
        public void step(SimState simState) {
            /**
             *
             */
            // Record the global probability of war whether it's prescribed or calculated
//            globalHostility.add(globalWarLikelihood);


            // End the simulation if the global probability of war is stagnate or stable at zero
            if (globalWarLikelihood <= 0) {
                System.exit(0);
            }
//            if (globalHostility.average() == globalWarLikelihood) {
//                System.exit(0);
//            }
        }
    };


    public WorldOrder getWorldOrderSimState() {
        return this;
    }


    public long getStepNumber() {
        return this.schedule.getSteps();
    }


    public int getStabilityDuration() {
        return this.stabilityDuration;
    }



}
