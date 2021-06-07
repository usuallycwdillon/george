package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.util.Lanchester;
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
        domain = Domain.WAR;
    }

    public War(Process proc) {
        this();
        Process p = proc;
        cost.increaseBy(p.getCost());
        cause = p;
        domain = Domain.WAR;
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
        // 1. Do any participants need peace?
        for (WarParticipationFact p : participations) {
            if ( Objects.isNull(p.getCommitment() ) ) {
                p.getPolity().surrender(p.getDisposition(), worldOrder);
                // TODO: if the attacker objective is to conquer, move this state out of the system, and merge
                // it with the attacking state.
                return;
            }
        }
        // 2. Update war values
        updateValues();
        // 3. Will there be a battle?
        // TODO: This should probably be a Weibull distro, but for now it's +1sd of Gaussian normal.
        if (worldOrder.random.nextGaussian() < -0.681 && !ceasefire) {     // 1sd below mean

            battle(worldOrder);
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

    public double estimateBattleDeaths(int e, int d, MersenneTwisterFast r) {
        /**
         * Cioffi-revilla, Claudio. 1991. “On the Likely Magnitude , Extent , and Duration of an Iraq-UN War.”
         * Journal of Conflict Resolution 35 (3): 387–411.
         *
         * For all interstate wars (regardless of great power status/participation)
         * log(totalFatalities) = 2.9 + 1.68 log(involvement.getPax) + 0.7 log(durationWeeks * 7)
         *
         * Fatalites from any battle are assumed to be a random number between a log of the intercept, 2.9 and the
         * maximum value that considers both the extent and the duration __so far__
         */
        int weeks = d;
        int extent = e;
        // no more than the number of involved can be lost in the battle
        double pax = involvement.getPax();
        double minF = Math.pow(10, 2.9);
        double maxF = Math.pow(10, (2.9 + ( (1.68 * Math.log10(extent)) + (0.7 * Math.log10(weeks / 4.33)) )) );
        double fatalities = minF + (r.nextDouble(true, true) * maxF);
        return Math.min(fatalities, pax);
    }

    private void battle(WorldOrder wo) {
        WorldOrder worldOrder = wo;

        // 1. How to divide (and attribute) the losses?
        Map<Double, WarParticipationFact> lossMap = new HashMap<>();
        int five = 0;
        int marching = 0;
        int side1 = 0;
        int side0 = 0;
        Resources attackers = new Resources.ResourceBuilder().build();
        Resources defenders = new Resources.ResourceBuilder().build();
        Resources currentInvolvement = new Resources.ResourceBuilder().build();
        for (WarParticipationFact wp : participations) {
            int o = wp.getDisposition().getObjective() != null ? wp.getDisposition().getObjective().value : -3;
            if (wp.getCommitment().getPax() == 0.0) wp.getPolity().surrender(wp.getDisposition(), worldOrder);
            Resources thisInvolvement = wp.getCommitment();
            if (wp.getSide() == 0) {
                currentInvolvement.increaseBy(thisInvolvement);
                side0 += 1;
                if (wp.getDisposition().getUt() > 0) {
                    attackers.increaseBy(thisInvolvement);
                    marching += 1;
                }
            } else {
                currentInvolvement.increaseBy(thisInvolvement);
                defenders.increaseBy(thisInvolvement);         // added in consideration of force size
                side1 += 1;
                if (o == 5) {
                    five += 1;
                    defenders.increaseBy(thisInvolvement);     // for the purposes of force concentration, add it again
                }
            }
        }
        // all attackers are still marching and all defenders are dug in
        if ((marching == side0 && five == side1) || side0 == 0 || side1 == 0) return;

        double attackForceConcentration = new Lanchester(attackers, defenders).calculateMyForceConcentration();
        Long d = worldOrder.getWeekNumber() - from;
        double fatalities = estimateBattleDeaths(participations.size(), d.intValue(), worldOrder.random);

        double fatalitiesSide0;
        if (attackForceConcentration > 1.0) {
            fatalitiesSide0 = fatalities / (attackForceConcentration + 1.0);
        } else {
            fatalitiesSide0 = fatalities - (fatalities / ((1.0 / attackForceConcentration) + 1.0));
        }
        int winningSide = (fatalitiesSide0 / fatalities > 0.5) ? 1 : 0;

        for (WarParticipationFact wp : participations) {
            boolean winning = wp.getSide() == winningSide;
            if (wp.getSide() == 0) {
                if (side0 == 1) {
                    wp.tallyLosses(fatalitiesSide0, winning, worldOrder);
                    this.cost.incrementPax(fatalitiesSide0);
                } else {
                    double thesePax = wp.getCommitment().getPax();
                    double share = thesePax / attackers.getPax();
                    double loss = Math.min(share, thesePax);
                    wp.tallyLosses(loss, winning, worldOrder);
                    this.cost.incrementPax(loss);
                }
            } else {
                if (side1 == 1) {
                    double loss = fatalities - fatalitiesSide0;
                    wp.tallyLosses(loss, winning, worldOrder);
                    this.cost.incrementPax(loss);
                } else {
                    double thesePax = wp.getCommitment().getPax();
                    double share = thesePax / attackers.getPax();
                    double loss = Math.min(share, thesePax);
                    wp.tallyLosses(loss, winning, worldOrder);
                    this.cost.incrementPax(loss);
                }
            }

        }
    }

    private void strike(WorldOrder wo) {
        WorldOrder worldOrder = wo;

    }

    public void updateValues() {
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
            Polity p = wp.getPolity();
            Resources c = wp.getCommitment();
            if (!Objects.isNull(c)) {
                double myCost = c.getTreasury() / weeks;
                c.decrementTreasury(myCost);
                cost.incrementTreasury(myCost);
                wp.getCost().incrementTreasury(myCost);
                Resources req = new Resources.ResourceBuilder().treasury(myCost).build();
                p.getSecurityStrategy().addSupplemental(wp,req);
            }

        }
    }

    public void updateForSave(WorldOrder wo) {
        Long week = wo.getWeekNumber();
        this.until = week;
        double mag = 0.0;
        double cos = 0.0;
        for (WarParticipationFact f : participations) {
            mag += f.getCost().getPax();
            cos += f.getCost().getTreasury();
            f.setUntil(week);
            f.setDurationMonths((this.from - this.until) / 4.33);
        }
        warFact.setMagnitude(mag);
        warFact.setFinalCost(cos);
        warFact.setUntil(week);
        warFact.setExtent(participations.size());
        warFact.setDurationMonths((this.from - this.until) / 4.33);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        War war = (War) o;

        if (getId() != null ? !getId().equals(war.getId()) : war.getId() != null) return false;
        return getWarFact() != null ? getWarFact().equals(war.getWarFact()) : war.getWarFact() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + (getWarFact() != null ? getWarFact().hashCode() : 0);
        return result;
    }
}
