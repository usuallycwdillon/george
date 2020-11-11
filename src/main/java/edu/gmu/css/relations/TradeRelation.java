package edu.gmu.css.relations;

import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;

public class TradeRelation extends InstitutionParticipation {

    Long id;
    Polity participant;
    Institution institution;
    Long from;
    Long until;


    public Long getId() {
        return id;
    }

    @Override
    public Polity getOwner() {
        return participant;
    }

    @Override
    public Institution getInstitution() {
        return institution;
    }

    @Override
    public Long getFrom() {
        return from;
    }

    @Override
    public void setFrom(Long from) {
        this.from = from;
    }

    @Override
    public Long getUntil() {
        return until;
    }

    @Override
    public void setUntil(Long until) {
        this.until = until;
    }

}
