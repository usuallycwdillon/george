package edu.gmu.css.relations;


import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Resources;
import org.neo4j.ogm.annotation.*;


@RelationshipEntity(type="PARTICIPATION")
public class Participation extends InstitutionParticipation {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    Polity participant;
    @EndNode
    Institution institution;
    @Property
    private int magnitude;
    @Property
    private int side;
    @Transient
    private Resources commitment;

    public Participation() {
    }

    public Participation(ProcessDisposition disposition, Institution institution, Long step) {
        this.institution = institution;
        this.participant = disposition.getOwner();
        this.commitment = disposition.getCommitment();
        this.from = step;
        this.magnitude = disposition.getCommitment().getPax();
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

    public int getMagnitude() {
        return magnitude;
    }

    public void updateMagnitude(Resources resources) {
        int force = resources.getPax();
        this.magnitude = Math.max(magnitude, force);
    }

    public void setSide(int s) {
        this.side = s;
    }

    public int getSide() {
        return this.side;
    }

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }
}
