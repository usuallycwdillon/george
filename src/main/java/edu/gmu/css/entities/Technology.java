package edu.gmu.css.entities;

import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;

public class Technology implements Serializable, Steppable {

    public Technology() {

    }

    @Override
    public void step(SimState simState) {
        WorldOrder wo = (WorldOrder) simState;
        wo.incrementMarchingPace();
    }

}
