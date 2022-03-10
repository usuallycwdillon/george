package edu.gmu.css.entities;

import edu.gmu.css.agents.Issue;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.service.DateConverter;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

@NodeEntity
public abstract class Institution extends Entity implements Steppable, Stoppable {
    /**
     *
     */
    @Id @GeneratedValue
    protected Long id;
    @Convert(DateConverter.class) protected Long from;        // from or began
    @Convert(DateConverter.class) protected Long until;       // until or ended
    @Property protected double value;     // magnitude, etc. a cumulative/total measure; may be overridden to int
    @Property protected int extent;       // number of participants
    @Property protected int during;       // not always used
    @Property protected Domain domain;
    @Property protected boolean active = false;
    @Transient protected boolean stopped;
    @Transient protected Resources maintenance = new Resources.ResourceBuilder().build();
    @Transient protected Stoppable stopper = null;
    @Transient protected String name;
    @Transient protected Issue issue;
    @Transient protected Process cause;
    @Transient protected Resources cost = new Resources.ResourceBuilder().build();
    @Transient protected String referenceName;
    @Transient protected double strength;


    @Relationship
    protected Process process;          // The process that created this institution
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
        WorldOrder wo = (WorldOrder) simState;
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
        return extent;
    }

    public void setSize(int size) {
        this.extent = size;
    }

    public int getDuring() {
        return during;
    }

    public void setDuring(int during) {
        this.during = during;
    }

    public Resources getCost() {
        return cost;
    }

    public void setCost(Resources cost) {
        this.cost = cost;
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

    public String getDomainName() {
        if (this.domain == null && WorldOrder.DEBUG) {
            System.out.println("Why doesn't this institution have a domain name?");
        }
        return this.domain.value;
    }

    public Domain getDomain() {
        return this.domain;
    }

    public Resources getMaintenance() {
        return maintenance;
    }

    public void setMaintenance(Resources maintenance) {
        this.maintenance = maintenance;
    }

    public Organization getOrganization() {
        return organization;
    }

    public void setOrganization(Organization organization) {
        this.organization = organization;
    }

    public void collectCosts() {

    }

    public Issue getIssue() {
        return issue;
    }

    public void setIssue(Issue issue) {
        this.issue = issue;
    }

    public Process getCause() {
        return cause;
    }

    public void setCause(Process cause) {
        this.cause = cause;
    }

    public String getReferenceName() {
        return referenceName;
    }

    public void setReferenceName(String referenceName) {
        this.referenceName = referenceName;
    }

    public double getStrength() {
        return strength;
    }

    public boolean isStopped() {
        return stopped;
    }

    public void setStopped(boolean stopped) {
        this.stopped = stopped;
    }

    public void setStrength(double strength) {
        this.strength = strength;
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
