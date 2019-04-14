package edu.gmu.css.hexFactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uber.h3core.H3Core;
import com.uber.h3core.util.GeoCoord;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.data.GeoDatasetData;
import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.queries.TerritoryQueries;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.*;
import org.jetbrains.annotations.NotNull;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * The HexFactory reads geojson files, finds the H3 hexagon tiles that fit in each Feature (at some resolution set in the
 * 'Territory' class), associates the geojson file with it's 'Territory' features, associates the Territory with it's
 *  hex tiles, creates a regular lattice grid of all the hex tiles in the initial feature collection, finds the borders
 *  between territories based on the hex tiles they occupy/include, and writes out new geojson files for each territory
 *  using the tiles as individual polygons in a multipolygon feature.
 */

public class HexFactory {

    private static Map<Integer, Dataset> geodatasets = GeoDatasetData.GEODATASETS;
    public static Map<String, Territory> territories = new HashMap<>();
    public static Map<Long, Tile> globalHexes = new HashMap<>();
    public static Map<Long, Tile> missingHexes = new HashMap<>();

    public static boolean DEBUG = true;


    public static void main( String[] args ) {
        // Adding a few printouts to ease monitoring
        LocalTime startTime = LocalTime.now();
        System.out.println("The factory started working at: " + startTime);

        new HexFactory().factoryLoop();

        // Hex Tiles get joined globally, because their arrangement is fixed, regardless of which tiles are in which
        // territory in any given year.
        new HexFactory().joinHexes();

        // The missing hexes returned by the joinHexes method together create the outline of all continents and islands.
        // They can be treated as a territory (one for each data year) and any territory that borders a sea,

        // Territory neighbors and munging territories with COW State facts are both dependent on the year, so we can
        // operate on both functions together.
        for (int year : geodatasets.keySet()) {
            new HexFactory().findTerritoryNeighbors(year);
            new HexFactory().makeCowRelations(year);
        }


        // Finally, we dump the hex-shaped multi-polygons into files for observation and visual validation (do these
        // hex
        if(DEBUG) {System.out.println("\n...making geojson files...");}
        Collection<Territory> territoryStream = territories.values().stream()
                .filter(t -> !t.getName().equals("Antarctica"))
                .collect(Collectors.toList());
        makeFeatureCollection(territoryStream);

        new HexFactory().isolateOccupationEdges();
        new HexFactory().makeStateBorders();

//        new HexFactory().adHocTerritory();

        System.exit(0);
    }

    private static List<Feature> geoJsonProcessor(String filename) {
        // Parse the GeoJSON file
        String filepath = "src/main/resources/historicalBasemaps/" + filename;
        File file = new File(filepath);

        List<Feature> features = new ArrayList<>();
        try (InputStream inputStream = new FileInputStream(file)) {
            features = new ObjectMapper().readValue(inputStream, FeatureCollection.class).getFeatures();
        } catch (Exception e) {
            System.out.println("Well, that didn't work. Was it on the right path?: " + filepath);
            e.printStackTrace();
        }
        return features;
    }

