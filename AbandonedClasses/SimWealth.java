package edu.gmu.css.relations;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Fact;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;

@RelationshipEntity(type = "SIM_WEALTH")
public class SimWealth implements Serializable {

    @Id @GeneratedValue
    private Long relationshipId;
    @StartNode
    private Tile tile;
    @EndNode
    private Fact fact;
    @Property
    private Integer during;

    public SimWealth() {

    }

    public SimWealth(Tile t, Fact f, Integer d) {
        this.tile = t;
        this.fact = f;
        this.during = d;
    }

    public Long getRelationshipId() {
        return relationshipId;
    }

    public Fact getFact() {
        return fact;
    }

    public Integer getDuring() {
        return during;
    }

//    public Double getWealth() {
//        return (Double)fact.getValue();
//    }
//
//    public boolean assignTileWealth() {
//        Double wealth = (Double) fact.getValue();
//        if (wealth != null) {
//            tile.setWealth(wealth);
//            return true;
//        } else {
//            return false;
//        }
//    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof SimWealth)) return false;

        SimWealth that = (SimWealth) o;

        if (!relationshipId.equals(that.getRelationshipId())) return false;
        if (!tile.equals(that.tile)) return false;
        return fact.equals(that.getFact());
    }

    @Override
    public int hashCode() {
        int result = getRelationshipId().hashCode();
        result = 31 * result + tile.hashCode();
        result = 31 * result + fact.hashCode();
        return result;
    }
}
