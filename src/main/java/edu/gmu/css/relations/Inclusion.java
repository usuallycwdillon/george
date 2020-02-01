package edu.gmu.css.relations;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Territory;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;

@RelationshipEntity(type="INCLUDES")
public class Inclusion implements Serializable {

    @Id @GeneratedValue
    private Long relationshipId;
    @Property
    private Integer during;
    @StartNode
    private Territory territory;
    @EndNode
    private Tile tile;


    public Inclusion() {}

    public Inclusion(Territory territory, Tile tile, Integer during) {
        this.territory = territory;
        this.tile = tile;
        this.during = during;
    }

    public Integer getDuring() {
        return during;
    }

    public void setDuring(Integer during) {
        this.during = during;
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

    public Long getTileId() {
        return this.tile.getH3Id();
    }

    public String getTileAddress() {
        return this.tile.getAddress();
    }

    public Integer getTilePopulation() {
        return this.tile.getPopulation();
    }

    public Integer getTileUrbanPop() {
        Long lupop = Math.round(this.getTilePopulation() * this.tile.getUrbanization());
        return lupop.intValue();
    }

    public Double geTileWealth() {
        return this.getTile().getWealth();
    }

    public Integer getTerritoryYear() {
        return territory.getYear();
    }
}
