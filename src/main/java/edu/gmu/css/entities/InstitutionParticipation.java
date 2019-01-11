package edu.gmu.css.entities;


import edu.gmu.css.worldOrder.Resources;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="PARTICIPANT_IN")
public class InstitutionParticipation {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    Polity participant;
    @EndNode
    Institution institution;
    @Property
    private Long from;
    @Property
    private Long until;
    @Property
    private Integer during;
    @Transient
    private Resources commitment;

    public InstitutionParticipation () {
    }

    public InstitutionParticipation(ProcessDisposition disposition, Institution result, Long step) {
        institution = result;
        participant = disposition.getOwner();
        commitment = disposition.getCommitment();
        from = step;
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

    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    public Integer getDuring() {
        return during;
    }

    public void setDuring(Integer during) {
        this.during = during;
    }

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }
}
