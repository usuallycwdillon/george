package edu.gmu.css.entities;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.service.*;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;


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


    @Relationship
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
        return tileLinks;
    }

    public Set<Inclusion> getPopulatedTileLinks() {
        return tileLinks.stream().filter(l -> l.getTile().getPopulation() > 0).collect(Collectors.toSet());
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

    public void loadIncludedTiles(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        String query = "MATCH (:Territory{mapKey:$mapKey})-[:INCLUDES]-(t:Tile) RETURN t";
        Iterable<Tile> result = Neo4jSessionFactory.getInstance()
                .getNeo4jSession().query(Tile.class, query, params);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            result.forEach(tile -> addHex(tile, wo));
        }
    }

    public void loadGovernment() {
        String name = WorldOrder.getFromYear() + "";
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        params.put("name", name);
        String query = "MATCH (t:Territory{mapKey:$mapKey})-[:OCCUPIED]-(s:State)-[:DURING]-(:Year{name:$name}) RETURN s";
        State n = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .queryForObject(State.class, query, params);
        if (n != null) {
            polity.setOwner(n);
        } else {
            polity = null;
        }
    }

    public void loadBorders() {
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", mapKey);
        String query = "MATCH (t:Territory{mapKey:$mapKey})-[:BORDERS]->(b:Border) RETURN b";
        Iterable<Border> result = Neo4jSessionFactory.getInstance()
                .getNeo4jSession().query(Border.class, query, params);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            result.forEach(t -> borders.add(t));
        }
    }

    public void loadTileFacts() {
        if (tileLinks.size() < 20) {
            tileLinks.stream().forEach(i -> loadFacts(i.getTile(), year));
        } else {
            tileLinks.parallelStream().forEach(i -> loadFacts(i.getTile(), year));
        }
    }

    private static void loadFacts(Tile t, int y) {
        /**
         * Returns map of tile Id, tile population, urban population, and production capital (wealth) for the given year
         */
        String query = "MATCH (t:Tile{h3Id:" + t.getH3Id() + "}) CALL wog.getTileDataMap(t, "+ y +") YIELD value RETURN value";
        Map<String, Object> params = new HashMap<>();
        params.put("h3Id", t.getH3Id());
        params.put("year", y);
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, Collections.EMPTY_MAP, false)
                    .queryResults().forEach(r -> t.loadFacts( (Map<String, Object>)r.get("value")));
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
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", this.getMapKey());
        params.put("name", "Residents of " + this.getMapKey());
        String query = "MATCH (:Territory{mapKey:$mapKey})-[:REPRESENTS_POPULATION]-(c:CommonWeal{name:$name}) RETURN c";
        this.commonWeal = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(CommonWeal.class, query, params);
        commonWeal.setTerritory(this);
        commonWeal.loadPersonMap();
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

    //------------------------------------------------------ Abandoned code ------------------------------------------//

//    public Territory(String name, String abbr, Double area, int year, int resolution, Feature feature) {
//        this();
//        this.year = year;
//        this.creationStep = (year - 1816) * 52L;
//        this.tileLinks = new HashSet<>();
//        this.name = name;
//        this.abbr = abbr;
//        this.resolution = resolution;
//        this.mapKey = name + " of " + year;
//        if (area != null) {this.area = area;} else {this.area = 0.0;}
//        buildTerritory(feature);
//    }

//    public Territory(String name, String abbr, Double area, int year, int resolution) {
//        this();
//        this.year = year;
//        this.creationStep = (year - 1816) * 52L;
//        this.tileLinks = new HashSet<>();
//        this.name = name;
//        this.abbr = abbr;
//        this.resolution = resolution;
//        if (area != null) {this.area = area;} else {this.area = 0.0;}
//    }
//


//    public Territory(Feature input, int year) {
//        this();
//        this.name = input.getProperty("NAME");
//        this.abbr = input.getProperty("WB_CNTRY");
//        this.year = year;
//        this.mapKey = name + " of " + year;
//        if (input.getProperty("AREA") != null) {
//            this.area = input.getProperty("AREA");
//        } else {
//            this.area = 0.0;
//        }
//        if (input.getProperty("CCODE") != null) {
//            this.cowcode = "" + input.getProperty("CCODE");
//        } else {
//            this.cowcode = "";
//        }
//        buildTerritory(input);
//    }

//    public int getResolution() {
//        return resolution;
//    }
//
//    public void setResolution(int resolution) {
//        this.resolution = resolution;
//    }

//    public void buildTerritory(Feature inputFeature) {
//        getTileIdsFromPolygons(inputFeature);
//        tileLinks.addAll(getTilesFromAddresses());
//    }

//    public void updateOccupation(Feature inputFeature) {
//        if (inputFeature.getProperty("AREA") != null) {
//            this.area = this.area + (Double) inputFeature.getProperty("AREA");
//        }
//        getTileIdsFromPolygons(inputFeature);
//        tileLinks.addAll(getTilesFromAddresses());
//    }

