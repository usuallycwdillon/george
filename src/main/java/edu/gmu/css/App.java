package edu.gmu.css;

import com.uber.h3core.H3Core;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.session.SessionFactory;

import static sim.engine.SimState.doLoop;

/**
 * Generator for Experiments on the Order and Relations in a Global Environment (GEORGE) using the Multi-Agent
 * Simulation On Networks (MASON). ...also, there's this: https://youtu.be/ArNz8U7tgU4?t=10
 *
 * In partial fulfillment of requirements for award of Doctor of Philosophy in Computational Social Science
 * from the Graduate College of Sciences, George Mason University, Fairfax, Virginia.
 *
 */
public class App {
    /**
     *
     * @param args
     */
    public static void main( String[] args ) {
        doLoop(WorldOrder.class, args);
        System.exit(0);
    }
}
