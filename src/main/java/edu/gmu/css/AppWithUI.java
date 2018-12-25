package edu.gmu.css;

import edu.gmu.css.worldOrder.WorldOrder;
import edu.gmu.css.worldOrder.WorldOrderWithUI;

import static sim.engine.SimState.doLoop;

public class AppWithUI {
    public static void main( String[] args ) {
        doLoop(WorldOrderWithUI.class, args);
        System.exit(0);
    }

}
