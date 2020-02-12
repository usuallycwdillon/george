package edu.gmu.css.entities;


import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.relations.ProcessDisposition;
import org.neo4j.ogm.annotation.*;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class Dispute extends Entity {
    /**
     *
     */
    @Id @GeneratedValue
    private long id;
    @Property
    private String name;
    @Property
    private long from;
    @Property
    private long until;
    @Property
    private long during;
    @Property
    private SecurityObjective objective;
    @Property
    private int costs;
    @Property
    private int magnitude;


    @Relationship
//            (type = "PARTICIPATE_IN", direction = Relationship.INCOMING)
    private Set<Polity> participants = new HashSet<>();

    public Dispute() {

    }

    public Dispute(Process process) {
        name = "Dispute";
        from = process.getBegan();
        until = process.getEnded();
        objective = highestLevel(process);
        for (ProcessDisposition pd : process.getProcessDispositionList()) {
            participants.add(pd.getOwner());
        }
    }

    private SecurityObjective highestLevel(Process process) {
        int highest = 0;
        for (ProcessDisposition d : process.getProcessDispositionList()) {
            if (d.getObjective() != null) {
                int val = d.getObjective().value;
                highest = Math.max(highest, val);
            }
        }

        return SecurityObjective.name(highest);
    }

    public long getUntil() {
        return until;
    }

    public void setUntil(long until) {
        this.until = until;
    }

    public long getDuring() {
        return during;
    }

    public void setDuring(long during) {
        this.during = during;
    }

    public int getCosts() {
        return costs;
    }

    public void setCosts(int costs) {
        this.costs = costs;
    }

    public int getMagnitude() {
        return magnitude;
    }

    public void setMagnitude(int magnitude) {
        this.magnitude = magnitude;
    }

    public Set<Polity> getParticipants() {
        return participants;
    }

    public void addParticipants(Polity participants) {
        this.participants.add(participants);
    }
}
