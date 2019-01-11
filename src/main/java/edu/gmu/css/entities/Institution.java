package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.entities.Organization;
import edu.gmu.css.entities.Polity;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.time.Year;
import java.util.List;

@NodeEntity
public abstract class Institution extends Entity implements Steppable, Serializable {
    /**
     *
     */
    @Id @GeneratedValue
    protected long id;
    @Property
    protected long from;        // from or began
    @Property
    protected long until;       // until or ended
    @Property
    protected double value;     // magnitude, etc. a cumulative/total measure; may be overridden to int
    @Property
    protected int numberParticipants;
    @Property
    protected Year year;        // not always used

    @Transient
    protected List<Polity> participants;

    @Relationship
    protected Process process;
    @Relationship
    protected Organization organization; // Only used if this institution spawned an organization

    public Institution() {
    }

    public Institution(Process process) {
    }

    public Institution(SimState simState) {

    }

    public void collectCosts() {

    }


}
