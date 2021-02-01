package edu.gmu.css.relations;

import edu.gmu.css.entities.Alliance;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.data.Resources;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="ALLIANCE_PARTICIPATION")
public class AllianceParticipation extends InstitutionParticipation {

    @Id @GeneratedValue
    Long id;
    @StartNode
    Polity owner;
    @EndNode
    Alliance institution;
    @Property
    Long from;
    @Property
    Long until;
    @Transient
    private Resources commitment;

    public AllianceParticipation() {
    }

    public AllianceParticipation(ProcessDisposition pd, Alliance a) {
        this.owner = pd.getOwner();
        this.institution = a;
        this.from = a.getFrom();
    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Resources getCommitment() {
        return commitment;
    }

    @Override
    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }

    @Override
    public void commitMore(Resources additional) {
        commitment.increaseBy(additional);
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
