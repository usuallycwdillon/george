package edu.gmu.css.entities;

import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class DisputeFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property private String notes;
    @Property private char fiat;
    @Property private double magnitude;
    @Property private double finalCost;

    @Relationship (type = "ABOUT")
    Dispute dispute;
    @Relationship(type = "ESCALATED_TO")
    protected WarFact war;


    public DisputeFact() {
    }

    public DisputeFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
        this.dispute = builder.dispute;
        this.fiat = builder.fiat;


        if (this.from == null && this.until != null) {
            this.from = this.until - 1L;
        }
        if (this.from != null && this.until == null) {
            this.until = this.from + 1L;
        }
        if (this.from == null && this.until == null) {
            this.from = 0L;
            this.until = 0L;
        }
    }

    public static class FactBuilder {
        private Long from;
        private Long until;
        private String name = "Dispute Fact";
        private String subject = "Not Collected";
        private String predicate = "ABOUT";
        private String object = "";
        private Dataset dataset;
        private Dispute dispute;
        private String source;
        private String notes;
        private char fiat;

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
            this.source = "GEORGE_" + s;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            this.source = "GEORGE_" + d.getName();
            return this;
        }

        public FactBuilder dispute(Dispute d) {
            this.dispute = d;
            return this;
        }

        public FactBuilder notes(String n) {
            this.notes = n;
            return this;
        }

        public FactBuilder fiat(char s) {
            this.fiat = s;
            return this;
        }

        public DisputeFact build() {
            return new DisputeFact(this);
        }
    }


    @Override
    public Long getId() {
        return this.id;
    }

    public Dispute getDispute() {
        return dispute;
    }

    public void setDispute(Dispute dispute) {
        this.dispute = dispute;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public void setFiat(char s) {
        this.fiat = s;
    }

    public WarFact getWar() {
        return war;
    }

    public void setWar(WarFact war) {
        this.war = war;
    }

    public double getMagnitude() {
        return magnitude;
    }

    public void setMagnitude(double magnitude) {
        this.magnitude = magnitude;
    }

    public double getFinalCost() {
        return finalCost;
    }

    public void setFinalCost(double finalCost) {
        this.finalCost = finalCost;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
//        if (super.equals(o)) return false;
        DisputeFact that = (DisputeFact) o;
        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        if (!getSubject().equals(that.getSubject())) return false;
        if (!getPredicate().equals(that.getPredicate())) return false;
        return getObject() != null ? getObject().equals(that.getObject()) : that.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getSubject().hashCode();
        result = 31 * result + getPredicate().hashCode();
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }

}
