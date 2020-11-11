package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Trade;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Stoppable;

public class TradeProcess extends Process {

    private final Domain domain = Domain.TRADE;
    private Trade trade;

    public TradeProcess () {    }



    public void stop() {
        for (ProcessDisposition p : processParticipantLinks) {
            p.getOwner().getProcessList().remove(this);
        }
        processParticipantLinks = null;
    }


    public void setStatus() {

    }

    public void setFiat() {

    }

    @Override
    public void step(SimState simState) {

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

//    public Trade createTrade(WorldOrder wo) {
//        WorldOrder worldOrder = wo;
//        long step = worldOrder.getStepNumber();
//        double influence = worldOrder.getInstitutionInfluence();
//        Stoppable stoppable;
//        trade = new Trade(this, step);
//        for (ProcessDisposition d : processParticipantLinks) {
//
//            Participation p = new Participation(d, trade, step);
//            trade.addParticipation(p);
//            d.getOwner().addInstitution(p);
//        }
//        stoppable = worldOrder.schedule.scheduleRepeating(trade);
//        trade.setStopper(stoppable);
//        return trade;
//    }


}
