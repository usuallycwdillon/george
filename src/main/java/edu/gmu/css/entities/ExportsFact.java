package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

@NodeEntity
public class ExportsFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    Double value;
    @Property
    Double totalExports;

    @Relationship(type = "EXPORTS", direction = Relationship.INCOMING)
    Polity polity;


    public ExportsFact() {

    }

    public ExportsFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.polity = builder.polity;
        this.subject = polity.getName();
        this.predicate = "EXPORTS";
        this.object = builder.object;
        this.value = builder.value;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated Exports";
        private String subject = "Not Collected";
        private String predicate = "EXPORTS";
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

        public ExportsFact build() {
            return new ExportsFact(this);
        }
    }


    @Override
    public Long getId() {
        return id;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ExportsFact)) return false;
        if (!super.equals(o)) return false;

        ExportsFact fact = (ExportsFact) o;

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
