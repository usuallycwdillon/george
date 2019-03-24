package edu.gmu.css.relations;


import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Resources;
import edu.gmu.css.entities.War;
import org.neo4j.ogm.annotation.*;

import java.util.List;


@RelationshipEntity(type="PARTICIPATION")
public class Participation extends InstitutionParticipation {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    Polity participant;
    @EndNode
    Institution institution;
    @Property
    private Resources magnitude;          // losses, not participation
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
        this.magnitude = new Resources.ResourceBuilder().build();
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

    public Resources getMagnitude() {
        return magnitude;
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

    public void tallyLosses(int pax) {
        commitment.subtractPax(pax);
        magnitude.addPax(pax);
        ProcessDisposition pd = participant.getProcessList().stream()
                .filter(d -> institution.equals(d.getSubject()))
                .findAny().orElse(null);
        if (pax * 3 > commitment.getPax()) {
            if (pd == null) {
                participant.getLeadership().considerPeace((War) institution);
            } else {
                pd.setN(true);
            }
        }
    }


}
