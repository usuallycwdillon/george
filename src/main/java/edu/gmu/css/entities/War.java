package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Process;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
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
    @Transient private Resources involvement;
    @Transient private boolean ceasefire = false;
    @Transient private int battleAttempts = 0;
    @Transient private Tile location;
    @Property private double warCost = 0.0;
    @Property private double magnitude = 0.0;

    @Relationship (type = "PARTICIPATED_IN", direction = Relationship.INCOMING)
    private final List<WarParticipationFact> participations = new LinkedList<>();
    @Relationship (type = "IS_WAR")
    private WarFact warFact;

    public War() {
        name = "War";
        cost = new Resources.ResourceBuilder().build();
        involvement = new Resources.ResourceBuilder().build();
        domain = Domain.WAR;
        strength = 1.0;
    }

    public War(Process proc, long s) {
        this();
        this.cause = proc;
        this.cost.increaseBy(cause.getCost());
        this.involvement.increaseBy(cause.getInvolvement());
        this.issue = proc.getIssue();
        this.from = s;
        this.until = s + 1L;
    }


    @Override
    public void step(SimState simState) {
        if(stopped) {
           stopper.stop();
           return;
        }
        WorldOrder worldOrder = (WorldOrder) simState;
        // 1. Do any participants ...need peace?
        for (WarParticipationFact p : participations) {
            ProcessDisposition pd = p.getDisposition();
            if ( Objects.isNull(p.getCommitment() ) ) {
                if(!pd.atN() || !pd.atU()) {
                    pd.developDisposition((WarProcess) this.cause, worldOrder);
                } else {
                    p.getPolity().surrender(p.getDisposition(), worldOrder);
                }
                // TODO: if the attacker objective is to conquer, move this state out of the system, and merge
                // it with the attacking state.
                return;
            } else {
                if (!pd.getMobilized().isEmpty()) {
                    p.getCommitment().increaseBy(pd.getMobilized());
                    pd.getMobilized().zeroize();
                }
                consumeResources(worldOrder, p);
            }

            if (p.getCommitment().getTreasury() < 0.0) {
                System.out.println("Why is this negative? The security implementation process should correct it. \n" +
                        "Financial commitment is: " + pd.getCommitment().getTreasury() + "\n" +
                        "...and State resources are: " + p.getPolity().getResources().getTreasury() );
                pd.getOwner().evaluateNeedForPeace(worldOrder, this.cause.getIssue());
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

    @Override
    public String getReferenceName() {
        return super.referenceName;
    }

    public double estimateBattleDeaths(int e, int d, MersenneTwisterFast r) {
        /**
         * Cioffi-Revilla, Claudio. 1991. “On the Likely Magnitude , Extent , and Duration of an Iraq-UN War.”
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
        int five = 0;
        int marching = 0;
        int side1 = 0;
        int side0 = 0;
        Resources attackers = new Resources.ResourceBuilder().build();
        Resources defenders = new Resources.ResourceBuilder().build();
        if (attackers.getPax() <= 0.0 && defenders.getPax() <= 0.0) {
            return;
        }
        Resources currentInvolvement = new Resources.ResourceBuilder().build();
        for (WarParticipationFact wp : participations) {
            int o = wp.getDisposition().getObjective() != null ? wp.getDisposition().getObjective().value : -3;
            if (wp.getCommitment().getPax() == 0.0) {
                ProcessDisposition pd = wp.getDisposition();
                WarProcess proc = (WarProcess) pd.getProcess();
                if(!pd.atN() || !pd.atU()) {
                    pd.developDisposition(proc, worldOrder);
                } else {
                    wp.getPolity().surrender(wp.getDisposition(), worldOrder);
                }
            }
            if (wp.isInitiated()) {
                String address = (String) wp.getDisposition().getAttackPath(worldOrder).get("last");
                location = worldOrder.getTiles().get(address);
            }
            Resources thisInvolvement = wp.getCommitment();
            if (wp.getSide() == 0) {
                currentInvolvement.increaseBy(thisInvolvement);
                attackers.increaseBy(thisInvolvement);
                side0 += 1;
                if (wp.getDisposition().getUt() > 0) {
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

        // potential battle magnitude
        Long d = worldOrder.getWeekNumber() - from;
        double fatalities = estimateBattleDeaths(participations.size(), d.intValue(), worldOrder.random);

        // calculate ratio of losses between sides
        double attackForceConcentration = new Lanchester(attackers, defenders).calculateAttackForceConcentration();
        // handle fringe cases
        if (attackForceConcentration == -1) {
            // Can't attack: no forces. Defender wins war (if they have forces)
            for (WarParticipationFact wp : participations) {
                if (wp.getSide()==0) {
                    if (attackers.getPax() > 0.0 && battleAttempts < 5) {
                        battleAttempts += 1;
                        return;
                    }
                    if (defenders.getPax() > 0.0) {
                        wp.acceptDefeat(worldOrder);
                        wp.getDisposition().getProcess().setOutcome(true);
                    }
                }
            }
        }
        if (attackForceConcentration == -9) {
            // Can't defend: mo forces. This was a route by the attacker. Defender takes losses and loses the war.
            double lossRate = worldOrder.random.nextDouble(true,true);
            double decimation = Math.max(defenders.getPax() * lossRate , fatalities);
            for (WarParticipationFact wp : participations) {
                double myPax = wp.getPolity().getResources().getPax();
                double myShare = defenders.getPax() > 0.0 ? myPax / defenders.getPax() : 1.0;
                double myLoss = Math.min(myPax, (decimation * myShare));
                wp.getCost().incrementPax(myLoss);
                wp.getPolity().getResources().decrementPax(myLoss);
                cost.incrementPax(myLoss);
                ProcessDisposition pd = wp.getDisposition();
                if (!pd.atU()) pd.getProcess().setOutcome(true);
                if (pd.atU() && pd.getUt() > 3) wp.getPolity().surrender(pd, worldOrder);
                if (location!=null) {
                    double popLoss = Math.min(100, location.getPopulationTrans());
                    popLoss = Math.max(location.getPopulationTrans() * 0.005, popLoss);
                    double uPopLoss = Math.min(popLoss, location.getUrbanPopTrans());
                    uPopLoss = Math.max(location.getUrbanPopTrans() * 0.010, uPopLoss);
                    double builtLoss = Math.min(2.0, location.getBuiltUpArea());
                    builtLoss = Math.max(location.getBuiltUpArea() * 0.005, builtLoss);
                    if (popLoss > 0.0) location.setPopulationTrans(location.getPopulationTrans() - popLoss);
                    if (uPopLoss > 0.0) location.setUrbanPopTrans(location.getPopulationTrans() - uPopLoss);
                    if (builtLoss > 0.0) location.setBuiltUpArea(location.getBuiltUpArea() - builtLoss);
                }
            }
        }


        double fatalitiesSide0;
        if (attackForceConcentration > 1.0) {
            fatalitiesSide0 = fatalities / (attackForceConcentration + 1.0);
        } else {
            fatalitiesSide0 = fatalities - (fatalities / ( (1.0 / attackForceConcentration) + 1.0));
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

    private void consumeResources(WorldOrder wo, WarParticipationFact wp) {
        int weeks = wo.dataYear.getWeeksThisYear();
        Polity p = wp.getPolity();
        Resources c = wp.getCommitment();
        if (!Objects.isNull(c)) {
            double myCost = c.getPax() * c.getCostPerPax() / weeks;
            c.decrementTreasury(myCost);
            this.cost.incrementTreasury(myCost);
            wp.getCost().incrementTreasury(myCost);
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
            f.setDurationMonths((this.until - this.from) / 4.33);
        }
        warFact.setMagnitude(mag);
        warFact.setFinalCost(cos);
        warFact.setUntil(week);
        warFact.setExtent(participations.size());
        warFact.setDurationMonths((this.until - this.from) / 4.33);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        War that = (War) o;

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
