package edu.gmu.css.entities;

import com.uber.h3core.H3Core;
import com.uber.h3core.util.GeoCoord;
import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.hexFactory.*;

import edu.gmu.css.relations.BorderRelation;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.service.*;
import edu.gmu.css.util.IndexReverseSorter;
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

    public Territory(String name, int year) {
        this.resolution = 4;
        this.year = year;
        this.name = name;
        this.mapKey = name + " " + year;
        this.population = 0;
        this.urbanPopulation = 0;
        this.area = 0.0;
        this.cowcode = "NA";
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
            int unum;

            if (WorldOrder.DEBUG) {
                System.out.println(mapKey + " has " + num + " tiles. ");
            }

            MersenneTwisterFast random = new MersenneTwisterFast();
            ZipfDistribution distribution;
            ZipfDistribution urbanDistrib;
            int[] uLevels = {0};
            int[] urbanizedIndexes = {0};
            int uProportion = 1;
            Integer[] sortedULevIdx = {0};

            Map<String, Object> params = new HashMap<>();
            params.put("cowcode", cowcode);
            params.put("startYear", WorldOrder.getStartYear());
            params.put("untilYear", WorldOrder.getUntilYear());

            String popQuery = "MATCH (t:Territory)-[o]-(s:State{cowcode:$cowcode})-[:POPULATION]-(pf:PopulationFact)-[:DURING]-(y:Year)," +
                    "(d:Dataset{name:'NMC Supplemental'})" +
                    "WHERE (d)-[:CONTRIBUTES]-(pf) AND (d)-[:CONTRIBUTES]-(pf) AND $startYear < y.began.year < $untilYear " +
                    "WITH pf, y ORDER BY y.began.year " +
                    "RETURN pf LIMIT 1";
            Fact popFact = Neo4jSessionFactory.getInstance().getNeo4jSession()
                    .queryForObject(Fact.class, popQuery, params);

            String uPopQuery = "MATCH (t:Territory)-[o]-(s:State{cowcode:$cowcode})-[:URBAN_POPULATION]-(uf:UrbanPopulationFact)-[:DURING]-(y:Year)," +
                    "(d:Dataset{name:'NMC Supplemental'})" +
                    "WHERE (d)-[:CONTRIBUTES]-(uf) AND (d)-[:CONTRIBUTES]-(uf) AND $startYear < y.began.year < $untilYear " +
                    "WITH uf, y ORDER BY y.began.year " +
                    "RETURN uf LIMIT 1";
            Fact uPopFact = Neo4jSessionFactory.getInstance().getNeo4jSession()
                    .queryForObject(Fact.class, uPopQuery, params);

            if (popFact == null) {
                pop = num * 1000L;
            } else {
                pop = (Long) popFact.getValue() * 1000;
            }

            // must get the length of the urbanized tile array before we can build it
            if (uPopFact == null) {
                upop = 0L;
                unum = 0;
            } else {
                upop = (Long) uPopFact.getValue() * 1000L;
                int urbanTiles = (int)(upop / 50000);
                if (urbanTiles % 2 == 0) {
                    unum = urbanTiles / 2;
                } else {
                    unum = (urbanTiles + 1) / 2;
                }
                unum = Math.min(unum, num);
            }

            distribution = new ZipfDistribution(new MTFApache(random), num, 1.7);

            int[] levels = distribution.sample(num);
            int distSum = IntStream.of(levels).sum();
            int pProportion = pop.intValue() / distSum;

            if (unum > 1) {
                // Get a sorted index of the population levels (levels are sorted, index describes the sort order)
                IndexReverseSorter sorter = new IndexReverseSorter(levels);
                final Integer[] sortedLevelsIdx = sorter.createIndexArray();
                Arrays.sort(sortedLevelsIdx, sorter);
                // Indices of urbanized populations (highest levels) limited to number of values above 50k
                urbanizedIndexes = IntStream.range(0, unum).map(i -> sortedLevelsIdx[i]).toArray();
                // new zeta-distribution for urbanized population values (array of dividend)
                urbanDistrib = new ZipfDistribution(new MTFApache(random), unum, 1.6);
                uLevels = urbanDistrib.sample(unum);
                // get proportion divisor and fraction 1/divisor
                int urbSum = IntStream.of(uLevels).sum();
                uProportion = upop.intValue() / urbSum;
                // get a sorted index of the
                IndexReverseSorter uSorter = new IndexReverseSorter(uLevels);
                sortedULevIdx = uSorter.createIndexArray();
                Arrays.sort(sortedULevIdx, uSorter);
            }

            if (num > 0) {
                int pacer = 0;
                int uPacer = 0;
                int summedPopulation = 0;
                int summedUrbanPop = 0;
                for (Inclusion h : tileLinks) {
                    Tile t = h.getTile();
                    // Applying the population proportion to this tile is simple: multiply the level from the samples
                    // array to the proportion of the population represented by each portion of the total
                    int thisPop = pProportion * levels[pacer];
                    summedPopulation += thisPop;
                    t.setPopulation(thisPop);
                    // Applying the urban population proportion to this tile is much more involved. If there is 1 or 0
                    // tiles with an urban population, apply the total urban population (maybe 0). If there are more
                    // than 2 tiles with an urban population, get the rank from the main population from the sorted
                    // array of indexes, match with the same-ranked index of urban population levels, then multiply
                    // that value to the proportion of the urban population represented by the levels.
                    int thisUpop = 0;
                    if (unum < 2) {
                        thisUpop = upop.intValue();
                        summedUrbanPop += thisUpop;
                        t.setUrbanization(thisUpop);
                    } else {
                        if (uPacer < unum) {
                            for (int i=0; i<unum; i++) {
                                if (pacer == urbanizedIndexes[i]) {
                                    int uIndex = sortedULevIdx[i];
                                    int uLevel = uLevels[uIndex];
                                    thisUpop = uLevel * uProportion;
                                    summedUrbanPop += thisUpop;
                                    t.setUrbanization(thisUpop);
                                    uPacer++;
                                }
                            }
                        } else {
                            summedUrbanPop += thisUpop;
                            t.setUrbanization(thisUpop);
                        }
                    }
                    Neo4jSessionFactory.getInstance().getNeo4jSession().save(t, 0);
                    WorldOrder.getTiles().put(t.getH3Id(), t);
                    pacer++;
                }
                double near = (summedPopulation * 1.0) / (pop + 1); // prevent zero division errors
                double nearU = (summedUrbanPop * 1.0) / (upop + 1); // still returns 0.
                if (WorldOrder.DEBUG) {
                    System.out.println(mapKey + " has population " + pop + " and the distributed population is "
                            + summedPopulation + ", which is " + near + " of the data. \n The simulated urban population is "
                            + summedUrbanPop + " which is " + nearU + " of the data: " + upop);
                }
                population = summedPopulation;
                urbanPopulation = summedUrbanPop;
            } else {
                int summedPopulation = 0;
                for (Inclusion i : tileLinks) {
                    Tile t = i.getTile();
                    t.setPopulation(100);
                    summedPopulation += 100;
                    WorldOrder.getTiles().put(t.getH3Id(), t);
                }
                population = summedPopulation;
                if (WorldOrder.DEBUG) {
                    System.out.println(mapKey + " has a contrived population of 100 pax / tile, or " + summedPopulation);
                }
            }
        }
        Neo4jSessionFactory.getInstance().getNeo4jSession().save(this, 0);
    }

    public void loadIncludedTiles() {
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        String query = "MATCH (t:Territory{mapKey:$mapKey})-[:INCLUDES]-(ti:Tile) RETURN ti";
        Iterable<Tile> result = Neo4jSessionFactory.getInstance()
                .getNeo4jSession().query(Tile.class, query, params);
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
        State n = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .queryForObject(State.class, query, params);
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
        Iterable<BorderRelation> result = Neo4jSessionFactory.getInstance()
                .getNeo4jSession().query(BorderRelation.class, query, params);
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
