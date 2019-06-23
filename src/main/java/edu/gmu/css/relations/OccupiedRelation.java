package edu.gmu.css.relations;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Territory;
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
    @Property
    private Integer during;

    public OccupiedRelation () {

    }

    public OccupiedRelation (Polity p, Territory t, Long step) {
        this.polity = p;
        this.territory = t;
        this.from = step;
    }

    public OccupiedRelation (Polity p, Territory t, Integer d) {
        this.polity = p;
        this.territory = t;
        this.during = d;
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

    public Integer getDuring() {
        return during;
    }

    public void setDuring(Integer during) {
        this.during = during;
    }
}

