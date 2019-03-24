package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Organization;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.relations.InstitutionParticipation;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.util.MTFApache;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.io.Serializable;
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
    protected Resources maintenance;
    @Transient
    protected MersenneTwisterFast random;
    @Transient
    protected Stoppable stopper = null;

    @Relationship(direction=Relationship.INCOMING)
    protected List<InstitutionParticipation> participation = new ArrayList<>();
    @Relationship
    protected Process process;          // Countervailing process,  not the one that created it
    @Relationship
    protected Organization organization; // Only used if this institution spawned an organization

    public Institution() {
    }

    public Institution(Process process) {
    }

    public void step(SimState simState) {

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

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
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

    public Organization getOrganization() {
        return organization;
    }

    public void setOrganization(Organization organization) {
        this.organization = organization;
    }

    public void collectCosts() {

    }

//    public void setStopper(Stoppable stopper) {
//        this.stopper = stopper;
//    }
//
//    public void stop(){
//        setStopper(this);
//    }

    public void setStopper(Stoppable stopper)   {this.stopper = stopper;}

    public void stop(){stopper.stop();}


}
