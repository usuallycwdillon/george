package edu.gmu.css.worldOrder;

import com.uber.h3core.H3Core;
import edu.gmu.css.App;
//import edu.gmu.css.agents.PeaceProcess;
//import edu.gmu.css.agents.State;
import edu.gmu.css.agents.Tile;
import org.neo4j.ogm.config.Configuration;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.session.SessionFactory;
import sim.engine.SimState;
import sim.engine.Steppable;


import java.io.IOException;
import java.util.*;

public class WorldOrder extends SimState {
    /**
     *
     * @param seed
     */
    // The simulation singleton self-manifest
    public WorldOrder(long seed) {
        super(seed);
    }

    // Initiate Services
    public static H3Core h3;
    private SessionFactory sessionFactory;

    // Initialize the Environment
//    public Set<State> allTheStates = new HashSet<>();
//    public Set<War> allTheWars = new HashSet<>();
//    public Set<PeaceProcess> allThePeaceProcs = new HashSet<>();
    public static Map<String, Set<String>> worldHexMap = new HashMap();


    // The stabilityDuration is the number of weeks with no change in globalWarLikelihood before the system is "stable"
    public int stabilityDuration = 25 * 52;                             // 25  years
//    public History globalHostility = new History(stabilityDuration);    // how far back to look for stability; not simulation Run time.
    public double warCostFactor = 0.10;                                 // The maximum % GDP that any one war can cost
    public double globalWarLikelihood = 0.50;


    public void start() {
        super.start();

        // TODO: Add calls to clear the primary elements: system, globe, Bags/Sets, etc.

        // TODO: Make sure the graphdb is presesnt and has tiles, wars and other COW-like things.
        // Create the Neo4j OGM mapper and configure connection to the database
        Configuration configuration = new Configuration.Builder()
                .uri("bolt://localhost")
                .credentials("neo4j", "george")
                .build();
        sessionFactory = new SessionFactory(configuration, "edu.gmu.css.agents");
        Session session = sessionFactory.openSession();

        // TODO: create the spatial environment and have have each Tile find it's neighbors.
        // Create the h3 instance
        try {
            h3 = H3Core.newInstance();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // TODO: Setup the global system of states

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
