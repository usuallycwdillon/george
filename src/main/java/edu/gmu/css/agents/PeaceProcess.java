package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.worldOrder.Institution;
import edu.gmu.css.worldOrder.Peace;
import org.neo4j.register.Register;
import sim.engine.SimState;
import sim.engine.Steppable;

public class PeaceProcess extends Process {

    private Domain domain = Domain.PEACE;

    public PeaceProcess() {
    }


    @Override
    public void setStatus() {

    }

    @Override
    public void setFiat() {

    }

    @Override
    public void step(SimState simState) {

    }

    public Institution createInstitution() {
        return new Peace();
    }

}
