package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class ImportsFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    Double value;


    @Relationship(type="IMPORTS", direction = Relationship.INCOMING)
    Polity polity;
    @Relationship(type="CONTRIBUTES", direction = Relationship.INCOMING)
    Dataset dataset;
    @Relationship(type="DURING", direction = Relationship.INCOMING)
    Year year;

    public ImportsFact() {

    }

    public ImportsFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.polity = builder.polity;
        this.subject = builder.subject;
        this.predicate = "IMPORTS";
        this.object = builder.object;
        this.value = builder.value;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private Polity polity;
        private String name = "Simulated Imports Fact";
        private String subject = "Not Collected";
        private String predicate = "IMPORTS";
        private String object = "";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Double value = 0.0;

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
            this.subject = polity.getName();
            return this;
        }

        public ImportsFact build() {
            return new ImportsFact(this);
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
    public Year getYear() {
        return year;
    }

    public void setYear(Year year) {
        this.year = year;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ImportsFact)) return false;
        if (!super.equals(o)) return false;

        ImportsFact fact = (ImportsFact) o;

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
