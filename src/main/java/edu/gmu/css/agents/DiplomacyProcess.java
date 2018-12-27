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
        setFiat();
        switch (fiat) {
            case 'x':
                // initial state; a challenge exists
                // owner assigns resources and prepares to attack
                return;
            case 'E':
                // target recognizes need but undertakes no action; owner does not attack
                // owner assigns resources and prepares to attack
                return;
            case 'X':
                // initial state; a challenge exists
                // owner assigns resources and prepares to attack
                return;
            case 'W':
                // initial state; a challenge exists
                // owner assigns resources and prepares to attack
                return;
            case 'Z':
                // initial state; a challenge exists
                // owner assigns resources and prepares to attack
                return;
            case 'A':
                // initial state; a challenge exists
                // owner assigns resources and prepares to attack
                return;
        }

    }

    public Institution createInstitution() {
        return new Diplomacy();
    }
}
