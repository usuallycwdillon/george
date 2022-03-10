package edu.gmu.css.entities;

import edu.gmu.css.agents.Issue;
import edu.gmu.css.data.DataTrend;
import edu.gmu.css.data.IssueType;
import edu.gmu.css.data.Resources;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.FactServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;

@NodeEntity
public class WarParticipationFact extends Fact {

    @Id @GeneratedValue private Long id;
    @Property private double magnitude;
    @Property private double concentration;
    @Property private double durationMonths;
    @Property private double maxTroops;
    @Property private double finalCost;
    @Property private boolean initiated;
    @Property private int side;
    @Property private char fiat = 'x';
    @Transient private Resources commitment = new Resources.ResourceBuilder().build(); // see, totally empty.
    @Transient private Resources cost;
    @Transient private final DataTrend battleHistory = new DataTrend(10);
    @Transient private SecurityObjective goal;
    @Transient private ProcessDisposition disposition;

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
        this.disposition = builder.disposition;
        this.initiated = builder.initiated;
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
        private String source = "";
        private Dataset dataset;
        private Resources commitment = new Resources.ResourceBuilder().build();
        private Resources cost = new Resources.ResourceBuilder().build();
        private int side;
        private boolean initiated;
        private SecurityObjective goal;
        private ProcessDisposition disposition;


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
            this.subject = p.getName();
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

        public FactBuilder disposition(ProcessDisposition p) {
            this.disposition = p;
            return this;
        }

        public FactBuilder initiated(boolean b) {
            this.initiated = b;
            return this;
        }

        public WarParticipationFact build() {
            return new WarParticipationFact(this);
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

    public ProcessDisposition getDisposition() {
        return disposition;
    }

    public SecurityObjective getGoal() {
        return goal;
    }

    public void setGoal(SecurityObjective goal) {
        this.goal = goal;
    }

    public char getFiat() {
        return fiat;
    }

    public void setFiat(char fiat) {
        this.fiat = fiat;
    }

    public boolean isInitiated() {
        return initiated;
    }

    public void setInitiated(boolean initiated) {
        this.initiated = initiated;
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

    public double getBattleTrend() {
        if (battleHistory.size()==0) return 0.0;
        return battleHistory.average();
    }

    public void acceptDefeat(WorldOrder wo) {
        for (ProcessDisposition d : polity.getProcessList()) {
            if (war.getName().equals(d.getSubject())) {
                d.setN(true);
            } else {
                createPeaceIssue(wo);
            }
            d.getProcess().setOutcome(true);
            polity.acquiesce(d, wo);
        }
    }

    public void tallyLosses(double l, boolean w, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        double pLoss = l;
        double lossRatio = l / commitment.getPax();
        double forceRatio = l / polity.getMilitaryStrategy().getPax();
        double tLoss = commitment.getCostPerPax() * pLoss;
        boolean winner = w;
        if (winner) {
            battleHistory.add(pLoss);
        } else {
            battleHistory.add(-pLoss);
            // If there isn't already a peace process for this war, the pd is null
            for (ProcessDisposition d : polity.getProcessList()) {
                if (war.equals(d.getSubject())) {
                    d.setN(true);
                } else {
                    createPeaceIssue(worldOrder);
                }
            }
        }

        Resources loss = new Resources.ResourceBuilder().pax(pLoss).treasury(tLoss).build();
        if (!loss.isEmpty()) {
            cost.increaseBy(commitment.minimumBetween(loss));
            commitment.reduceToNoLessThanZero(loss);
        }

        magnitude += pLoss;
        if (lossRatio > 0.333 || forceRatio > 0.50 || commitment.getTreasury() <= 0.0) {
            polity.surrender(disposition, worldOrder);
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
        Issue peace = new Issue.IssueBuilder()
                .from(wo.getStepNumber())
                .claimant(polity)
                .target(opponent)
                .issueType(IssueType.PEACE)
                .duration(2)
                .cause(war)
                .build();
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

    @Override
    public int hashCode() {
        int result = getName().hashCode();
        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }


}
