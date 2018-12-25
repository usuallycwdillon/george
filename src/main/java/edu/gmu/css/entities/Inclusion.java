package edu.gmu.css.entities;

import edu.gmu.css.agents.Tile;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="INCLUDES")
public class Inclusion {

    @Id @GeneratedValue
    private Long relationshipId;
    @Property
    private Integer year;
    @StartNode
    private Territory territory;
    @EndNode
    private Tile tile;


    public Inclusion() {}

    public Inclusion(Territory territory, Tile tile, Integer year) {
        this.territory = territory;
        this.tile = tile;
        this.year = year;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Territory getTerritory() {
        return territory;
    }

    public void setTerritory(Territory territory) {
        this.territory = territory;
    }

    public Tile getTile() {
        return tile;
    }

    public void setTile(Tile tile) {
        this.tile = tile;
    }

    public Long getTileH3Id() {
        return this.tile.getH3Id();
    }

    public Integer getTilePopulation() {
        return this.tile.getPopulation();
    }
}
