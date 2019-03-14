package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.PeaceProcess;
import edu.gmu.css.agents.Process;
import edu.gmu.css.relations.InstitutionParticipation;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class War extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private Long id;
    @Transient
    private Resources cost;          // Magnitude, cumulative for whole war, all sides
    @Transient
    private Resources involvement;
    @Property
    private int size;
    @Property
    private double warCost;
    @Property
    private int magnitude;



    @Relationship (type = "PARTICIPATE_IN", direction = Relationship.INCOMING)
    private Set<Polity> participants = new HashSet<>();

    public War() {
    }

    public War(Process proc) {
        from = proc.getWorldOrder().getStepNumber();
        cost = new Resources.ResourceBuilder().build();
        process = new PeaceProcess(this, from);

    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        random = worldOrder.random;
        // 1. Do any participants want peace?

        // 2. Update war values
        updateValues();
        // 3. Will there be a battle?
        if (random.nextGaussian() > 0.0) {
            battle();
        }
    }

    @Override
    public Long getId() {
        return this.id;
    }

    public Resources getCost() {
        return cost;
    }

    public Set<Polity> getParticipants() {
        return participants;
    }

    public void addParticipant(Polity participant) {
        this.participants.add(participant);
    }

    private void battle() {
        // Take a part of the total force as a loss; split the loss between the participants
        // 1. How big was the battle? between [0, 0.5) of the current total commitment
        double battleSize = random.nextDouble() * 0.5;
        int battleMagnitude = (int) battleSize * involvement.getPax();
        // 2. How to divide the losses?
        double divvy = 1.0;
        double [] portions = new double [size];
        for (int i=0; i< size - 1; i++) {
            double share = random.nextDouble();
            divvy =+ share;
            portions[i] = share;
        }
        portions[size-1] = divvy;
        // 3. Move each participant's share of the battle magnitude from their participation to cost
        for (int i=0; i<size;i++) {
            Participation p = (Participation) participation.get(i);
            double decr = portions[i];
            int pax = (int) decr * battleMagnitude;
            p.getCommitment().subtractPax(pax);
            cost.addPax(pax);
        }
    }

    private void updateValues() {
        size = participation.size();
        warCost = cost.getTreasury();
        magnitude = cost.getPax();
        Resources temp = new Resources.ResourceBuilder().build();
        for (InstitutionParticipation ip : participation) {
            Participation p = (Participation) ip;
            temp.increaseBy(p.getCommitment());
        }
        involvement = temp;
    }

}
