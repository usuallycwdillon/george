package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Diplomacy;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;

public class DiplomacyProcess extends Process {

    private Domain domain = Domain.DIPLOMACY;


    public DiplomacyProcess() {
    }

    public void setStatus() {

    }

    @Override
    public void setFiat() {

    }

    @Override
    public void step(SimState simState) {
        worldOrder = (WorldOrder) simState;
        int count = 0;

        int statusSum = 0;
        for (int i : status) {
            statusSum = +i;
        }

        switch (statusSum) {
            case 2:

                return;
            case 3:

                return;
            case 4:

                return;
            case 5:

                return;
            case 6:

                return;
            case 7:

                return;
            case 8:

                return;
            case 9:

                return;
            case 10:

                return;
            case 11:

                return;
            case 14:

                return;
            case 15:

                return;
        }
    }


    public Institution createInstitution() {
        return new Diplomacy();
    }
}
