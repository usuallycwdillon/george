package edu.gmu.css.relations;

import edu.gmu.css.entities.Alliance;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="ALLIANCE_PARTICIPATION")
public class AllianceParticipation extends InstitutionParticipation {

    @Id @GeneratedValue
    Long id;
    @StartNode
    Polity participant;
    @EndNode
    Alliance institution;
    @Property
    Long from;
    @Property
    Long until;

    public AllianceParticipation() {

    }

    public AllianceParticipation(Polity p, Alliance a) {
        this.participant = p;
        this.institution = a;
        this.from = a.getFrom();
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        AllianceParticipation that = (AllianceParticipation) o;

        return getId().equals(that.getId());
    }

//    @Override
//    public int hashCode() {
//        return getId().hashCode();
//    }
}
