package edu.gmu.css.relations;

import edu.gmu.css.entities.Border;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;

@RelationshipEntity(type="SHARES_BORDER")
public class BorderAgreement extends InstitutionParticipation implements Serializable {

    @Id
    @GeneratedValue
    Long id;
    @StartNode
    Polity owner;
    @EndNode
    Border institution;
    @Property
    Integer during;

    public BorderAgreement() {

    }

    public BorderAgreement(Polity self, Border border, int year) {
        this.owner = self;
        this.institution = border;
        this.during = year;
    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Polity getOwner() {
        return owner;
    }

    @Override
    public Institution getInstitution() {
        return institution;
    }

    @Override
    public Integer getDuring() {
        return during;
    }

    @Override
    public void setDuring(Integer during) {
        this.during = during;
    }

    public Polity getNeighbor() {
        return institution.findBorderPartner(this);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        BorderAgreement agreement = (BorderAgreement) o;

        return getId().equals(agreement.getId());
    }

    @Override
    public int hashCode() {
        return getId().hashCode();
    }
}
