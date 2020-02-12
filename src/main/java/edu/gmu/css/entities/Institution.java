package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Issue;
import edu.gmu.css.relations.InstitutionParticipation;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@NodeEntity
public abstract class Institution extends Entity implements Steppable, Stoppable {
    /**
     *
     */
    @Id @GeneratedValue
    protected Long id;
    @Property
    protected Long from;        // from or began
    @Property
    protected Long until;       // until or ended
    @Property
    protected double value;     // magnitude, etc. a cumulative/total measure; may be overridden to int
    @Property
    protected int size;         // number of participants
    @Property
    protected int year;        // not always used
    @Property
    protected Domain domain;
    @Property
    protected boolean active = false;
    @Transient
    protected boolean stopped;
    @Transient
    protected Resources maintenance;
    @Transient
    protected MersenneTwisterFast random;
    @Transient
    protected Stoppable stopper = null;
    @Transient
    protected String name;
    @Transient
    protected Issue issue;
    @Transient
    protected Process cause;
    @Transient
    protected Resources cost;

    @Relationship(direction=Relationship.INCOMING)
    protected List<InstitutionParticipation> participation = new ArrayList<>();
    @Relationship
    protected Process process;          // Countervailing process,  not the one that created it
    @Relationship
    protected Organization organization; // Only used if this institution spawned an organization

    public Institution() {
    }

    public Institution(Process process, long s) {
       cause = process;
       from = s;
       cost = new Resources.ResourceBuilder().build();
    }

    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
    }

    @Override
    public Long getId() {
        return id;
    }

    public Long getFrom() {
        return from;
    }

    public void setFrom(long from) {
        this.from = from;
    }

    public Long getUntil() {
        return until;
    }

    public void setUntil(long until) {
        this.until = until;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public int getDuring() {
        return year;
    }

    public void setDuring(int during) {
        this.year = during;
    }

    public List<InstitutionParticipation> getParticipation() {
        return participation;
    }

    public void setParticipation(List<InstitutionParticipation> participation) {
        this.participation = participation;
    }

    public void addParticipation(InstitutionParticipation participation) {
        this.participation.add(participation);
    }

    public Set<Polity> getParticipants() {
        Set<Polity> participants = new HashSet<>();
        for (InstitutionParticipation p : participation) {
            participants.add(p.getParticipant());
        }
        return participants;
    }

    public Set<Polity> getOtherParticipants(Polity p) {
        Set<Polity> others = new HashSet<>();
        for (InstitutionParticipation i : participation) {
            if (i.getParticipant() != p) {
                others.add(i.getParticipant());
            }
        }
        return others;
    }

    public boolean isParticipant(Polity t) {
        for (InstitutionParticipation i : participation) {
            if (i.getParticipant() == t) {
                return true;
            }
        }
        return false;
    }


    public Process getProcess() {
        return process;
    }

    public void setProcess(Process process) {
        this.process = process;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Organization getOrganization() {
        return organization;
    }

    public void setOrganization(Organization organization) {
        this.organization = organization;
    }

    public void collectCosts() {

    }

    public void setStopper(Stoppable stopper)   {this.stopper = stopper;}

    public Stoppable getStopper() {
        return this.stopper;
    }

    public void stop(){stopper.stop();}

    public void conclude(WorldOrder wo) {
        stopper.stop();
        stopped = true;
        wo.getAllTheInstitutions().remove(this);
    }
}