//    private void getTileIdsFromPolygons(@NotNull Feature inputFeature) {
//        // All territory elements are multipolygons, even if there is only one polygon in the array
//        MultiPolygon geom = (MultiPolygon) inputFeature.getGeometry();
//        int numPolygons = geom.getCoordinates().size();
//
//        Set<Long> tempList5 = new HashSet<>();
//
//        for (int i = 0; i < numPolygons; i++) {
//            List<List<GeoCoord>> holes = new ArrayList<>();
//            int numInnerLists = geom.getCoordinates().get(i).size();
//
//            List<LngLatAlt> coordinates = geom.getCoordinates().get(i).get(0);
//            List<GeoCoord> boundaryCoordinates = swapCoordinateOrdering(coordinates);
//
//            if (numInnerLists > 1) {        // second thru last elements are holes in the outer polygon
//                for (int il=1; il<numInnerLists; il++) {
//                    List<GeoCoord> hole = swapCoordinateOrdering(geom.getCoordinates().get(i).get(il));
//                    holes.add(hole);
//                }
//            }
//            try {
//                H3Core h3 = H3Core.newInstance();
//                tempList5.addAll(h3.polyfill(boundaryCoordinates, holes, resolution + 1));
//                for (Long t5 : tempList5) {
//                    Long t5Parent = h3.h3ToParent(t5, resolution);
//                    List<Long> t5Siblings = h3.h3ToChildren(t5Parent, resolution + 1);
//                    if (tempList5.contains(t5Siblings.get(0))) {
//                        linkedTileIds.add(t5Parent);
//                    }
//                }
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//        }
//    }

    //    public Set<Long> getLinkedTileIds() { return linkedTileIds; }


//    public Inclusion addIncludedTile(Tile tile) {
//        Inclusion occupied = new Inclusion(this, tile, year);
//        this.tileLinks.add(occupied);
//        return occupied;
//    }


    //    public Set<Inclusion> getTilesFromAddresses() {
//        Set<Inclusion> tiles = new HashSet<>();
//        for (Long h : linkedTileIds) {
//            if (globalHexes.containsKey(h)) {
//                Tile t = globalHexes.get(h);
//                this.occupation(t);
//            } else  {
//                Tile t = new Tile(h);
//                globalHexes.put(h, t);
//                this.occupation(t);
//            }
//        }
//        return tiles;
//    }


//    private List<GeoCoord> swapCoordinateOrdering(@NotNull List<LngLatAlt> coordinates) {
//        List<GeoCoord> h3Coords = new ArrayList<>();
//        for (LngLatAlt c : coordinates) {
//            GeoCoord gc = new GeoCoord(c.getLatitude(), c.getLongitude());
//            h3Coords.add(gc);
//        }
//        return h3Coords;
//    }

//

