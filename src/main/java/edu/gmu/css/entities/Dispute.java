package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.data.SecurityStrategy;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;


@NodeEntity
public class Dispute extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private long id;
    @Property private String name;
    @Transient private Resources cost = new Resources.ResourceBuilder().build();
    @Transient private Resources involvement = new Resources.ResourceBuilder().build();
    @Transient private WarProcess cause;
    @Transient private Domain domain;
    @Transient private Stoppable stopper;
    @Transient private boolean stopped;


    @Relationship(type = "DISPUTE_OVER", direction=Relationship.INCOMING)
    protected List<DisputeParticipationFact> participations = new ArrayList<>();
    @Relationship(type = "ABOUT", direction = Relationship.INCOMING)
    protected DisputeFact disputeFact;
    @Relationship(type = "LINKED")
    protected List<DisputeLinkFact> followOnDisputes = new ArrayList<>();
    @Relationship(type = "LINKED_TO", direction = Relationship.INCOMING)
    protected List<DisputeLinkFact> priorDisputes = new ArrayList<>();


    public Dispute() {
    }

    public Dispute(Process p) {
        this.cause = (WarProcess) p;
        this.cost.increaseBy(p.getCost());
        this.name = "Dispute";
        this.involvement = cause.getInvolvement();
        this.domain = Domain.WAR;
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        if(stopped) {
            stopper.stop();
            return;
        }
        for (DisputeParticipationFact f : participations) {
            ProcessDisposition p = f.getDisposition();
            if (p.getUt() <= 0) {
                int val = p.getObjective() == null ? -3 : p.getObjective().value;
                if (val == 0 || val == 1) {
                    cost.increaseBy( strike(f, worldOrder) );
                } else if (val == 2 || val == 3) {
                    cost.increaseBy( showForce(f, worldOrder) );
                }
            }
        }
    }

    @Override
    public void stop() {

    }


    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void addParticipant(DisputeParticipationFact f) {
        participations.add(f);
    }

    public void setDisputeFact(DisputeFact f) {
        this.disputeFact = f;
    }

    public DisputeFact getDisputeFact() {
        return this.disputeFact;
    }

    public List<DisputeParticipationFact> getParticipations() {
        return participations;
    }

    public Resources getInvolvement() {
        return involvement;
    }

    public void setInvolvement(Resources involvement) {
        this.involvement = involvement;
    }

    @Override
    public Resources getCost() {
        return cost;
    }

    @Override
    public void setCost(Resources cost) {
        this.cost = cost;
    }

    public List<DisputeLinkFact> getFollowOnDisputes() {
        return followOnDisputes;
    }

    public void setFollowOnDisputes(List<DisputeLinkFact> followOnDisputes) {
        this.followOnDisputes = followOnDisputes;
    }

    public void addFollowOnDispute(DisputeLinkFact f) {
        this.followOnDisputes.add(f);
    }

    public List<DisputeLinkFact> getPriorDisputes() {
        return priorDisputes;
    }

    public void setPriorDisputes(List<DisputeLinkFact> priorDisputes) {
        this.priorDisputes = priorDisputes;
    }

    public void addPriorDispute(DisputeLinkFact f) {
        this.priorDisputes.add(f);
    }

    public Stoppable getStopper() {
        return stopper;
    }

    public void setStopper(Stoppable stopper) {
        this.stopper = stopper;
    }

    public boolean isStopped() {
        return stopped;
    }

    public void setStopped(boolean stopped) {
        this.stopped = stopped;
    }

    public Resources strike(DisputeParticipationFact f, WorldOrder wo) {
        ProcessDisposition p = f.getDisposition();
        WorldOrder worldOrder = wo;
        Polity enemy = p.getEnemy();
        double ppl = worldOrder.random.nextDouble() * (1 + worldOrder.random.nextInt(10) );
        double bld = worldOrder.random.nextDouble() * 0.5;
        ProcessDisposition attacker = p;
        String location =  (String) p.getAttackPath().get("last");
        Tile tile = wo.getTiles().get(location);
        if (Objects.isNull(tile)) {
            System.out.println("Tile " + location + " seems not to be loaded");
        }
        tile.takeDamage(ppl, bld);
        SecurityStrategy force = enemy.getSecurityStrategy();
        force.getMilitaryStrategy().decrementPax(2 * ppl);
        force.getMilitaryStrategy().decrementTreasury(bld * 1000.0);
        // was it successful ?
        if (worldOrder.random.nextBoolean() ) {
            p.setS(true);
        }
        // The Strikes end whether it was successful or not (11 -> Z) or (14 -> A)
        stopper.stop();
        setStopped(true);
        // This is what the target lost in the strike, regardless of success
        return new Resources.ResourceBuilder().pax(2 * ppl).treasury(1000.0 * bld).build();
    }

    public Resources showForce(DisputeParticipationFact f, WorldOrder wo) {
        ProcessDisposition p = f.getDisposition();
        ProcessDisposition o = p.getEnemyDisposition();
        WorldOrder worldOrder = wo;
        if (worldOrder.random.nextBoolean(0.10) || o.getOwner().willRelent(o, worldOrder) ) {
            p.setS(true);
            p.setOutcome(true);
            cause.setNowFighting(false);
            cause.getIssue().setResolved(true);
            // The SOF does not end until it is successful (even if it's just a president standing on an aircraft
            // carrier declaring that their definition of victory is success. ...and victory.
            stopper.stop();
            setStopped(true);

        }
        if ( p.getCommitment().getTreasury() <= 0.0 ) {
            stopper.stop();
            setStopped(true);
            p.setOutcome(true);
        }
        return new Resources.ResourceBuilder().treasury(p.getCommitment().getTreasury()/52).build();
    }

    public void updateForSave(WorldOrder wo) {
        Long week = wo.getWeekNumber();
        this.until = week;
        double mag = 0.0;
        double cos = 0.0;
        for (DisputeParticipationFact f : participations) {
            mag += f.getCost().getPax();
            cos += f.getCost().getTreasury();
            f.setUntil(week);
        }
        disputeFact.setMagnitude(mag);
        disputeFact.setFinalCost(cos);
        disputeFact.setUntil(week);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Dispute that = (Dispute) o;

        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        if (!getName().equals(that.getName())) return false;
        return disputeFact != null ? disputeFact.equals(that.disputeFact) : that.disputeFact == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getName().hashCode();
        result = 31 * result + (disputeFact != null ? disputeFact.hashCode() : 0);
        return result;
    }
}
