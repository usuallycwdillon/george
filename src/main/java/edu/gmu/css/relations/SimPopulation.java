package edu.gmu.css.relations;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Fact;
import org.neo4j.ogm.annotation.*;


@RelationshipEntity(type = "SIM_POPULATION")
public class SimPopulation {

    @Id
    @GeneratedValue
    private Long relationshipId;
    @StartNode
    private Tile tile;
    @EndNode
    private Fact fact;
    @Property
    private Integer during;

    public SimPopulation() {

    }

    public SimPopulation(Tile t, Fact f, Integer d) {
        this.tile = t;
        this.fact = f;
        this.during = d;
    }

    public Long getRelationshipId() {
        return relationshipId;
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

    public boolean assignTilePopulation() {
        Integer pop = (Integer) fact.getValue();
        if (pop != null) {
            tile.setPopulation(pop);
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof SimPopulation)) return false;

        SimPopulation that = (SimPopulation) o;

        if (!getRelationshipId().equals(that.getRelationshipId())) return false;
        if (!getTile().equals(that.getTile())) return false;
        return getFact().equals(that.getFact());
    }

    @Override
    public int hashCode() {
        int result = getRelationshipId().hashCode();
        result = 31 * result + getTile().hashCode();
        result = 31 * result + getFact().hashCode();
        return result;
    }
}
