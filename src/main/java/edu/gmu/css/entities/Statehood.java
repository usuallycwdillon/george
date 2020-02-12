package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import sim.engine.SimState;

public class Statehood extends Institution {

    public Statehood() {
        name = "Statehood";
        cost = new Resources.ResourceBuilder().build();
    }

    public Statehood(Process process, long s) {
        name = "Statehood";
        from = s;
        cause = process;
        cost = new Resources.ResourceBuilder().build();
    }

    @Override
    public void step(SimState simState) {

    }

}
