package edu.gmu.css.entities;

import edu.gmu.css.data.Resources;
import edu.gmu.css.relations.ProcessDisposition;
import org.neo4j.ogm.annotation.*;

import static java.lang.Boolean.FALSE;

public class DisputeParticipationFact extends Fact {

    @Id @GeneratedValue private Long id;
    @Property private String fatalityLevel;
    @Property private String highestAction;
    @Property private String hostilityLevel;
    @Property private Double preciseFatalities;
    @Property private boolean originatedDispute;
    @Property private boolean sideA;
    @Property private String fiat;
    @Transient private Resources cost;
    @Transient private Resources commitment;
    @Transient private ProcessDisposition disposition;

    @Relationship private Polity polity;
    @Relationship private Dispute dispute;


    public DisputeParticipationFact() {

    }

    public DisputeParticipationFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.name = builder.name;
        this.dataset = builder.dataset;
        this.source = builder.source;
        this.fatalityLevel = builder.fatalityLevel;
        this.highestAction = builder.highestAction;
        this.preciseFatalities = builder.preciseFatalities;
        this.originatedDispute = builder.originatedDispute;
        this.sideA = builder.sideA;
        this.fiat = builder.fiat;
        this.cost = builder.cost;
        this.disposition = builder.disposition;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated Dispute Participation";
        private String subject = "Not Collected";
        private String predicate = "DISPUTED";
        private String object = "";
        private Dataset dataset;
        private String source = "GEORGE_";
        private String fatalityLevel = " deaths";
        private String highestAction = "Clash";
        private Boolean sideA = FALSE;
        private Boolean originatedDispute = FALSE;
        private Resources cost = new Resources.ResourceBuilder().build();
        private Resources commitment = new Resources.ResourceBuilder().build();
        private Double preciseFatalities = cost.getPax();
        private String fiat;
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
            this.source = "GEORGE_" + dataset.getName();
            return this;
        }

        public FactBuilder fatalityLevel(String s) {
            this.fatalityLevel = s;
            return this;
        }

        public FactBuilder highestAction(String s) {
            this.highestAction = s;
            return this;
        }

        public FactBuilder preciseFatalities(double i) {
            this.preciseFatalities = i;
            return this;
        }

        public FactBuilder sideA(Boolean b) {
            this.sideA = b;
            return this;
        }

        public FactBuilder originatedDispute(Boolean b) {
            this.originatedDispute = b;
            return this;
        }

        public FactBuilder fiat(String s) {
            this.fiat = s;
            return this;
        }

        public FactBuilder disposition(ProcessDisposition p) {
            this.disposition = p;
            return this;
        }

        public FactBuilder cost(Resources r) {
            this.cost = r;
            this.preciseFatalities = r.getPax();
            return this;
        }

        public FactBuilder commitment(Resources r) {
            this.commitment = r;
            return this;
        }


        public DisputeParticipationFact build() {
            return new DisputeParticipationFact(this);
        }
    }

    public String getFatalityLevel() {
        return fatalityLevel;
    }

    public void setFatalityLevel(String fatalityLevel) {
        this.fatalityLevel = fatalityLevel;
    }

    public String getHighestAction() {
        return highestAction;
    }

    public void setHighestAction(String highestAction) {
        this.highestAction = highestAction;
    }

    public String getHostilityLevel() {
        return hostilityLevel;
    }

    public void setHostilityLevel(String hostilityLevel) {
        this.hostilityLevel = hostilityLevel;
    }

    public Double getPreciseFatalities() {
        return preciseFatalities;
    }

    public void setPreciseFatalities(Double preciseFatalities) {
        this.preciseFatalities = preciseFatalities;
    }

    public boolean isOriginatedDispute() {
        return originatedDispute;
    }

    public void setOriginatedDispute(boolean originatedDispute) {
        this.originatedDispute = originatedDispute;
    }

    public boolean isSideA() {
        return sideA;
    }

    public void setSideA(boolean sideA) {
        this.sideA = sideA;
    }

    public Resources getCost() {
        return cost;
    }

    public void setCost(Resources cost) {
        this.cost = cost;
    }

    public void commitMore(Resources additional) {
        commitment.increaseBy(additional);
    }

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }

    public void setFiat(String s) {
        this.fiat = s;
    }

    public ProcessDisposition getDisposition() {
        return disposition;
    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DisputeParticipationFact)) return false;
        if (!super.equals(o)) return false;

        DisputeParticipationFact fact = (DisputeParticipationFact) o;

        if (getId() != null ? !getId().equals(fact.getId()) : fact.getId() != null) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getName().hashCode();
        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }



}
