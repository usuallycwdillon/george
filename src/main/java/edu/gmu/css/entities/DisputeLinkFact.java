package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Relationship;


public class DisputeLinkFact extends Fact {

    @Id @GeneratedValue private Long id;
    @Relationship (type = "LINKED_TO")
    protected Dispute nextDispute;
    @Relationship (type = "LINKED", direction = Relationship.INCOMING)
    protected Dispute priorDispute;

    public DisputeLinkFact () {

    }

    private DisputeLinkFact(FactBuilder builder) {
        this.name = "Dispute Link Fact";
        this.subject = builder.subject;
        this.predicate = "LINKED";
        this.object = builder.object;
        this.priorDispute = builder.priorDispute;
        this.nextDispute = builder.nextDispute;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private String subject;
        private String object;
        private Dispute priorDispute;
        private Dispute nextDispute;
        private Dataset dataset;

        public FactBuilder() {

        }

        public FactBuilder priorDispute(Dispute d) {
            this.priorDispute = d;
            this.subject = this.priorDispute.getName();
            return this;
        }

        public FactBuilder nextDispute(Dispute d) {
            this.nextDispute = d;
            this.object = this.nextDispute.getName();
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            return this;
        }

        public DisputeLinkFact build() {
            return new DisputeLinkFact(this);
        }
    }

    @Override
    public Long getId() {
        return this.id;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getObject() {
        return object;
    }

    public void setObject(String object) {
        this.object = object;
    }

    public Dispute getPriorDispute() {
        return priorDispute;
    }

    public void setPriorDispute(Dispute priorDispute) {
        this.priorDispute = priorDispute;
    }

    public Dispute getNextDispute() {
        return nextDispute;
    }

    public void setNextDispute(Dispute nextDispute) {
        this.nextDispute = nextDispute;
    }

    public Dataset getDataset() {
        return dataset;
    }

    public void setDataset(Dataset dataset) {
        this.dataset = dataset;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DisputeLinkFact)) return false;
        if (!super.equals(o)) return false;

        DisputeLinkFact fact = (DisputeLinkFact) o;

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
