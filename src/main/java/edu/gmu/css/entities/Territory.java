package edu.gmu.css.entities;

import com.uber.h3core.H3Core;
import com.uber.h3core.util.GeoCoord;
import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.hexFactory.*;

import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.relations.BorderRelation;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.service.*;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.distribution.ZipfDistribution;
import org.geojson.*;
import org.jetbrains.annotations.NotNull;
import org.neo4j.ogm.annotation.*;


import java.io.Serializable;
import java.util.*;
import java.util.stream.IntStream;

@NodeEntity
public class Territory extends Entity implements Serializable {

    @Transient
    Map<Long, Tile> globalHexes = HexFactory.globalHexes;

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
    @Transient
    Integer population;
    @Transient
    Integer urbanPopulation;
    @Transient
    Double wealth;

    @Property
    Set<Long> linkedTileIds;

    @Relationship(type="OCCUPIED", direction = Relationship.INCOMING)
    OccupiedRelation government;

    @Relationship(type="INCLUDES")
    Set<Inclusion> tileLinks;

    @Relationship(type="BORDERS", direction = Relationship.UNDIRECTED)
    Set<BorderRelation> borderRelations;


    public Territory() {
        this.resolution = 4;
        this.creationStep = 0L;
        this.name = "Unnamed";
        this.area = 0.0;
        this.tileLinks = new HashSet<>();
        this.linkedTileIds = new HashSet<>();
    }

    public Territory(String name, String abbr, Double area, int year, int resolution) {
        this();
        this.year = year;
        this.creationStep = (year - 1816) * 52L;
        this.tileLinks = new HashSet<>();
        this.name = name;
        this.abbr = abbr;
        this.resolution = resolution;
        if (area != null) {this.area = area;} else {this.area = 0.0;}
    }

    public Territory(String name, String abbr, Double area, int year, int resolution, Feature feature) {
        this();
        this.year = year;
        this.creationStep = (year - 1816) * 52L;
        this.tileLinks = new HashSet<>();
        this.name = name;
        this.abbr = abbr;
        this.resolution = resolution;
        this.mapKey = name + " of " + year;
        if (area != null) {this.area = area;} else {this.area = 0.0;}
        buildTerritory(feature);
    }

