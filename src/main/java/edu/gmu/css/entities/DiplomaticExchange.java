package edu.gmu.css.entities;


import edu.gmu.css.data.FactType;
import edu.gmu.css.data.SeaTerritories;
import org.neo4j.ogm.annotation.*;
import edu.gmu.css.agents.Process;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class DiplomaticExchange extends Institution {

    @Id @GeneratedValue
    private Long id;
    @Property
    private String[] subjects;

    @Relationship (type="REPRESENTED_WITH", direction=Relationship.INCOMING)
    Set<DipExFact> representation = new HashSet<>();
    @Relationship (type="DURING")
    private Year year;



    public DiplomaticExchange() {
        name = "Diplomatic Exchange";
    }

    public DiplomaticExchange(Process p) {
        from = p.getEnded();
        name = "Diplomatic Exchange";
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
}
