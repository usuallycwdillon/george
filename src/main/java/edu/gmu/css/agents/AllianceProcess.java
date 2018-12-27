package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.worldOrder.Alliance;
import edu.gmu.css.worldOrder.Institution;
import sim.engine.SimState;

public class AllianceProcess extends Process {

    private Domain domain = Domain.ALLIANCE;

    public AllianceProcess() {  }

    public AllianceProcess(Polity owner, Polity target) {

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

    @Override
    public Institution createInstitution() {
        return new Alliance();
    }
}
