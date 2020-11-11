package edu.gmu.css.relations;

import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Territory;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;

@RelationshipEntity (type="OCCUPIED")
public class OccupiedRelation extends InstitutionParticipation implements Serializable {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    Polity owner;
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
        this.owner = p;
        this.territory = t;
        this.from = step;
    }

    public OccupiedRelation (Polity p, Territory t, Integer d) {
        this.owner = p;
        this.territory = t;
        this.during = d;
    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Polity getOwner() {
        return owner;
    }

    public void setOwner(Polity owner) {
        this.owner = owner;
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

