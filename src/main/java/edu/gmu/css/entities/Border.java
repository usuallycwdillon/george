package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Resources;
import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;
import sim.engine.SimState;

import java.util.Set;

@NodeEntity
public class Border extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private Long id;
    @Property
    private String name;
    @Property @Convert(DateConverter.class)
    Long from;
    @Property @Convert(DateConverter.class)
    Long until;
    @Property
    private int during;
    @Property
    private String[] subjects;

    @Relationship (type = "BORDERS_WITH", direction=Relationship.INCOMING)
    private Set<BorderFact> borderFacts;
    @Relationship (type = "BORDERS", direction = Relationship.INCOMING)
    private Set<Territory> territoryNeighbors;


    // only for the OGM, don't use this otherwise
    public Border() {
        name = "Border";
    }

    public Border(Process proc, long s) {
        cause = proc;
        from = s;
        name = "Border";
        cost = new Resources.ResourceBuilder().build();
    }

    private Border(BorderBuilder builder) {
        this.borderFacts = builder.borderFacts;
        this.territoryNeighbors = builder.territoryNeighbors;
        this.from = builder.from;
        this.until = builder.until;
        this.maintenance = builder.maintenance;
    }


    public static class BorderBuilder {
        private Set<BorderFact> borderFacts;
        private Set<Territory> territoryNeighbors;
        private String[] subjects;
        private Long from;
        private Long until;
        private Resources maintenance;

        public BorderBuilder() {        }


        public BorderBuilder from (Long from) {
            this.from = from;
            return this;
        }

        public BorderBuilder until (Long until) {
            this.until = until;
            return this;
        }

        public BorderBuilder maintenance (Resources cost) {
            this.maintenance = cost;
            return this;
        }

        public BorderBuilder territoryNeighbors(Set<Territory> t) {
            this.territoryNeighbors = t;
            return this;
        }

        public BorderBuilder borderFacts(Set<BorderFact> f) {
            this.borderFacts = f;
            return this;
        }

        public Border build() {
            Border border = new Border();
            return border;
        }
    }


    @Override
    public Long getId() {
        return id;
    }

    public Resources getCommitment() {
        return maintenance;
    }

    public String getName() {
        return this.name;
    }

    public void setCommitment(Resources commitment) {
        this.maintenance = commitment;
    }

    public String[] getSubjects() {
        return subjects;
    }

    public void setSubjects(String[] subjects) {
        this.subjects = subjects;
    }

    public Territory getTerritoryNeighbors(Territory me) {
        for (Territory neighbor : territoryNeighbors) {
            if (!neighbor.equals(me))
                return neighbor;
        }
        return null;
    }


}
