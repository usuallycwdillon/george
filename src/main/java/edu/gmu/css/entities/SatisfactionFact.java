package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

@NodeEntity
public class SatisfactionFact extends Fact {

    @Id @GeneratedValue private Long id;
    @Property private Double value;

    @Relationship(type = "SATISFACTION", direction = Relationship.INCOMING)
    Polity polity;
    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
    Dataset dataset;

    public SatisfactionFact() {

    }

    private SatisfactionFact(FactBuilder builder) {
        this.name = builder.name;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.source = builder.source;
        this.value = builder.value;
        this.from = builder.from;
        this.until = builder.until;
        this.polity = builder.polity;
        this.dataset = builder.dataset;
        this.simulationRun = builder.dataset.getName();
        this.during = Long.parseLong(object);
    }

    public static class FactBuilder {
        private final String name = "Satisfaction Fact";
        private String subject = "Not Collected";
        private String predicate = "SATISFACTION";
        private String object = "";
        private String source = "GEORGE_";
        private Double value = 0.0;
        private Long from = 0L;
        private Long until = 0L;
        private Polity polity;
        private Dataset dataset;


        public FactBuilder predicate(String predicate) {
            this.predicate = predicate;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            this.source = d.getName();
            return this;
        }

        public FactBuilder value(Double d) {
            this.value = d;
            return this;
        }

        public FactBuilder during(Year y) {
            this.from = y.getBegan();
            this.until = y.getEnded();
            this.object = y.getName();
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            this.subject = p.getName();
            return this;
        }

        public SatisfactionFact build() {
            return new SatisfactionFact(this);
        }
    }


    @Override
    public Long getId() {
        return this.id;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    @Override
    public Dataset getDataset() {
        return dataset;
    }

    @Override
    public void setDataset(Dataset dataset) {
        this.dataset = dataset;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        SatisfactionFact fact = (SatisfactionFact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null)
            return false;
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