//    public void loadBaselinePopulation(SimState simState) {
//        WorldOrder worldOrder = (WorldOrder) simState;
//        if (cowcode != "NA") {
//            Long pop;
//            Long upop;
//            int num = tileLinks.size();
//            int unum;
//
//            if (WorldOrder.DEBUG) {
//                System.out.println(mapKey + " has " + num + " tiles. ");
//            }
//
//            MersenneTwisterFast random = new MersenneTwisterFast();
//            ZipfDistribution distribution;
//            ZipfDistribution urbanDistrib;
//            int[] uLevels = {0};
//            int[] urbanizedIndexes = {0};
//            int uProportion = 1;
//            Integer[] sortedULevIdx = {0};
//
//            Map<String, Object> params = new HashMap<>();
//            params.put("cowcode", cowcode);
//            params.put("startYear", WorldOrder.getFromYear());
//            params.put("untilYear", WorldOrder.getUntilYear());
//
//            String popQuery = "MATCH (t:Territory)-[o]-(s:State{cowcode:$cowcode})-[:POPULATION]-(pf:PopulationFact)-[:DURING]-(y:Year)," +
//                    "(d:Dataset{name:'NMC Supplemental'})" +
//                    "WHERE (d)-[:CONTRIBUTES]-(pf) AND $startYear < y.began.year < $untilYear " +
//                    "WITH pf, y ORDER BY y.began.year " +
//                    "RETURN pf LIMIT 1";
//            Fact popFact = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                    .queryForObject(Fact.class, popQuery, params);
//
//            String uPopQuery = "MATCH (t:Territory)-[o]-(s:State{cowcode:$cowcode})-[:URBAN_POPULATION]-(uf:UrbanPopulationFact)-[:DURING]-(y:Year)," +
//                    "(d:Dataset{name:'NMC Supplemental'})" +
//                    "WHERE (d)-[:CONTRIBUTES]-(uf) AND $startYear < y.began.year < $untilYear " +
//                    "WITH uf, y ORDER BY y.began.year " +
//                    "RETURN uf LIMIT 1";
//            Fact uPopFact = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                    .queryForObject(Fact.class, uPopQuery, params);
//
//            if (popFact == null) {
//                pop = num * 1000L;
//            } else {
//                pop = (Long) popFact.getValue() * 1000;
//            }
//
//            // must get the length of the urbanized tile array before we can build it
//            if (uPopFact == null) {
//                upop = 0L;
//                unum = 0;
//            } else {
//                upop = (Long) uPopFact.getValue() * 1000L;
//                int urbanTiles = (int)(upop / 50000);
//                if (urbanTiles % 2 == 0) {
//                    unum = urbanTiles / 2;
//                } else {
//                    unum = (urbanTiles + 1) / 2;
//                }
//                unum = Math.min(unum, num);
//            }
//
//            distribution = new ZipfDistribution(new MTFApache(random), num, 1.7);
//
//            int[] levels = distribution.sample(num);
//            int distSum = IntStream.of(levels).sum();
//            int pProportion = pop.intValue() / distSum;
//
//            if (unum > 1) {
//                // Get a sorted index of the population levels (levels are sorted, index describes the sort order)
//                IndexReverseSorter sorter = new IndexReverseSorter(levels);
//                final Integer[] sortedLevelsIdx = sorter.createIndexArray();
//                Arrays.sort(sortedLevelsIdx, sorter);
//                // Indices of urbanized populations (highest levels) limited to number of values above 50k
//                urbanizedIndexes = IntStream.range(0, unum).map(i -> sortedLevelsIdx[i]).toArray();
//                // new zeta-distribution for urbanized population values (array of dividend)
//                urbanDistrib = new ZipfDistribution(new MTFApache(random), unum, 1.6);
//                uLevels = urbanDistrib.sample(unum);
//                // get proportion divisor and fraction 1/divisor
//                int urbSum = IntStream.of(uLevels).sum();
//                uProportion = upop.intValue() / urbSum;
//                // get a sorted index of the
//                IndexReverseSorter uSorter = new IndexReverseSorter(uLevels);
//                sortedULevIdx = uSorter.createIndexArray();
//                Arrays.sort(sortedULevIdx, uSorter);
//            }
//
//            if (num > 0) {
//                int pacer = 0;
//                int uPacer = 0;
//                int summedPopulation = 0;
//                int summedUrbanPop = 0;
//                for (Inclusion h : tileLinks) {
//                    Tile t = h.getTile();
//                    // Applying the population proportion to this tile is simple: multiply the level from the samples
//                    // array to the proportion of the population represented by each portion of the total
//                    int thisPop = pProportion * levels[pacer];
//                    summedPopulation += thisPop;
//                    t.setPopulation(thisPop);
//                    // Applying the urban population proportion to this tile is much more involved. If there is 1 or 0
//                    // tiles with an urban population, apply the total urban population (maybe 0). If there are more
//                    // than 2 tiles with an urban population, get the rank from the main population from the sorted
//                    // array of indexes, match with the same-ranked index of urban population levels, then multiply
//                    // that value to the proportion of the urban population represented by the levels.
//                    int thisUpop = 0;
//                    if (unum < 2) {
//                        thisUpop = upop.intValue();
//                        summedUrbanPop += thisUpop;
//                        t.setUrbanization(thisUpop);
//                    } else {
//                        if (uPacer < unum) {
//                            for (int i=0; i<unum; i++) {
//                                if (pacer == urbanizedIndexes[i]) {
//                                    int uIndex = sortedULevIdx[i];
//                                    int uLevel = uLevels[uIndex];
//                                    thisUpop = uLevel * uProportion;
//                                    summedUrbanPop += thisUpop;
//                                    t.setUrbanization(thisUpop);
//                                    uPacer++;
//                                }
//                            }
//                        } else {
//                            summedUrbanPop += thisUpop;
//                            t.setUrbanization(thisUpop);
//                        }
//                    }
//                    Neo4jSessionFactory.getInstance().getNeo4jSession().save(t, 0);
//                    worldOrder.getTiles().put(t.getH3Id(), t);
//                    pacer++;
//                }
//                double near = (summedPopulation * 1.0) / (pop + 1); // prevent zero division errors
//                double nearU = (summedUrbanPop * 1.0) / (upop + 1); // still returns 0.
//                if (WorldOrder.DEBUG) {
//                    System.out.println(mapKey + " has population " + pop + " and the distributed population is "
//                            + summedPopulation + ", which is " + near + " of the data. \n The simulated urban population is "
//                            + summedUrbanPop + " which is " + nearU + " of the data: " + upop);
//                }
//                population = summedPopulation;
//                urbanPopulation = summedUrbanPop;
//            } else {
//                int summedPopulation = 0;
//                for (Inclusion i : tileLinks) {
//                    Tile t = i.getTile();
//                    t.setPopulation(100);
//                    summedPopulation += 100;
//                    worldOrder.getTiles().put(t.getH3Id(), t);
//                }
//                population = summedPopulation;
//                if (WorldOrder.DEBUG) {
//                    System.out.println(mapKey + " has a contrived population of 100 pax / tile, or " + summedPopulation);
//                }
//            }
//        }
//        Neo4jSessionFactory.getInstance().getNeo4jSession().save(this, 0);
//    }
}
