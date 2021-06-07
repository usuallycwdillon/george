package edu.gmu.css.data;

import edu.gmu.css.entities.WarParticipationFact;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.relations.ProcessDisposition;
import org.apache.commons.lang3.tuple.ImmutablePair;
import java.util.Deque;
import java.util.LinkedList;
import java.util.concurrent.RecursiveTask;


public class SecurityStrategy {
    Resources baseline;
    Resources militaryStrategy;
    Resources foreignStrategy;
    Double costPerPax;
    Deque<ImmutablePair<Object, Resources>> supplementals;


    public SecurityStrategy(Resources b) {
        this.baseline = b; // Military strategy and foreign strategy sum
        this.militaryStrategy = new Resources.ResourceBuilder().build();
        this.foreignStrategy = new Resources.ResourceBuilder().build();
        this.supplementals = new LinkedList<>();
        militaryStrategy.increaseBy(baseline.dividedBy(1.1));
        foreignStrategy.increaseBy(baseline.dividedBy(11.0));
        resetBaseline();
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

}
