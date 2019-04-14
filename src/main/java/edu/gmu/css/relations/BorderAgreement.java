package edu.gmu.css.relations;

import edu.gmu.css.entities.Border;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Territory;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="SHARES_BORDER")
public class BorderAgreement extends InstitutionParticipation{

    @Id
    @GeneratedValue
    Long id;
    @StartNode
    Polity participant;
    @EndNode
    Border institution;
    @Property
    Integer during;

    public BorderAgreement() {

    }

    public BorderAgreement(Polity self, Border border, int year) {
        this.participant = self;
        this.institution = border;
        this.during = year;
    }

    public Long getId() {
        return id;
    }

    public Polity getParticipant() {
        return participant;
    }

    public Institution getInstitution() {
        return institution;
    }

    public Integer getDuring() {
        return during;
    }

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
