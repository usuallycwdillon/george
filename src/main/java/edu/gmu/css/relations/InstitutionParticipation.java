package edu.gmu.css.relations;

import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.data.Resources;
import edu.gmu.css.worldOrder.WorldOrder;

import java.io.Serializable;


public abstract class InstitutionParticipation implements Serializable {

    protected Long id;
    protected Polity owner;
    protected Institution institution;
    protected Long from;
    protected Long until;
    protected Integer during;
    protected Resources commitment;
    protected Resources cost;
    protected Double magnitude;
    protected int side;



    public Long getId() {
        return id;
    }

    public Polity getOwner() {
        return owner;
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

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }

    public Double getMagnitude() {
        return magnitude;
    }

    public void setMagnitude(Double m) {
        this.magnitude = m;
    }

    public int getSide() {
        return side;
    }

    public void setSide(int side) {
        this.side = side;
    }

    public void tallyLosses(double rate, WorldOrder wo) {

    }

    public void commitMore(Resources additional) {

    }
}
