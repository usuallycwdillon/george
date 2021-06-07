package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Relationship;

public class IgoFact extends Fact {

    @Id
    @GeneratedValue
    Long id;

    @Relationship(type = "FORMED", direction = Relationship.INCOMING)
    Organization igo;

    public IgoFact() {

    }

    public IgoFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.igo = builder.igo;
        this.subject = builder.subject;
        this.predicate = "FORMED";
        this.object = builder.object;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated IGO Formation";
        private String subject = "Not Collected";
        private String predicate = "FORMED";
        private String object = "";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Organization igo;

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

        public FactBuilder igo(Organization o) {
            this.igo = o;
            this.igo.getName();
            return this;
        }

        public IgoFact build() {
            return new IgoFact(this);
        }
    }



    @Override
    public Long getId() {
        return id;
    }

    public Organization getIgo() {
        return igo;
    }

    public void setIgo(Organization igo) {
        this.igo = igo;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof IgoFact)) return false;
        if (!super.equals(o)) return false;

        IgoFact fact = (IgoFact) o;

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
