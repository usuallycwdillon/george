package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Statehood;
import edu.gmu.css.relations.ProcessDisposition;
import sim.engine.SimState;

public class StatehoodProcess extends Process {

    private final Domain domain = Domain.STATEHOOD;
    private Statehood statehood;

    public StatehoodProcess() {  }

    public StatehoodProcess(Polity owner, Polity target) {

    }

//    @Override
    public void setStatus() {

    }

    @Override
    public void setFiat() {

    }

    public void stop() {
//        worldOrder.allTheState.remove(this);
        for (ProcessDisposition p : processParticipantLinks) {
            p.getOwner().getProcessList().remove(this);
        }
        processParticipantLinks = null;
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

//    public Statehood createInstitution(WorldOrder wo) {
//        WorldOrder worldOrder = wo;
//        long step = worldOrder.getStepNumber();
//        double influence = worldOrder.getInstitutionInfluence();
//        Stoppable stoppable;
//        statehood = new Statehood(this, step);
//        for (ProcessDisposition d : processParticipantLinks) {
//            Participation p = new Participation(d, statehood, step);
//            statehood.addParticipation(p);
//            d.getOwner().addInstitution(p);
//        }
//        stoppable = worldOrder.schedule.scheduleRepeating(statehood);
//        statehood.setStopper(stoppable);
//        return statehood;
//    }

}
