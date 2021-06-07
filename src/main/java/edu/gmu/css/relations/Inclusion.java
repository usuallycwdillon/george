//package edu.gmu.css.relations;
//
//import edu.gmu.css.agents.Tile;
//import edu.gmu.css.entities.Territory;
//import org.neo4j.ogm.annotation.*;
//
//import java.io.Serializable;
//
//@RelationshipEntity(type="INCLUDES")
//public class Inclusion implements Serializable {
//
//    @Id @GeneratedValue
//    private Long id;
//    @Property
//    private Integer during;
//    @StartNode
//    private Territory territory;
//    @EndNode
//    private Tile tile;
//
//
//    public Inclusion() {}
//
//    public Inclusion(Territory territory, Tile tile, Integer during) {
//        this.territory = territory;
//        this.tile = tile;
//        this.during = during;
//    }
//
//    public long getId() {
//        return id;
//    }
//
//    public Integer getDuring() {
//        return during;
//    }
//
//    public void setDuring(Integer during) {
//        this.during = during;
//    }
//
//    public Territory getTerritory() {
//        return territory;
//    }
//
//    public void setTerritory(Territory territory) {
//        this.territory = territory;
//    }
//
//    public Tile getTile() {
//        return tile;
//    }
//
//    public void setTile(Tile tile) {
//        this.tile = tile;
//    }
//
//    public String getTileAddressYear() {
//        return this.tile.getAddressYear();
//    }
//
//    public String getTileAddress() {
//        return this.tile.getAddress();
//    }
//
//    public Double getTilePopulation() {
//        return this.tile.getPopulation();
//    }
//
//    public Double getTileUrbanPop() {
//        return this.tile.getUrbanPop();
//    }
//
//    public Double getTileWealth() {
//        return this.getTile().getWealth();
//    }
//
//    public Double getWeeklyGrossTileProductivity() {
//        if (this.getTile()==null) {
//            System.out.println("where's the Tile?");
//        }
//        return this.getTile().getWeeklyGrossTileProduction();
//    }
//
//    public Double getGrossTileProductivityLastYear() {
//        return this.tile.getGrossTileProductionLastYear();
//    }
//
//    public Double getTileBuiltUpArea() {
//        return this.tile.getBuiltUpArea();
//    }
//
//    public Integer getTerritoryYear() {
//        return territory.getYear();
//    }
//}