    private void joinHexes() {
        System.out.println("The time is " + LocalTime.now() + " and it's about to lattice them hexes...");
        Iterator it = globalHexes.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();
            updateHexNeighbors((Long)pair.getKey());
        }
        if (missingHexes.size() != 0) {
            globalHexes.putAll(missingHexes);
        }
        System.out.println("There were " + missingHexes.size() + " missing hex Tiles.");
    }

    private void findTerritoryNeighbors(int year) {
        System.out.println("The simulation is ready to find territorial borders during " + year + " at: " + LocalTime.now());
        String query = "MATCH (t1:Territory{year:{year}})-[:INCLUDES]->(tt1:Tile)-[:ABUTS]-(tt2:Tile)<-[:INCLUDES]-(t2:Territory{year:{year}})\n" +
                "  WHERE t1 <> t2 AND tt1 <> tt2 \n" +
                "WITH [t1.mapKey, t2.mapKey] AS pair ORDER BY pair \n" +
                "WITH DISTINCT pair AS pairs \n" +
                "FOREACH (p IN CASE WHEN pairs[0] < pairs[1] THEN [1] ELSE [] END | \n" +
                "  MERGE (b:Border{year:{year}, subjects:pairs}) \n" +
                "  MERGE (y:Year{name:toString({year})}) \n" +
                "  MERGE (t0:Territory{mapKey:pairs[0]}) \n" +
                "  MERGE (t1:Territory{mapKey:pairs[1]}) \n" +
                "  MERGE (b)-[:DURING{year:{year}}]->(y) \n" +
                "  MERGE (t0)-[:BORDERS{during:{year}}]->(b) \n" +
                "  MERGE (t1)-[:BORDERS{during:{year}}]->(b) \n" +
                ")";

        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));

        if(DEBUG) {System.out.println("Connected the borders of territories as of " + year );}
    }

    private void updateHexNeighbors(Long h) {
        Tile tile = globalHexes.get(h);
        for (Long n : tile.getNeighborIds()) {
            if (globalHexes.containsKey(n)) {
                Tile neighbor = globalHexes.get(n);
                tile.addNeighbor(neighbor);
            } else {
                Tile newHex = new Tile(n);
                missingHexes.put(n, newHex);
                tile.addNeighbor(newHex);
            }
        }
        Neo4jSessionFactory.getInstance().getNeo4jSession().save(tile, 1);
    }

    private static void makeFeatureCollection(Collection<Territory> territories) {
        for (Territory t : territories) {
            t.loadBaselinePopulation();
            FeatureCollection featureCollection = new FeatureCollection();
            String key = t.getMapKey();
            String filepath = "src/main/resources/historicalHexMaps/" + t.getYear() + "/" + key + "_poly.geojson";
            Feature territoryFeature = makeFeatures(t);
            featureCollection.add(territoryFeature);
            featureCollection = makeFeatureCollectionPoly(t);
            ObjectMapper geoFeature = new ObjectMapper();
            try {
                geoFeature.writeValue(new File(filepath), featureCollection);
            } catch (Exception e) {
                e.printStackTrace();
            }
//            filepath = "src/main/resources/historicalHexMaps/" + t.getYear() + "/" + key + "_point.geojson";
//            featureCollection = makeFeatureCollectionPoint(t);
//            ObjectMapper pointFeature = new ObjectMapper();
//            try {
//                pointFeature.writeValue(new File(filepath), featureCollection);
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
        }
    }

    private static void makeCowRelations(int year) {
        if(DEBUG) {
            System.out.println("Linking territory data to war data by COW ccode for " + year + " at: " + LocalTime.now());
        }
        String query = "MATCH (t:Territory{year:{year}}), (s:State)-[m:MEMBER]-(f:MembershipFact) \n" +
                "WHERE f.from.year <= {year} AND f.until.year >= {year} AND s.cowcode = t.cowcode \n" +
                "MERGE (s)-[h:OCCUPIED]->(t)";
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));
    }

    //MATCH (t:Territory{year:1816}), (s:State)-[:MEMBER]-(f:MembershipFact) WHERE t.cowcode = s.cowcode AND f.from.year < 1880 MERGE (s)-[:OCCUPIED]->(t)

    private static Feature makeFeatures(Territory t) {
        Set<Long> hexList = new HashSet<>(t.getLinkedTileIds());
        Feature territoryFeature = new Feature();
        MultiPolygon multiPolyTerritory = new MultiPolygon();

        try {
            H3Core h3 = H3Core.newInstance();
            for (Long h : hexList) {
                Polygon poly = new Polygon();
                List<GeoCoord> outerPolyCoords = h3.h3ToGeoBoundary(h);
                List<LngLatAlt> lngLatAlts = new ArrayList<>();
                for (GeoCoord gc : outerPolyCoords) {
                    lngLatAlts.add(lngLatAlt(gc));
                }
                lngLatAlts.add(lngLatAlt(outerPolyCoords.get(0)));
                poly.setExteriorRing(lngLatAlts);
                multiPolyTerritory.add(poly);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        territoryFeature.setGeometry(multiPolyTerritory);
        territoryFeature.setProperty("NAME", t.getName());
        territoryFeature.setProperty("ABBR", t.getAbbr());
        territoryFeature.setProperty("CCODE", t.getCowcode());
        territoryFeature.setProperty("YEAR", t.getYear());

        return territoryFeature;
    }

    private static FeatureCollection makeFeatureCollectionPoly(Territory t) {
        Set<Inclusion> hexList = new HashSet<>(t.getTileLinks());
        FeatureCollection fc = new FeatureCollection();
        for(Inclusion i : hexList) {
            Tile h = i.getTile();
            int upop = (int)(h.getPopulation() * h.getUrbanization());
            Feature border = new Feature();
            border.setId(h.getAddress());
            border.setProperty("H3ID", h.getH3Id());
            border.setProperty("POPULATION", h.getPopulation());
            border.setProperty("URBAN_POP", upop);
            border.setProperty("H3Address", h.getAddress());
            Polygon poly = new Polygon();
            try {
                H3Core h3 = H3Core.newInstance();
                List<GeoCoord> outerPolyCoords = h3.h3ToGeoBoundary(h.getH3Id());
                List<LngLatAlt> lngLatAlts = new ArrayList<>();
                for (GeoCoord gc : outerPolyCoords) {
                    lngLatAlts.add(lngLatAlt(gc));
                }
                lngLatAlts.add(lngLatAlt(outerPolyCoords.get(0)));
                poly.setExteriorRing(lngLatAlts);
                border.setGeometry(poly);
            } catch (Exception e) {
                e.printStackTrace();
            }
            fc.add(border);
        }
        return fc;
    }

    private static FeatureCollection makeFeatureCollectionPoint(Territory t) {
        Set<Inclusion> hexList = new HashSet<>(t.getTileLinks());
        FeatureCollection fc = new FeatureCollection();
        for(Inclusion i : hexList) {
            Tile h = i.getTile();
            int upop = (int)(h.getPopulation() * h.getUrbanization());
            Feature tileFeature = new Feature();
            tileFeature.setId(h.getAddress());
            tileFeature.setProperty("POPULATION", h.getPopulation());
            tileFeature.setProperty("H3ID", h.getH3Id());
            tileFeature.setProperty("URBAN_POP", upop);
            tileFeature.setProperty("H3Address", h.getAddress());
            Point point = new Point();
            try {
                H3Core h3 = H3Core.newInstance();
                GeoCoord center = h3.h3ToGeo(h.getH3Id());
                point.setCoordinates(lngLatAlt(center));
                tileFeature.setGeometry(point);
            } catch (Exception e) {
                e.printStackTrace();
            }
            fc.add(tileFeature);
        }
        return fc;
    }


    static private LngLatAlt lngLatAlt(GeoCoord coordinates) {
        LngLatAlt lla = new LngLatAlt();
        lla.setLatitude(coordinates.lat);
        lla.setLongitude(coordinates.lng);
        return lla;
    }

    private void makeStateBorders() {
        // This won't work unless state system data has already been loaded.
        String query = "MATCH (s1:State)-[o1:OCCUPIED]->(t1:Territory)-[b1:BORDERS]->(b:Border)<-[b2:BORDERS]-(t2:Territory)-[o2:OCCUPIED]-(s2:State) \n" +
                "WHERE s1<>s2 AND t1<>t2 AND o1.during=o2.during \n" +
                "MERGE (s1)-[:SHARES_BORDER{during:b.year}]->(b)<-[:SHARES_BORDER{during:b.year}]-(s2) ";
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map());
    }

    private void isolateOccupationEdges() {
        String query = "MATCH (s:State)-[o:OCCUPIED]-(t:Territory) SET o.during = t.year";
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map());
    }

    private void factoryLoop() {
        for (Map.Entry entry : geodatasets.entrySet()) {
            int y = (int)entry.getKey();
            Dataset d = (Dataset) entry.getValue();
            String filename = "cowWorld_" + y + ".geojson";

            // Checking that the dataset will save before doing any work; fail early, please.
            Neo4jSessionFactory.getInstance().getNeo4jSession().save(d,0);

            List<Feature> features = geoJsonProcessor(filename);
            d.addAllFacts(features.stream()
                    .filter(feature -> !feature.getProperty("NAME").equals("Antarctica"))
                    .map(feature -> new Territory(feature, y))
                    .collect(Collectors.toList()));

            // Get rid of any territories too small to have any tiles
            List<Territory> irrelevants = new ArrayList<>();
            for (Entity e : d.getFacts()) {
                Territory t = (Territory) e;
                if (t.getTileLinks().size() <= 0) {
                    irrelevants.add(t);
                }
            }
            for (Territory t : irrelevants) {
                d.removeFact(t);
            }

            // Save the territories into the database
            for (Entity e : d.getFacts()) {
                Territory t = (Territory) e;
                Neo4jSessionFactory.getInstance().getNeo4jSession().save(t, 1);
                if(DEBUG) {System.out.println("Saved " + t.getMapKey() + " to the database at " + LocalTime.now());}
                territories.put(t.getMapKey(), t);
            }

            Neo4jSessionFactory.getInstance().getNeo4jSession().save(d, 1);
            if(DEBUG) {System.out.println("Completed " + y + " at " + LocalTime.now());}
        }
    }

    private void adHocTerritory() {
        String key = "Coastal Regions 1816";
        Territory t = TerritoryQueries.loadWithRelations(key);
        List<Territory> territoryList = new ArrayList<>();
        territoryList.add(t);
        makeFeatureCollection(territoryList);
    }

}

