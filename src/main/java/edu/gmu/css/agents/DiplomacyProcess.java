package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.worldOrder.Diplomacy;
import edu.gmu.css.worldOrder.Institution;
import sim.engine.SimState;

public class DiplomacyProcess extends Process {

    private Domain domain = Domain.DIPLOMACY;


    public DiplomacyProcess() {
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
        return new Diplomacy();
    }
}
