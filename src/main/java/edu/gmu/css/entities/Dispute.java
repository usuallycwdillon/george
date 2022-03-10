package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Stoppable;

import java.util.*;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;


@NodeEntity
public class Dispute extends Institution {
    /**
     *
     */
    @Id @GeneratedValue private Long id;
    @Property private String name;
    @Transient private Resources involvement = new Resources.ResourceBuilder().build();
    @Transient private WarProcess cause;
    @Transient private int plannedDuration = 4;

    @Relationship(type = "DISPUTED_OVER", direction=Relationship.INCOMING)
    protected List<DisputeParticipationFact> participations = new ArrayList<>();
    @Relationship(type = "ABOUT", direction = Relationship.INCOMING)
    protected DisputeFact disputeFact;
    @Relationship(type = "LINKED")
    protected List<DisputeLinkFact> followOnDisputes = new ArrayList<>();
    @Relationship(type = "LINKED_TO", direction = Relationship.INCOMING)
    protected List<DisputeLinkFact> priorDisputes = new ArrayList<>();


    public Dispute() {
        this.name = "Dispute";
        this.cost = new Resources.ResourceBuilder().build();
        this.involvement = new Resources.ResourceBuilder().build();
        this.domain = Domain.WAR;
        this.strength = 0.5;
    }

