package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class ProductionFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    Double value;
    @Property
    String anomaly;
    @Property
    String denomination;
    @Property
    String notes;

    @Relationship(type = "IRON_STEEL_PRODUCTION", direction = Relationship.INCOMING)
    Polity polity;


    public ProductionFact() {

    }

    public ProductionFact(FactBuilder builder) {this.from = builder.from;
        this.until = builder.until;
        this.polity = builder.polity;
        this.subject = polity.getName();
        this.predicate = "MILEX";
        this.object = builder.object;
        this.value = builder.value;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
        this.value = builder.value;

    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated Military Expenditures";
        private String subject = "Not Collected";
        private String predicate = "MILEX";
        private String object = "";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Double value;
        private Polity polity;

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

        public FactBuilder value(Double d) {
            this.value = d;
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            return this;
        }

        public ProductionFact build() {
            return new ProductionFact(this);
        }
    }



    @Override
    public Long getId() {
        return id;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public String getAnomaly() {
        return anomaly;
    }

    public void setAnomaly(String anomaly) {
        this.anomaly = anomaly;
    }

    public String getDenomination() {
        return denomination;
    }

    public void setDenomination(String denomination) {
        this.denomination = denomination;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ProductionFact)) return false;
        if (!super.equals(o)) return false;

        ProductionFact fact = (ProductionFact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = getId().hashCode();
        result = 31 * result + getName().hashCode();
        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }
}
