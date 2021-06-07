package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class ImportFromFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    String currency;
    @Property
    Double smoothedTotalTrading;
    @Property
    Double smootedValue;
    @Property
    Integer spike;
    @Property
    Integer tradeSpike;
    @Property
    Integer tradeDip;
    @Property
    Integer dip;
    @Property
    Double value;

    @Relationship(type = "IMPORTED", direction = Relationship.INCOMING)
    Polity importer;
    @Relationship(type = "IMPORTED_FROM")
    Polity exporter;


    public ImportFromFact() {

    }

    public ImportFromFact(FactBuilder builder) {
        this.from = builder.from;
        this.importer = builder.importer;
        this.exporter = builder.exporter;
        this.subject = builder.subject;
        this.predicate = "IMPORTED";
        this.object = builder.object;
        this.value = builder.value;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated Imports";
        private Polity importer;
        private Polity exporter;
        private String subject = importer.getName()!=null ? importer.getName() : "Not collected";
        private String predicate = "IMPORTED";
        private String object = exporter.getName()!=null ? exporter.getName() : "Not collected";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Year year;
        private Double value;

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

        public FactBuilder importer(Polity p) {
            this.importer = p;
            this.source = importer.getName();
            return this;
        }

        public FactBuilder exporter(Polity p) {
            this.exporter = p;
            this.object = exporter.getName();
            return this;
        }

        public FactBuilder year(Year y) {
            this.year = y;
            return this;
        }

        public ImportFromFact build() {
            return new ImportFromFact(this);
        }
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getCurrency() {
        return currency;
    }

    public Double getSmoothedTotalTrading() {
        return smoothedTotalTrading;
    }

    public Double getSmootedValue() {
        return smootedValue;
    }

    public Integer getSpike() {
        return spike;
    }

    public Integer getTradeSpike() {
        return tradeSpike;
    }

    public Integer getTradeDip() {
        return tradeDip;
    }

    public Integer getDip() {
        return dip;
    }

    public Double getValue() {
        return value;
    }

    public Polity getImporter() {
        return importer;
    }

    public Polity getExporter() {
        return exporter;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public void setImporter(Polity importer) {
        this.importer = importer;
    }

    public void setExporter(Polity exporter) {
        this.exporter = exporter;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ImportFromFact)) return false;
        if (!super.equals(o)) return false;

        ImportFromFact fact = (ImportFromFact) o;

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
