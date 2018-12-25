package edu.gmu.css.worldOrder;

import edu.gmu.css.entities.Polity;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.List;

public abstract class Institution implements Steppable, Serializable {

    private int cost;               // A total cost that must be met by all members in order to survive;
    private double influence;       // A coefficient for each member's benefit
    private long creationStep;      // The step number during which the institution formed

    private List<Polity> members;

    public Institution() {

    }

    public Institution(SimState simState) {

    }

    public void collectCosts() {
        int size = members.size();
        for (Polity p : members) {

        }

    }


}
