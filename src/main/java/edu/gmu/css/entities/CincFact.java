package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class CincFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    Double value;

    @Relationship(type = "CINC_SCORE", direction = Relationship.INCOMING)
    Polity polity;

    public CincFact() {

    }




    public Double getValue() {
        return this.value;
    }

//    public Year getYear() {
//        if (this.year==null) {
//            this.year = new FactServiceImpl().getRelatedYear(this);
//        }
//        return this.year;
//    }


    @Override
    public Long getId() {
        return id;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CincFact)) return false;
        if (!super.equals(o)) return false;

        CincFact fact = (CincFact) o;

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
