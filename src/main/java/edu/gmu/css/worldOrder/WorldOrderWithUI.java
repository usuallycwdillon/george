package edu.gmu.css.worldOrder;

import sim.display.Console;
import sim.display.GUIState;
import sim.engine.SimState;

import java.util.Objects;

public class WorldOrderWithUI extends GUIState {
    /**
     *
     * @param
     *
     */
    // The simulation singleton self-manifest
    public WorldOrderWithUI() {
        super(new WorldOrder(System.currentTimeMillis()));
    }

    public WorldOrderWithUI(SimState state) {
        super(state);
    }

    public static void main(String[] args) {
        WorldOrderWithUI vid = new WorldOrderWithUI();
        Console c = new Console(vid);
        c.setVisible(true);
    }

    public static String getName() {
        return "World Order";
    }

    @Override
    public Object getSimulationInspectedObject() {
        return state;
    }



}
