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
    private long id;
    private double costliness;  // How much does the war cost (split between parties) each step
    private double issueValue;  // What is the value of the war subject?
    private long start;         // Week @start
    private double overallCost; // Cumulative cost from all participants for each step the war lasts
    public int numParticipants;

    @Relationship (type = "PARTICIPATE_IN", direction = "INCOMING")
    private Set<State> participants = new HashSet<>();

    public War(long start) {
        if (numParticipants > 0) {
            setCostliness();
        }
//        this.issueValue = value;
        this.start = start;
    }

    @Override
    public void step(SimState simState) {

    }

    public double getCostliness() {
        return costliness;
    }

    private double setCostliness() {
//        if (numParticipants > 0) {
//            costliness = (participants.stream().mapToDouble(s -> s.getResources() * (0.10)).sum() / numParticipants);
//            }
        return costliness;
    }

    public double getValue() {
        return issueValue;
    }

    public Set<State> getParticipants() {
        return participants;
    }

    public void addParticipant(State participant) {
        this.participants.add(participant);
        setCostliness();
    }

}
