package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Process;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class War extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private long id;
    @Property
    private Resources cost;          // Magnitude, cumulative for whole war, all sides

    @Relationship (type = "PARTICIPATE_IN", direction = "INCOMING")
    private Set<Polity> participants = new HashSet<>();

    public War() {
    }

    public War(Process process) {

    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        battle(worldOrder.random);


    }

    public Resources getCost() {
        return cost;
    }

    public Set<Polity> getParticipants() {
        return participants;
    }

    public void addParticipant(Polity participant) {
        this.participants.add(participant);
    }

    private void battle(MersenneTwisterFast mtf) {
        // Take a part of the total force as a loss; split the loss between the participants
        MTFApache random = new MTFApache(mtf);

    }

}
