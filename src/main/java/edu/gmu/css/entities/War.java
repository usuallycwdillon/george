package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
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
    private long id;
    private int cost;          // Magnitude, cumulative for whole war, all sides

    @Relationship (type = "PARTICIPATE_IN", direction = "INCOMING")
    private Set<Polity> participants = new HashSet<>();

    public War() {
    }

    public War(Process process) {

    }

    @Override
    public void step(SimState simState) {

    }

    public int getCost() {
        return cost;
    }

    public Set<Polity> getParticipants() {
        return participants;
    }

    public void addParticipant(Polity participant) {
        this.participants.add(participant);
    }

}
