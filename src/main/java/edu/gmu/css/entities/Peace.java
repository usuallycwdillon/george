package edu.gmu.css.entities;

import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import edu.gmu.css.agents.Process;

public class Peace extends Institution {

    public Peace() {
    }

    public Peace(Process p) {
        name = "Peace";
    }

    @Override
    public void step(SimState simState) {
        double influence = worldOrder.getInstitutionInfluence();
        WorldOrder worldOrder = (WorldOrder) simState;
        worldOrder.setGlobalWarLikelihood(-1 * influence);
        if (stopped) {
            stopper.stop();
            return;
        }
    }
}
