package edu.gmu.css.entities;

import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;

public class DisputeParticipationFact extends Fact {

    @Id
    @GeneratedValue
    Long id;

    public DisputeParticipationFact() {

    }

    public DisputeParticipationFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated Inter-state War";
        private String subject = "Not Collected";
        private String predicate = "";
        private String object = "";
        private String source = "GEORGE_";
        private Dataset dataset;

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

        public DisputeParticipationFact build() {
            return new DisputeParticipationFact(this);
        }
    }

    @Override
    public Long getId() {
        return id;
    }

//    public Year getYear() {
//        if (this.year==null) {
//            this.year = new FactServiceImpl().getRelatedYear(this);
//        }
//        return this.year;
//    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DisputeParticipationFact)) return false;
        if (!super.equals(o)) return false;

        DisputeParticipationFact fact = (DisputeParticipationFact) o;

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
