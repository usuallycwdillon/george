package edu.gmu.css.entities;

import sim.engine.SimState;
import edu.gmu.css.agents.Process;

public class Peace extends Institution {

    public Peace() {
    }

    public Peace(Process process) {
        name = "Peace";
    }

    @Override
    public void step(SimState simState) {

        if (stopped) {
            stopper.stop();
            return;
        }
    }
}
