package edu.gmu.css.relations;

import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;
import java.util.Set;


public abstract class InstitutionParticipation implements Serializable {

    Long id;
    Polity participant;
    Institution institution;
    Long from;
    Long until;
    Integer during;


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

    public Integer getDuring() {
        return during;
    }

    public void setDuring(Integer during) {
        this.during = during;
    }

}
