package edu.gmu.css.entities;

import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class UrbanPopulationFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    Double value;

    @Relationship(type = "URBAN_POPULATION", direction = Relationship.INCOMING)
    Polity polity;
//    @Relationship(type = "DURING")
//    Year year;
//    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
//    Dataset dataset;

    public UrbanPopulationFact() {

    }

    public UrbanPopulationFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.polity = builder.polity;
        this.year = builder.year;
        this.subject = polity.getName();
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.value = builder.value;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated Urban Population Fact";
        private String subject = "Not Collected";
        private String predicate = "URBAN_POPULATION";
        private String object = "";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Double value = 0.0;
        private Polity polity;
        private Year year;

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

        public FactBuilder value(Double d) {
            this.value = d;
            return this;
        }

        public FactBuilder year(Year y) {
            this.year = y;
            return this;
        }

        public UrbanPopulationFact build() {
            return new UrbanPopulationFact(this);
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

    public Year getYear() {
        if (this.year==null) {
            this.year = new FactServiceImpl().getRelatedYear(this);
        }
        return this.year;
    }

    public void setYear(Year y) {
        this.year = y;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (super.equals(o)) return false;
        UrbanPopulationFact that = (UrbanPopulationFact) o;
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
