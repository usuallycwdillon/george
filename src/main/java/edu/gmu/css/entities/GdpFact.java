package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class GdpFact extends Fact {

    @Id @GeneratedValue
    private Long id;
    @Property private String currency = "2013 GK Dollars";
    @Property private Double value;
    @Property private int factor;

    @Relationship(type = "PRODUCED", direction = Relationship.INCOMING)
    Polity polity;
    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
    Dataset dataset;

    public GdpFact() {

    }

    private GdpFact(FactBuilder builder) {
        this.name = builder.name;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.source = builder.source;
        this.value = builder.value;
        this.from = builder.from;
        this.until = builder.until;
        this.factor = builder.factor;
        this.polity = builder.polity;
        this.dataset = builder.dataset;
        this.simulationRun = builder.dataset.getName();
        this.during = Long.parseLong(object);
    }

    public static class FactBuilder {
        private String name = "GDP Fact";
        private String subject = "Not Collected";
        private String predicate = "PRODUCED";
        private String object = "";
        private String source = "GEORGE_";
        private Double value = 0.0;
        private int factor = 1000;
        private Long from = 0L;
        private Long until = 0L;
        private Polity polity;
        private Dataset dataset;

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

        public FactBuilder factor(int f) {
            this.factor = f;
            return this;
        }

        public GdpFact build() {
            return new GdpFact(this);
        }

    }

    @Override
    public Long getId() {
        return id;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

//    @Override
//    public String getName() {
//        return name;
//    }

//    @Override
//    public void setName(String name) {
//        this.name = name;
//    }

//    @Override
//    public String getSubject() {
//        return subject;
//    }

//    @Override
//    public void setSubject(String subject) {
//        this.subject = subject;
//    }

//    @Override
//    public String getPredicate() {
//        return predicate;
//    }

//    @Override
//    public void setPredicate(String predicate) {
//        this.predicate = predicate;
//    }

//    @Override
//    public String getObject() {
//        return object;
//    }

//    @Override
//    public void setObject(String object) {
//        this.object = object;
//    }

//    @Override
//    public String getSource() {
//        return source;
//    }

//    @Override
//    public void setSource(String source) {
//        this.source = source;
//    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

//    @Override
//    public Long getDuring() {
//        return this.during;
//    }

//    public void setDuring(Long during) {
//        this.during = during;
//    }

    public int getFactor() {
        return factor;
    }

    public void setFactor(int factor) {
        this.factor = factor;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

//    @Override
//    public Dataset getDataset() {
//        return dataset;
//    }

//    @Override
//    public void setDataset(Dataset dataset) {
//        this.dataset = dataset;
//    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        GdpFact gdpFact = (GdpFact) o;

        if (!getId().equals(gdpFact.getId())) return false;
        if (!getName().equals(gdpFact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(gdpFact.getSubject()) : gdpFact.getSubject() != null)
            return false;
        if (getPredicate() != null ? !getPredicate().equals(gdpFact.getPredicate()) : gdpFact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(gdpFact.getObject()) : gdpFact.getObject() == null;
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
