package edu.gmu.css.entities;

import edu.gmu.css.data.World;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import edu.gmu.css.agents.Process;

public class Peace extends Institution {

    public Peace() {
    }

    public Peace(Process p, long s) {
        name = "Peace";
        from = s;
        cause = p;
        cost = new Resources.ResourceBuilder().build();
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        double influence = worldOrder.getInstitutionInfluence();
        worldOrder.setGlobalWarLikelihood(-1 * influence);
        if (stopped) {
            stopper.stop();
            return;
        }
    }
}