    public Dispute(Process p, long s) {
        this();
        this.cause = (WarProcess) p;
        this.cost.increaseBy(p.getCost());
        this.involvement.increaseBy(cause.getInvolvement());
        this.issue = p.getIssue();
        this.from = s;
        this.until = s + 1L;
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        plannedDuration -= 1;
        if (plannedDuration <= 0) {
            for (DisputeParticipationFact f : participations) {
                ProcessDisposition d = f.getDisposition();
                d.setOutcome(true);
                d.setS(false);
            }
            this.setStopped(true);
        }
        if(stopped) {
            stopper.stop();
            return;
        }
        for (DisputeParticipationFact f : participations) {
            ProcessDisposition p = f.getDisposition();
            if ( p.atU() &&
                 p.getUt() == 0 &&
                 f.getCommitment().isSufficientFor(p.getCommitment()) &&
                 worldOrder.random.nextBoolean() ) {
                int val = p.getObjective() == null ? -3 : p.getObjective().value;
                if (val == 0 || val == 1) {
                    cost.increaseBy( strike(f, worldOrder) );
                    disputeFact.setHostilityLevel("Strike");
                } else if (val == 2 || val == 3) {
                    cost.increaseBy( showForce(f, worldOrder) );
                    disputeFact.setHostilityLevel("Show of Force");
                } else {
                    p.getOwner().surrender(p,worldOrder);
                }
            }
        }
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

    public int getPlannedDuration() {
        return plannedDuration;
    }

    public void setPlannedDuration(int plannedDuration) {
        this.plannedDuration = plannedDuration;
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

//    public boolean isStopped() {
//        return stopped;
//    }
//
//    public void setStopped(boolean stopped) {
//        this.stopped = stopped;
//    }

    @Override
    public String getReferenceName() {
        return super.referenceName;
    }

    public Resources strike(DisputeParticipationFact f, WorldOrder wo) {
        Map<String, Object> varMap = new HashMap<>();
        varMap.put("Dispute", this.getReferenceName());
        varMap.put("Action", f.getDisposition().getObjective().toString());
        varMap.put("attacker", f.getPolity().getName());
        varMap.put("stepNo", wo.getStepNumber());
        WorldOrder worldOrder = wo;
        ProcessDisposition attacker = f.getDisposition();
        Polity target = attacker.getEnemy();
        varMap.put("target", target.getName());
        ProcessDisposition targetDisposition = attacker.getEnemyDisposition();
        DisputeParticipationFact targetParticipation = getEnemyParticipation(target);
        double ppl = worldOrder.random.nextDouble() * (1 + worldOrder.random.nextInt(10) );
        double bld = worldOrder.random.nextDouble() * 0.5;
        String location =  (String) attacker.getAttackPath(worldOrder).get("last");
        varMap.put("targetTile", location);
        Tile tile = wo.getTiles().get(location);
        if (Objects.isNull(tile)) {
            System.out.println("Tile " + location + " seems not to be loaded");
        }
        tile.takeDamage(ppl, bld);
        varMap.put("civLives", ppl);
        varMap.put("infrastructure", bld);
        Resources targetResources = target.getResources();
        Resources strikeCost = new Resources.ResourceBuilder().pax(2 * ppl).treasury(1000.0 * bld).build();
        targetResources.reduceBy(strikeCost);
        targetParticipation.getCost().increaseBy(strikeCost);
        varMap.put("paxLost", strikeCost.getPax());
        varMap.put("equipmentLost", strikeCost.getTreasury());
        // was it successful ?
        if (worldOrder.random.nextBoolean(0.75) ) {
            attacker.setS(true);
            attacker.setOutcome(true);
            disputeFact.setOutcome(target.getName() + " Yield to " + attacker.getOwner().getName());
            targetDisposition.setOutcome(true);
            varMap.put("successfulStrike", true);
        }
        // The Strikes end whether it was successful or not (11 -> Z) or (14 -> A)
//        if (targetDisposition.atU() == true && targetDisposition.getUt() < 4) {

//        } else {
            this.setStopped(true);
            this.cause.setOutcome(true);
            this.cause.setFiat();
            if (DEBUG) System.out.println(this.disputeFact.getObject() + " should end in the next step.");
//        }
        // This is what the target lost in the strike, regardless of success
//        System.out.println(varMap.toString());
        return strikeCost;
    }

    public Resources showForce(DisputeParticipationFact f, WorldOrder wo) {
        ProcessDisposition p = f.getDisposition();
        ProcessDisposition o = p.getEnemyDisposition();
        WorldOrder worldOrder = wo;
        if (worldOrder.random.nextBoolean(0.10) && p.getOwner().willRelent(p, o, worldOrder) ) {
            p.setS(true);
            p.setOutcome(true);
            cause.getIssue().setResolved(true);
            cause.setOutcome(true);
            setStopped(true);
            // The SOF does not end until it is successful (even if it's just a president standing on an aircraft
            // carrier declaring that their "definition of victory is success. ...and victory" --George III.
//            cause.conclude(worldOrder);
            if (DEBUG) System.out.println(this.disputeFact.getObject() + " should just ended in the previous step.");
        }
        if ( p.getCommitment().getTreasury() <= 0.0 ) {
            stopper.stop();
            this.setStopped(true);
            p.setOutcome(true);
//            process.setNowFighting(false);
            cause.setOutcome(true);
            cause.conclude(worldOrder);
            if (DEBUG) System.out.println(this.disputeFact.getObject() + " should end in the next step.");
        }
        return new Resources.ResourceBuilder().treasury(p.getCommitment().getTreasury()/52).build();
    }

    private DisputeParticipationFact getEnemyParticipation(Polity enemy) {
        for (DisputeParticipationFact f : participations) {
            if (f.getPolity().equals(enemy)) {
                return f;
            }
        }
        return null;
    }

    public void updateForSave(WorldOrder wo) {
        Long week = wo.getWeekNumber();
        this.until = week;
        double mag = 0.0;
        double cos = 0.0;
        for (DisputeParticipationFact f : participations) {
            mag += f.getCost().getPax();
            f.setPreciseFatalities(f.getCost().getPax());
            cos += f.getCost().getTreasury();
            f.setFinalCost(f.getCost().getTreasury());
            f.setUntil(week);
        }
        disputeFact.setPreciseFatalities(mag);
        disputeFact.setFinalCost(cos);
        disputeFact.setUntil(week);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Dispute)) return false;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Dispute that = (Dispute) o;

        if (getReferenceName() != null ? !getReferenceName()
                .equals(that.getReferenceName()) : that.getReferenceName() != null) return true;
        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        return getName().equals(that.getName());
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getReferenceName().hashCode();
        result = 31 * result + getName().hashCode();
        return result;
    }

}
