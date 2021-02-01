package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.data.Resources;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.data.World;
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
    @Transient
    private boolean ceasefire = false;
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
        boolean firstStep = worldOrder.getStepNumber() == from;
        boolean evenStep = worldOrder.getStepNumber() % 2 == 0;
        // 0. Consume resources at wartime rate = 2x peacetime
        consumeResources(worldOrder);
        // 1. Do any participants need peace?

        // 2. Update war values
        updateValues();
        // 3. Will there be a battle?
        // TODO: This should be a Weibul distro, bur for now it's +1sd of Gaussian normal.
        if (worldOrder.random.nextGaussian() > 0.681 && !ceasefire) {     // 1sd above mean
            battle(worldOrder);
        }
        if (firstStep) {
            Polity instigator = cause.getIssue().getInstigator();
            SecurityObjective goal = participations.get(0).getGoal();


        }

    }

    @Override
    public Long getId() {
        return this.id;
    }

    public List<WarParticipationFact> getParticipations() {
        return this.participations;
    }

    public void addParticipation(WarParticipationFact p) {
        participations.add(p);
        if(WorldOrder.DEBUG && p.getCommitment().getPax()==0) {
            System.out.println(p.getPolity().getName() + " has not forces to commit to this war");
        }
        involvement.increaseBy(p.getCommitment());
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

    public void beginCeaseFire() {
        this.ceasefire = true;
    }

    public void endCeaseFire() {
        this.ceasefire = false;
    }

    private void battle(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        // 1. How to divide (and attribute) the losses?
        Map<Double, WarParticipationFact> lossMap = new HashMap<>();
        Double divvy = 1.0;
        Double [] portions = new Double [extent];
        for (int i = 0; i< extent-1; i++) {
            Double share = worldOrder.random.nextDouble();
            divvy -= share;
            portions[i] = share;
        }
        portions[extent - 1] = divvy;

        Double inferior = participations.get(0).getCommitment().getPax();
        for (WarParticipationFact p : participations) {
            Double force = p.getCommitment().getPax();
            if (force < inferior) inferior = force;
        }

        Double maxPortion = Collections.max(Arrays.asList(portions));
        Double battleMagnitude = inferior * maxPortion;
        // 3. Move each participant's share of the battle magnitude from their participation to cost/magnitude
        for (int i = 0; i< extent; i++) {
            WarParticipationFact p = participations.get(i);
            Double loss = portions[i] * battleMagnitude;
            lossMap.put(loss,p);
            cost.incrementPax(loss);  // War cost, not Polity's cost in this battle
        }

        Double minLoss = Collections.min(lossMap.keySet());
        int winningSide = lossMap.get(minLoss).getSide();
        for (Map.Entry<Double, WarParticipationFact> e : lossMap.entrySet()) {
            boolean winning = e.getValue().getSide() == winningSide;
            e.getValue().tallyLosses(e.getKey(), winning, worldOrder);
        }
    }

    private void strike(WorldOrder wo) {
        WorldOrder worldOrder = wo;

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
