package edu.gmu.css.entities;


import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class DiplomaticExchange extends Institution {

    @Id @GeneratedValue
    private Long id;
    @Property
    private String[] subjects;
    @Transient
    protected double strength = 0.50;

    @Relationship (type="REPRESENTED_WITH", direction=Relationship.INCOMING)
    Set<DipExFact> representation = new HashSet<>();
    @Relationship (type="DURING")
    private Year year;



    public DiplomaticExchange() {
        name = "Diplomatic Exchange";
        domain = Domain.DIPLOMACY;
    }

    public DiplomaticExchange(Process p) {
        from = p.getEnded();
        name = "Diplomatic Exchange";
        domain = Domain.DIPLOMACY;
    }

    @Override
    public void step(SimState simState) {
        WorldOrder wo = (WorldOrder) simState;
        this.strength = strength * wo.getInstitutionStagnationRate(); // decreases by every year but use increases
    }

    @Override
    public Long getId() {
        return this.id;
    }

    public String[] getSubjects() {
        return subjects;
    }

    public void setSubjects(String[] subjects) {
        this.subjects = subjects;
    }

    public Year getYear() {
        return year;
    }

    public void setYear(Year year) {
        this.year = year;
    }

    public void setRepresentation(Set<DipExFact> set) {
        this.representation = set;
    }

    public Set<DipExFact> getRepresentation() {
        return this.representation;
    }

    public void addRepresentation(DipExFact f) {
        this.representation.add(f);
    }

    public void removeRepresentation(DipExFact f) {
        this.representation.remove(f);
    }

    public double getStrength() {
        return strength;
    }

    public void setStrength(double strength) {
        this.strength = strength;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        DiplomaticExchange that = (DiplomaticExchange) o;

        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        // Probably incorrect - comparing Object[] arrays with Arrays.equals
        return Arrays.equals(getSubjects(), that.getSubjects());
    }

    @Override
    public int hashCode() {
        return Arrays.hashCode(getSubjects());
    }
}
