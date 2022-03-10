package edu.gmu.css.data;

import edu.gmu.css.entities.WarParticipationFact;
import org.apache.commons.lang3.tuple.ImmutablePair;

import java.util.Deque;
import java.util.LinkedList;
import java.util.Objects;


public class SecurityStrategy {
    Resources baseline;
    Resources militaryStrategy;
    Resources foreignStrategy;
    Double costPerPax = 0.0;
    Double weeklyDeterrenceCost;
    Double weeklyForeignPolicyCost;
    Deque<ImmutablePair<Object, Resources>> supplementals;


    public SecurityStrategy(Resources b) {
        this.baseline = b; // Military strategy and foreign strategy sum
        this.militaryStrategy = new Resources.ResourceBuilder().build();
        this.foreignStrategy = new Resources.ResourceBuilder().build();
        this.supplementals = new LinkedList<>();
        this.militaryStrategy.increaseBy(baseline);
        this.militaryStrategy.setSufficient(true);
        this.weeklyDeterrenceCost = militaryStrategy.getTreasury() / 52.0;
        this.foreignStrategy.increaseBy(baseline.dividedBy(11.0));
        this.foreignStrategy.setSufficient(true);
        this.weeklyForeignPolicyCost = foreignStrategy.getTreasury() / 52.0;
        this.resetBaseline();
        if ( baseline.getPax() > 0.0 && baseline.getTreasury() > 0.0) {
            this.costPerPax = baseline.getTreasury() / baseline.getPax();
        } else {
            this.costPerPax = 1.0;
        }
    }

    public Resources getBaseline() {
        return this.baseline;
    }

    public Resources getMilitaryStrategy() {
        return militaryStrategy;
    }

    public void setMilitaryStrategy(Resources militaryStrategy) {
        this.militaryStrategy = militaryStrategy;
    }

    public Resources getForeignStrategy() {
        return foreignStrategy;
    }

    public void setForeignStrategy(Resources foreignStrategy) {
        this.foreignStrategy = foreignStrategy;
    }

    public Deque<ImmutablePair<Object, Resources>> getSupplementals() {
        return this.supplementals;
    }

    public Resources getSupplementalsSum() {
        Resources ss = new Resources.ResourceBuilder().build();
        for (ImmutablePair<Object, Resources> i : supplementals) {
            ss.increaseBy(i.getRight());
        }
        return ss;
    }

    public Double getCostPerPax() {
        return costPerPax;
    }

    public void setCostPerPax(Double costPerPax) {
        this.costPerPax = costPerPax;
    }

    public Double getWeeklyDeterrenceCost() {
        return weeklyDeterrenceCost;
    }

    public Double getWeeklyForeignPolicyCost() {
        return weeklyForeignPolicyCost;
    }

    public void setWeeklyForeignPolicyCost(Double weeklyForeignPolicyCost) {
        this.weeklyForeignPolicyCost = weeklyForeignPolicyCost;
    }

    public void setWeeklyDeterrenceCost(Double weeklyDeterrenceCost) {
        this.weeklyDeterrenceCost = weeklyDeterrenceCost;
    }

    public void replaceBaseline(Resources r) {
        this.baseline = r;
    }

    public void increaseBaseline(Resources additional) {
        this.baseline.increaseBy(additional);
    }

    public void addSupplemental(Object caller, Resources request) {
        ImmutablePair<Object, Resources> p = new ImmutablePair<Object, Resources>(caller, request);
        // War funding/recruitment takes priority over impending challenges and foreign policy costs
        if (caller.getClass() == WarParticipationFact.class) {
            this.supplementals.addFirst(p);
        } else {
            this.supplementals.addLast(p);
        }
    }

    public void renewSupplementals(Deque<ImmutablePair<Object, Resources>> q) {
        this.supplementals = q;
    }

    public void resetCostPerPax() {
        this.costPerPax = baseline.getTreasury() / baseline.getPax();
    }

    public void resetBaseline() {
        baseline = new Resources.ResourceBuilder().build();
        baseline.increaseBy(foreignStrategy);
        baseline.increaseBy(militaryStrategy);
        resetCostPerPax();
    }

    public void rebalancePolicy(SecurityPolicy p) {
        this.militaryStrategy = new Resources.ResourceBuilder().build();
        this.foreignStrategy = new Resources.ResourceBuilder().build();
        militaryStrategy = baseline.multipliedBy(p.getMilitary());
        foreignStrategy = baseline.multipliedBy(p.getForeign());
    }

    public void increaseMilitaryByForeignAffairsShare(double cut) {
        Resources fromCut = foreignStrategy.multipliedBy(cut);
        foreignStrategy.reduceBy(fromCut);
        militaryStrategy.increaseBy(fromCut);
    }

    public void increaseForeignAffairsByMilitaryShare(double cut) {
        Resources fromCut = militaryStrategy.multipliedBy(cut);
        militaryStrategy.reduceBy(fromCut);
        foreignStrategy.increaseBy(fromCut);
    }

    public Resources getTotalDemand() {
        Resources total = new Resources.ResourceBuilder().build();
        total.increaseBy(baseline);
        total.increaseBy(getSupplementalsSum());
        return total;
    }

    public Double getBaselineWeeklyCostSum() {
        return getWeeklyDeterrenceCost() + getWeeklyForeignPolicyCost();
    }

}
