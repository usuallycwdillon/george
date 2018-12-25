package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.worldOrder.Institution;
import edu.gmu.css.worldOrder.Trade;
import sim.engine.SimState;
import sim.engine.Steppable;

public class TradeProcess extends Process {

    private Domain domain = Domain.TRADE;

    public TradeProcess () {    }


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
        return new Trade();
    }



}
