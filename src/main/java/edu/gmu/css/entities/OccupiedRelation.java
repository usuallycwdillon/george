package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

@RelationshipEntity (type="OCCUPIED")
public class OccupiedRelation {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    Polity polity;
    @EndNode
    Territory territory;
    @Property
    private Long from = 0L;
    @Property
    private Long until;

    public OccupiedRelation () {

    }

    public OccupiedRelation (Polity polity, Territory territory, Long step) {
        this.polity = polity;
        this.territory = territory;
        this.from = step;
    }

    public Long getId() {
        return id;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Territory getTerritory() {
        return territory;
    }

    public void setTerritory(Territory territory) {
        this.territory = territory;
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
}

