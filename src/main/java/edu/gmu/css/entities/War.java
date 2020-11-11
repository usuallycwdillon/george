package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.*;

@NodeEntity
public class War extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private Long id;
    @Transient
    private Resources involvement;
    @Property
    private double warCost = 0.0;
    @Property
    private double magnitude = 0.0;

    @Relationship (type = "PARTICIPATED_IN", direction = Relationship.INCOMING)
    private final List<WarParticipationFact> participations = new LinkedList<>();
    @Relationship (type = "IS_WAR")
    private WarFact warFact;

    public War() {
        name = "War";
        cost = new Resources.ResourceBuilder().build();
        involvement = new Resources.ResourceBuilder().build();
    }

    public War(Process proc) {
        this();
        Process p = proc;
        from = p.getEnded();
        cost.increaseBy(p.getCost());
        involvement.increaseBy(p.getInvolvement());
        name = "War";
        cause = p;
    }

    @Override
    public void step(SimState simState) {
        if(stopped) {
            stopper.stop();
            return;
        }
        WorldOrder worldOrder = (WorldOrder) simState;
        // 0. Consume resources at wartime rate = 2x peacetime
        consumeResources(worldOrder);
        // 1. Do any participants want peace?

        // 2. Update war values
        updateValues();
        // 3. Will there be a battle?
        // TODO: This should probably be a Weibul distro, bur for now it's +1sd of Gaussian normal.
        if (worldOrder.random.nextGaussian() > 0.681) {     // 1sd above mean
            battle(worldOrder);
        }
    }

    @Override
    public Long getId() {
        return this.id;
    }

    public void addParticipation(WarParticipationFact p) {
        participations.add(p);
    }

    public void removeParticipation(WarParticipationFact p) {
        participations.remove(p);
    }

    public WarFact getWarFact() {
        return warFact;
    }

    public void setWarFact(WarFact warFact) {
        this.warFact = warFact;
    }

    private void battle(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        extent = this.participations.size();
        // Take a part of the total force as a loss; split the loss between the participants
        // 1. How big was the battle? between [0, 0.5) of the current total commitment
        Double battleSize = worldOrder.random.nextDouble() * 0.5;
        Double battleMagnitude = (involvement.getPax() * battleSize);
        // 2. How to divide the losses?
        double divvy = 1.0;
        double [] portions = new double [extent];
        for (int i = 0; i< extent-1; i++) {
            double share = worldOrder.random.nextDouble();
            divvy -= share;
            portions[i] = share;
        }
        portions[extent - 1] = divvy;
        // 3. Move each participant's share of the battle magnitude from their participation to cost/magnitude
        for (int i = 0; i< extent; i++) {
            WarParticipationFact p = participations.get(i);
            Double loss = portions[i] * battleMagnitude * p.getCommitment().getPax();
            p.tallyLosses(loss, worldOrder);
            cost.incrementPax(loss);  // War cost, not Polity's cost in this battle
        }
    }

    private void updateValues() {
        extent = participations.size();
        warCost = cost.getTreasury();
        magnitude = cost.getPax();
        Resources temp = new Resources.ResourceBuilder().build();
        for (WarParticipationFact wp : participations) {
            temp.increaseBy(wp.getCommitment());
        }
        involvement = temp;
    }

    private void consumeResources(WorldOrder wo) {
        int weeks = wo.dataYear.getWeeksThisYear();
        for (WarParticipationFact wp : participations) {
            Resources c = wp.getCommitment();
            Polity p = wp.getPolity();
            double myCost = (c.getTreasury() / weeks) * 2.0;
            c.decrementTreasury(myCost);
            cost.incrementTreasury(myCost);
            Resources req = new Resources.ResourceBuilder().treasury(myCost).build();
            p.getSecurityStrategy().addSupplemental(wp,req);
        }
    }

}
