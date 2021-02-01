package edu.gmu.css.entities;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.service.*;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.model.Result;
import org.neo4j.register.Register;


import java.io.Serializable;
import java.util.*;
import java.util.stream.Collectors;

@NodeEntity
public class Territory extends Entity implements Serializable {

//    @Transient
//    Map<Long, Tile> globalHexes = HexFactory.globalHexes;

    @Id @GeneratedValue (strategy = NameIdStrategy.class)
    String mapKey;
    @Property
    String name;
    @Property
    String cowcode = "NA";
    @Property
    Long creationStep;
    @Property
    String abbr;
    @Property
    Double area = 0.0;
    @Property
    Integer year;
    @Property
    Integer resolution;
    @Property
    Double centrality;
    @Property
    long[] linkedTileIds;


    @Relationship(type="REPRESENTS_POPULATION")
    CommonWeal commonWeal;

    @Relationship(type="OCCUPIED", direction = Relationship.INCOMING)
    OccupiedRelation polity;

    @Relationship(type="INCLUDES")
    Set<Inclusion> tileLinks;

    @Relationship(type="BORDERS")
    Set<Border> borders;


    public Territory() {
    }

    public Territory(String name, int year) {
        this.year = year;
        this.name = name;
        this.mapKey = name + " " + year;
        this.area = 0.0;
        this.cowcode = "NA";
        this.tileLinks = new HashSet<>();
    }

    //------------------------------------------------------------------------------------------------------------------

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAbbr() {
        return abbr;
    }

    public void setAbbr(String abbr) {
        this.abbr = abbr;
    }

    public String getCowcode() {
        return cowcode;
    }

    public void setCowcode(String cowcode) {
        this.cowcode = cowcode;
    }

    public Double getArea() {
        return area;
    }

    public void setArea(Double area) {
        this.area = area;
    }

    public int getYear() {
        return year;
    }

    public Double getWealth() {
        return tileLinks.stream().mapToDouble(Inclusion::geTileWealth).sum();
    }

    public Double getPopulation() {
        if (getPopulatedTileLinks()==null || getPopulatedTileLinks().size()==0) {
            this.tileLinks = new TerritoryServiceImpl().loadIncludedTiles(this.mapKey);
        }
        return tileLinks.stream().mapToDouble(Inclusion::getTilePopulation).sum();
    }

    public Double getGrossDomesticProduct() {
        return tileLinks.stream().mapToDouble(Inclusion::getGrossTileProductivity).sum();
    }

    public Double getGrossDomesticProductLastYear() {
        return tileLinks.stream().mapToDouble(Inclusion::getGrossTileProductivityLastYear).sum();
    }

    public Double getUrbanPopulation() {
        return (tileLinks.stream().mapToDouble(Inclusion::getTileUrbanPop).sum() / getPopulation());
    }

    public String getMapKey() {
        return mapKey;
    }

    public Set<Inclusion> getTileLinks() {
        if(tileLinks==null || tileLinks.size()==0) {
            this.tileLinks = new TerritoryServiceImpl().loadIncludedTiles(this.mapKey);
        }
        return tileLinks;
    }

    public Set<Inclusion> getPopulatedTileLinks() {
        return tileLinks.stream().filter(l -> l.getTile().getPopulation() > 0.0).collect(Collectors.toSet());
    }

    public Polity getPolity() {
        if (polity == null) {
            return null;
        } else {
            return polity.getOwner();
        }
    }

    public void setPolity(Polity p, Long step) {
        this.polity = new OccupiedRelation(p, this, step);
    }

    public CommonWeal getCommonWeal() {
        return commonWeal;
    }

    public void setCommonWeal(CommonWeal commonWeal) {
        this.commonWeal = commonWeal;
    }

    public void initiateGraph() {
        this.commonWeal = new CommonWeal(this, true);
    }

    public void setTileLinks(Set<Inclusion> i) {
        this.tileLinks = i;
    }

    public void addHex(Tile hex, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Inclusion i = new Inclusion(this, hex, year);
        this.tileLinks.add(i);
        if (!worldOrder.getTiles().containsKey(hex.getH3Id())) {
            worldOrder.tiles.put(hex.getH3Id(), hex);
        }
    }

    public Set<Border> getBorders() {
        return borders;
    }

    public boolean loadTileFacts() {
        long loadthis = System.nanoTime();
        Map<Long, Tile> tileMapper = new HashMap<>();
        for (Inclusion i : tileLinks) {
            tileMapper.put(i.getTileId(), i.getTile());
        }
        long postMap = System.nanoTime();
        Result result = new TerritoryServiceImpl().loadTiles(this);
        long postQuery = System.nanoTime();
        Iterator it = result.iterator();
        double avgSave = 0.0;
        if (tileMapper.size() < 499) {
            long openSplit = System.nanoTime();
            result.spliterator().forEachRemaining(i -> processItem(i, tileMapper));
            avgSave = (System.nanoTime() - openSplit) / 1000000000.0;
        } else {
            long openSplit = System.nanoTime();
            result.spliterator().trySplit().forEachRemaining(i -> processItem(i, tileMapper) );
            avgSave = (System.nanoTime() - openSplit)/1000000000.0;
        }
        if(WorldOrder.DEBUG) {
            long loaded = System.nanoTime();
            System.out.println(name + "'s " + tileMapper.size() + " tiles loaded with data in " + (loaded - loadthis)/1000000.0 );
            System.out.println("\t" + (postMap - loadthis)/ 1000000000.0 + " sec to make the map.");
            System.out.println("\t" + (postQuery - postMap)/ 1000000000.0 + " sec to get query results.");
            System.out.println("\t" + (loaded - postQuery)/ 1000000000.0 + " sec save the data to the tiles.");
            System.out.println("\t" + (avgSave/tileMapper.size()) + " sec for avg tile to save.\n");
        }
        return true;
    }

    private void processItem(Map<String, Object> i, Map<Long, Tile> t) {
        Map<String, Object> map = (Map<String, Object>) i.get("value");
        ( t.get( map.get("a")) ).loadFacts(map);
    }

    public void updateTotals() {
        double population = tileLinks.stream().mapToDouble(Inclusion::getTilePopulation).sum();
        double urbanPop = tileLinks.stream().mapToDouble(Inclusion::getTileUrbanPop).sum() / population;
        double wealth = tileLinks.stream().mapToDouble(Inclusion::geTileWealth).sum();

    }

    public Double assessPopularWarSupport(Entity e) {
        return commonWeal.evaluateWarNeed(e);
    }

    public void findCommonWeal() {
        if (commonWeal == null) {
            this.commonWeal = new CommonWealServiceImpl().findTerritoryCommonWeal(this);
            commonWeal.setTerritory(this);
        }
//        commonWeal.loadPersonMap();
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Territory)) return false;
        if (!super.equals(o)) return false;

        Territory territory = (Territory) o;

        return getMapKey().equals(territory.getMapKey());
    }

    @Override
    public int hashCode() {
        return getMapKey().hashCode();
    }

}
