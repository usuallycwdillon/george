package edu.gmu.css.relations;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Fact;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;

@RelationshipEntity(type = "SIM_URBAN_POPULATION")
public class SimUrbanPopulation implements Serializable {

    @Id
    @GeneratedValue
    private Long relationshipId;
    @StartNode
    private Tile tile;
    @EndNode
    private Fact fact;
    @Property
    private Integer during;

    public SimUrbanPopulation() {

    }

    public SimUrbanPopulation(Tile t, Fact f, Integer d) {
        this.tile = t;
        this.fact = f;
        this.during = d;
    }

    public Tile getTile() {
        return tile;
    }

    public Fact getFact() {
        return fact;
    }

    public Integer getDuring() {
        return during;
    }

    public Long getRelationshipId() {
        return relationshipId;
    }

//    public boolean assignTileUrbanPop() {
//        Integer pop = (Integer) fact.getValue();
//        if (pop != null) {
//            tile.setUrbanPopulation(pop);
//            return true;
//        } else {
//            return false;
//        }
//    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof SimUrbanPopulation)) return false;

        SimUrbanPopulation that = (SimUrbanPopulation) o;

        if (!relationshipId.equals(that.relationshipId)) return false;
        if (!getTile().equals(that.getTile())) return false;
        return getFact().equals(that.getFact());
    }

    @Override
    public int hashCode() {
        int result = relationshipId.hashCode();
        result = 31 * result + getTile().hashCode();
        result = 31 * result + getFact().hashCode();
        return result;
    }
}
