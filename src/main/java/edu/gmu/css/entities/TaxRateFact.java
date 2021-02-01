package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

@NodeEntity
public class TaxRateFact extends Fact {

    @Id @GeneratedValue
    private Long id;
    @Property
    Double value;

    @Relationship(type="SIM_TAX_RATE", direction = Relationship.INCOMING)
    private Polity polity;

    private TaxRateFact() {

    }

    @Override
    public Long getId() {
        return this.id;
    }

    public Double getValue() {
        return this.value;
    }

    public void setValue(Double v) {
        this.value = v;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof TaxRateFact)) return false;
        if (!super.equals(o)) return false;

        TaxRateFact fact = (TaxRateFact) o;

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
        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }
}
