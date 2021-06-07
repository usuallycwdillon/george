package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Alliance;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;

public class AllianceProcess extends Process {

    private final Domain domain = Domain.ALLIANCE;
    private Alliance alliance;

    public AllianceProcess() {  }

    public AllianceProcess(Polity owner, Polity target) {
        name = "Alliance Process";
    }


    public void stop() {
        if (issue != null) issue.setProcess(null);
        for (ProcessDisposition p : processParticipantLinks) {
            p.getOwner().getProcessList().remove(this);
        }
        processParticipantLinks = null;
    }

    @Override
    public void setFiat() {

    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
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


//    public Alliance createAlliance(WorldOrder wo) {
//        WorldOrder worldOrder = wo;
//        Stoppable stoppable;
//        ended = worldOrder.getStepNumber();
//        alliance = new Alliance(this);
//        alliance.setStrength(0.50);
//        for (ProcessDisposition d : processParticipantLinks) {
//            AllianceParticipationFact p = new AllianceParticipationFact.FactBuilder().build();
//            alliance.addParticipations(p);
//            d.getOwner().addAllianceParticipationFact(p);
//        }
//        stoppable = worldOrder.schedule.scheduleRepeating(alliance);
//        alliance.setStopper(stoppable);
//        wo.allTheInstitutions.add(alliance);
//        return alliance;
//    }

}
