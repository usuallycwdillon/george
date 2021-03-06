package edu.gmu.css.entities;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.data.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.FactServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.lang3.ObjectUtils;
import org.neo4j.ogm.annotation.*;

public class WarParticipationFact extends Fact {

    @Id @GeneratedValue
    Long id;
    @Property
    private double magnitude;
    @Property
    private double concentration;
    @Property
    private double durationMonths;
    @Property
    private double maxTroops;
    @Property
    private double finalCost;
    @Property
    private int side;
    @Transient
    private Resources commitment;
    @Transient
    private Resources cost;
    @Transient
    private final DataTrend battleHistory = new DataTrend(10);
    @Transient
    private SecurityObjective goal;

    @Relationship (type="PARTICIPATED", direction = Relationship.INCOMING)
    private Polity polity;
    @Relationship (type="PARTICIPATED_IN")
    private War war;

    public WarParticipationFact() {

    }

    public WarParticipationFact(FactBuilder builder) {
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.name = builder.name;
        this.from = builder.from;
        this.until = builder.until;
        this.commitment = builder.commitment;
        this.cost = builder.cost;
        this.polity = builder.polity;
        this.war = builder.war;
        this.side = builder.side;
        this.dataset = builder.dataset;
        this.goal = builder.goal;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private Polity polity;
        private War war;
        private String name = "War Participation Fact";
        private String subject = "unknown";
        private String predicate = "PARTICIPATED";
        private String object = "unknown";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Resources commitment = new Resources.ResourceBuilder().build();
        private Resources cost = new Resources.ResourceBuilder().build();
        private int side;
        private SecurityObjective goal;


        public FactBuilder from(Long from) {
            this.from = from;
            return this;
        }

        public FactBuilder until(Long until) {
            this.until = until;
            return this;
        }

        public FactBuilder name(String name) {
            this.name = name;
            return this;
        }

        public FactBuilder subject(String subject) {
            this.subject = subject;
            return this;
        }

        public FactBuilder predicate(String predicate) {
            this.predicate = predicate;
            return this;
        }

        public FactBuilder object(String object) {
            this.object = object;
            return this;
        }

        public FactBuilder source(String s) {
            this.source = s;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            return this;
        }

        public FactBuilder war(War w) {
            this.war = w;
            return this;
        }

        public FactBuilder side(int s) {
            this.side = s;
            return this;
        }

        public FactBuilder commitment(Resources r) {
            this.commitment = r;
            return this;
        }

        public FactBuilder cost(Resources r) {
            this.cost = r;
            return this;
        }

        public FactBuilder goal(SecurityObjective g) {
            this.goal = g;
            return this;
        }

        public WarParticipationFact build() {
            WarParticipationFact wpf = new WarParticipationFact(this);
            wpf.getWar().addParticipation(wpf);
            wpf.getPolity().addWarParticipationFact(wpf);
            return wpf;
        }

    }

    public Long getId() {
        return id;
    }

    public double getMaxTroops() {
        return maxTroops;
    }

    public void setMaxTroops(double maxTroops) {
        this.maxTroops = maxTroops;
    }

    public double getFinalCost() {
        return finalCost;
    }

    public void setFinalCost(double finalCost) {
        this.finalCost = finalCost;
    }

    public int getSide() {
        return side;
    }

    public void setSide(int side) {
        this.side = side;
    }

    public Resources getCost() {
        return cost;
    }

    public void setCost(Resources cost) {
        this.cost = cost;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public War getWar() {
        return war;
    }

    public void setWar(War war) {
        this.war = war;
    }

    public double getMagnitude() {
        return magnitude;
    }

    public void setMagnitude(double magnitude) {
        this.magnitude = magnitude;
    }

    public double getConcentration() {
        return concentration;
    }

    public void setConcentration(double concentration) {
        this.concentration = concentration;
    }

    public double getDurationMonths() {
        return durationMonths;
    }

    public void setDurationMonths(double durationMonths) {
        this.durationMonths = durationMonths;
    }

    public SecurityObjective getGoal() {
        return goal;
    }

    public void setGoal(SecurityObjective goal) {
        this.goal = goal;
    }

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources c) {
        this.commitment = c;
        this.maxTroops = commitment.getPax() > maxTroops ? commitment.getPax() : maxTroops;
    }

    public void commitMore(Resources additional) {
        commitment.increaseBy(additional);
    }

    public void tallyLosses(double l, boolean w, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        double pLoss = l;
        double tLoss = commitment.getCostPerPax() * pLoss;
        boolean winner = w;
        if (winner) {
            battleHistory.add(pLoss);
        } else {
            battleHistory.add(-pLoss);
        }
        Resources loss = new Resources.ResourceBuilder().pax(pLoss).treasury(tLoss).build();
        commitment.reduceBy(loss);
        cost.increaseBy(loss);
        polity.getSecurityStrategy().addSupplemental(this, loss);
        magnitude += pLoss;
        if (commitment.getPax() < 0) {
            // TODO: implement consequences for losing the war; for now, just end it.
            war.conclude(worldOrder);
            polity.surrender(this, worldOrder);
        }
        // If there isn't already a peace process for this war, the pd is null
        ProcessDisposition pd = polity.getProcessList().stream()
                .filter(d -> war.equals(d.getSubject()))
                .findAny().orElse(null);
        if (pLoss * 2 > commitment.getPax() || !winner) {
            if (pd == null) {
                createPeaceIssue(worldOrder);
            } else {
                pd.setN(true);
            }
        }
    }

    private void createPeaceIssue(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Polity opponent = new Polity();
        Double force = 0.0;
        // New peace issue between this polity and the most powerful opponent involved in the war
        for (WarParticipationFact f : war.getParticipations() ) {
            if (f.side != side) {
                Double pax = f.getCommitment().getPax();
                if (pax > force) {
                    opponent = f.getPolity();
                    force = pax;
                }
            }
        }
        Issue peace = new Issue.IssueBuilder().from(wo.getStepNumber()).instigator(polity).target(opponent)
                .issueType(IssueType.PEACE).duration(2).cause(war).build();
        peace.setStopper(worldOrder.schedule.scheduleRepeating(peace));
    }

    private void evaluateData() {

    }

    public Year getYear() {
        if (this.year==null) {
            this.year = new FactServiceImpl().getRelatedYear(this);
        }
        return this.year;
    }

    public DataTrend getBattleHistory() {
        return this.battleHistory;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof WarParticipationFact)) return false;
        if (!super.equals(o)) return false;

        WarParticipationFact fact = (WarParticipationFact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

//    @Override
//    public int hashCode() {
//        int result = getId().hashCode();
//        result = 31 * result + getName().hashCode();
//        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
//        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
//        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
//        return result;
//    }


}
