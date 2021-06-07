package edu.gmu.css.entities;

import edu.gmu.css.data.Resources;
import edu.gmu.css.service.DateConverter;
import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

@NodeEntity
public class Fact extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property @Convert(DateConverter.class)
    Long from;
    @Property @Convert(DateConverter.class)
    Long until;
    @Property
    Long during;
    @Property
    String name;
    @Property
    String subject;
    @Property
    String predicate;
    @Property
    String object;
    @Property
    String source;
    @Transient              //  weekly cost/commitment
    Resources maintenance = new Resources.ResourceBuilder().build();

    @Relationship(type="CONTRIBUTES", direction = Relationship.INCOMING)
    Dataset dataset;
    @Relationship(type="DURING", direction = Relationship.INCOMING)
    Year year;


    public Fact() {}


    @Override
    public Long getId() {
        return id;
    }

    public Long getFrom() {
        return from;
    }

    public void setFrom(Long from) {
        this.from = from;
    }

    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    public Long getDuring() {
        return during;
    }

    public void setDuring(long d) {
        this.during = d;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSubject() {
        return subject;
    }

    public void setPredicate(String predicate) {
        this.predicate = predicate;
    }

    public String getPredicate() {
        return predicate;
    }

    public String getObject() {
        return object;
    }

    public void setObject(String object) {
        this.object = object;
    }

    public String getSource() {
        return source;
    }

    public void setDuring(Long during) {
        this.during = during;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public void setYear(Year year) {
        this.year = year;
    }

    public Dataset getDataset() {
        return dataset;
    }

    public void setDataset(Dataset dataset) {
        this.dataset = dataset;
    }

    public void setSource(String s) {
        this.source = s;
    }

    public Year getYear() {
        if (this.year == null) {
            return new FactServiceImpl().getRelatedYear(this);
        }
        return this.year;
    }

    public void setMaintenanceCost(Resources r) {
        maintenance = new Resources.ResourceBuilder().pax(r.getPax()).treasury(r.getTreasury()).build();
    }

    public Resources getMaintenance() {
        return this.maintenance;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Fact)) return false;
        if (!super.equals(o)) return false;

        Fact fact = (Fact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = getSubject() != null ? getSubject().hashCode() : 0;
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }
}
