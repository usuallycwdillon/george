package edu.gmu.css.worldOrder;

import edu.gmu.css.entities.State;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class War extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private int cost;          // Magnitude, cumulative for whole war, all sides

    @Relationship (type = "PARTICIPATE_IN", direction = "INCOMING")
    private Set<State> participants = new HashSet<>();

    public War() {
    }

    @Override
    public void step(SimState simState) {

    }

    public int getCost() {
        return cost;
    }

    public Set<State> getParticipants() {
        return participants;
    }

    public void addParticipant(State participant) {
        this.participants.add(participant);
    }

}
