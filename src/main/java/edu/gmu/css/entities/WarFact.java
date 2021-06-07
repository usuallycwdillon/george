package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class WarFact extends Fact {

    @Id @GeneratedValue Long id;
    @Property private double magnitude;
    @Property private double concentration;
    @Property private double durationMonths;
    @Property private double maxTroops;
    @Property private int extent;
    @Property private double finalCost;
    @Property private char fiat;

    @Relationship (type = "IS_WAR", direction = Relationship.INCOMING)
    War war;


    public WarFact() {

    }


    public WarFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.war = builder.war;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
        this.finalCost = builder.finalCost;
        this.magnitude = builder.magnitude;
        this.fiat = builder.fiat;

    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private War war;
        private String name = "Simulated Inter-state War";
        private String subject = "Not Collected";
        private String predicate = "IS_WAR";
        private String object = "Simulated Inter-state Wars List";
        private String source = "GEORGE_";
        private Dataset dataset;
        private double finalCost;
        private double magnitude;
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
            this.source = s;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            return this;
        }

        public FactBuilder fiat(char s) {
            this.fiat = s;
            return this;
        }

        public String getPredicate() {
            return predicate;
        }

        public FactBuilder war(War w) {
            this.war = w;
            return this;
        }

        public FactBuilder finalCost(double d) {
            this.finalCost = d;
            return this;
        }

        public FactBuilder magnitude(double d) {
            this.magnitude = d;
            return this;
        }

        public WarFact build() {
            return new WarFact(this);
        }

    }


    @Override
    public Long getId() {
        return id;
    }

    public void setWar(War w) {
        this.war = w;
    }

    public War getWar() {
        return this.war;
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

    public double getMaxTroops() {
        return maxTroops;
    }

    public void setMaxTroops(double maxTroops) {
        this.maxTroops = maxTroops;
    }

    public int getExtent() {
        return extent;
    }

    public void setExtent(int extent) {
        this.extent = extent;
    }

    public double getFinalCost() {
        return finalCost;
    }

    public void setFinalCost(double finalCost) {
        this.finalCost = finalCost;
    }

    public char getFiat() {
        return fiat;
    }

    public void setFiat(char fiat) {
        this.fiat = fiat;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof WarFact)) return false;
        if (!super.equals(o)) return false;

        Fact fact = (Fact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

//    @Override
//    public int hashCode() {
//        int result = getId().hashCode();
//        result = 31 * result + getName().hashCode();
//        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
//        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
//        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
//        return result;
//    }
}