    public Territory(Feature input, int year) {
        this();
        this.name = input.getProperty("NAME");
        this.abbr = input.getProperty("WB_CNTRY");
        this.year = year;
        this.mapKey = name + " of " + year;
        if (input.getProperty("AREA") != null) {
            this.area = input.getProperty("AREA");
        } else {
            this.area = 0.0;
        }
        if (input.getProperty("CCODE") != null) {
            this.cowcode = "" + input.getProperty("CCODE");
        } else {
            this.cowcode = "";
        }
        buildTerritory(input);
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

    public int getResolution() {
        return resolution;
    }

    public void setResolution(int resolution) {
        this.resolution = resolution;
    }

    public Integer getPopulation() {
        return population;
    }

    public void setPopulation(Integer population) {
        this.population = population;
    }

    public String getMapKey() {
        return mapKey;
    }

    public Set<Inclusion> getTileLinks() {
        return tileLinks;
    }

    public Set<Long> getLinkedTileIds() { return linkedTileIds; }

    public Polity getGovernment() {
        if (government==null) {
            return null;
        } else {
            return government.getPolity();
        }
    }

    public void setGovernment(Polity government, Long step) {
        this.government = new OccupiedRelation(government, this, step);
    }

    public void addHex(Tile hex) {
        Inclusion o = new Inclusion(this, hex, year);
        this.tileLinks.add(o);
        if (!WorldOrder.tiles.containsKey(hex.getH3Id())) {
            WorldOrder.tiles.put(hex.getH3Id(), hex);
        }
    }

    public Set<BorderRelation> getBorderRelations() {
        return borderRelations;
    }

    public void buildTerritory(Feature inputFeature) {
        getTileIdsFromPolygons(inputFeature);
        tileLinks.addAll(getTilesFromAddresses());
    }

    public void updateOccupation(Feature inputFeature) {
        if (inputFeature.getProperty("AREA") != null) {
            this.area = this.area + (Double) inputFeature.getProperty("AREA");
        }
        getTileIdsFromPolygons(inputFeature);
        tileLinks.addAll(getTilesFromAddresses());
    }

    private void getTileIdsFromPolygons(@NotNull Feature inputFeature) {
        // All territory elements are multipolygons, even if there is only one polygon in the array
        MultiPolygon geom = (MultiPolygon) inputFeature.getGeometry();
        int numPolygons = geom.getCoordinates().size();

        Set<Long> tempList5 = new HashSet<>();

        for (int i = 0; i < numPolygons; i++) {
            List<List<GeoCoord>> holes = new ArrayList<>();
            int numInnerLists = geom.getCoordinates().get(i).size();

            List<LngLatAlt> coordinates = geom.getCoordinates().get(i).get(0);
            List<GeoCoord> boundaryCoordinates = swapCoordinateOrdering(coordinates);

            if (numInnerLists > 1) {        // second thru last elements are holes in the outer polygon
                for (int il=1; il<numInnerLists; il++) {
                    List<GeoCoord> hole = swapCoordinateOrdering(geom.getCoordinates().get(i).get(il));
                    holes.add(hole);
                }
            }

            try {
                H3Core h3 = H3Core.newInstance();
                tempList5.addAll(h3.polyfill(boundaryCoordinates, holes, resolution + 1));
                for (Long t5 : tempList5) {
                    Long t5Parent = h3.h3ToParent(t5, resolution);
                    List<Long> t5Siblings = h3.h3ToChildren(t5Parent, resolution + 1);
                    if (tempList5.contains(t5Siblings.get(0))) {
                        linkedTileIds.add(t5Parent);
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private List<GeoCoord> swapCoordinateOrdering(@NotNull List<LngLatAlt> coordinates) {
        List<GeoCoord> h3Coords = new ArrayList<>();
        for (LngLatAlt c : coordinates) {
            GeoCoord gc = new GeoCoord(c.getLatitude(), c.getLongitude());
            h3Coords.add(gc);
        }
        return h3Coords;
    }

    public Set<Inclusion> getTilesFromAddresses() {
        Set<Inclusion> tiles = new HashSet<>();
        for (Long h : linkedTileIds) {
            if (globalHexes.containsKey(h)) {
                Tile t = globalHexes.get(h);
                this.occupation(t);
            } else  {
                Tile t = new Tile(h);
                globalHexes.put(h, t);
                this.occupation(t);
            }
        }
        return tiles;
    }

    public Inclusion occupation(Tile tile) {
        Inclusion occupied = new Inclusion(this, tile, year);
        this.tileLinks.add(occupied);
        return occupied;
    }

    public void loadBaselinePopulation() {
        if (cowcode != "NA") {
            Long pop;
            Long upop;
            int num = tileLinks.size();

            Map<String, Object> params = new HashMap<>();
            params.put("cowcode", cowcode);
            params.put("startYear", WorldOrder.getStartYear());
            params.put("untilYear", WorldOrder.getUntilYear());

            String popQuery = "MATCH (t:Territory)-[o]-(s:State{cowcode:$cowcode})-[:POPULATION]-(pf:PopulationFact)-[:DURING]-(y:Year)," +
                    "(d:Dataset{name:'NMC Supplemental'})" +
                    "WHERE (d)-[:CONTRIBUTES]-(pf) AND (d)-[:CONTRIBUTES]-(pf) AND $startYear < y.began.year < $untilYear " +
                    "WITH pf, y ORDER BY y.began.year " +
                    "RETURN pf LIMIT 1";
            Fact popFact = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, popQuery, params);

            if (popFact == null) {
                pop = num * 1000L;
            } else {
                pop = (Long) popFact.getValue() * 1000;
            }

            String uPopQuery = "MATCH (t:Territory)-[o]-(s:State{cowcode:$cowcode})-[:URBAN_POPULATION]-(uf:UrbanPopulationFact)-[:DURING]-(y:Year)," +
                    "(d:Dataset{name:'NMC Supplemental'})" +
                    "WHERE (d)-[:CONTRIBUTES]-(uf) AND (d)-[:CONTRIBUTES]-(uf) AND $startYear < y.began.year < $untilYear " +
                    "WITH uf, y ORDER BY y.began.year " +
                    "RETURN uf LIMIT 1";
            Fact uPopFact = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, uPopQuery, params);

            if (uPopFact == null) {
                upop = num * 50L;
            } else {
                upop = (Long) uPopFact.getValue() * 1000L;
            }

            System.out.println(mapKey + " has " + num + " tiles. ");
            MersenneTwisterFast random = new MersenneTwisterFast();
            ZipfDistribution distribution = new ZipfDistribution(new MTFApache(random), num, 2.0);

            int[] levels = distribution.sample(num);
            int distSum = IntStream.of(levels).sum();
            int uProportion = upop.intValue() / distSum;
            int pProportion = pop.intValue() / distSum;
            if (num > 0) {
                int pacer = 0;
                int summedPopulation = 0;
                int summedUrban = 0;
                for (Inclusion h : tileLinks) {
                    Tile t = h.getTile();
                    int thisPop = pProportion * levels[pacer];
                    int thisUrb = uProportion * levels[pacer];
                    t.setPopulation(thisPop);
                    t.setUrbanization(thisUrb);
                    Neo4jSessionFactory.getInstance().getNeo4jSession().save(t, 0);
                    summedPopulation += thisPop;
                    summedUrban += thisUrb;
                    WorldOrder.getTiles().put(t.getH3Id(), t);
                    pacer++;
                }
                double near = (Double) (summedPopulation * 1.0) / pop;
                double unear = (Double) (summedUrban * 1.0) / upop;
                System.out.println(mapKey + " has population " + pop + " and the distributed population is "
                        + summedPopulation + ", which is " + near + " of the data." + "\n The urban population is "
                        + summedUrban + " compared to " + upop + " in the data, or " + unear);
                population = summedPopulation;
                urbanPopulation = summedUrban;
            } else {
                int summedPopulation = 0;
                for (Inclusion i : tileLinks) {
                    Tile t = i.getTile();
                    t.setPopulation(1000);
                    summedPopulation += 1000;
                    WorldOrder.getTiles().put(t.getH3Id(), t);
                }
                population = summedPopulation;
                System.out.println(mapKey + " has a contrived population of 100 pax / tile, or " + summedPopulation);
            }
        }
    }

    public void loadIncludedTiles() {
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        String query = "MATCH (t:Territory{mapKey:$mapKey})-[:INCLUDES]-(ti:Tile) RETURN ti";
        Iterable<Tile> result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(Tile.class, query, params);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            result.forEach(tile -> addHex(tile));
        }
    }

    public void loadGovernment() {
        String name = WorldOrder.getStartYear() + "";
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        params.put("name", name);
        String query = "MATCH (t:Territory{mapKey:$mapKey})-[:OCCUPIED]-(s:State)-[:DURING]-(:Year{name:$name}) RETURN s";
        State n = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(State.class, query, params);
        if (n != null) {
            government.setPolity(n);
        } else {
            government = null;
        }
    }

    public void loadBorders() {
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        String query = "MATCH (t:Territory{mapKey:$mapKey})-[:BORDERS]->(b:Border) b";
        Iterable<BorderRelation> result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(BorderRelation.class, query, params);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            result.forEach(t -> borderRelations.add(t));
        }
    }

    public void loadRelations() {
        this.loadIncludedTiles();
        this.loadGovernment();
        this.loadBorders();

    }


    public void updateTotals() {
        population = tileLinks.stream().mapToInt(Inclusion::getTilePopulation).sum();
    }

    // TODO: Add equals method, toString method,


}
