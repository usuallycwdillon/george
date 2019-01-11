package edu.gmu.css.hexFactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uber.h3core.H3Core;
import com.uber.h3core.util.GeoCoord;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.data.GeoDatasetData;
import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.*;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

public class HexFactory {

    private static Map<Integer, Dataset> geodatasets = GeoDatasetData.GEODATASETS;
    public static Map<String, Territory> territories = new HashMap<>();
    public static Map<Long, Tile> globalHexes = new HashMap<>();
    public static Map<Long, Tile> missingHexes = new HashMap<>();


    public static void main( String[] args ) {
        // Adding a few printouts to ease monitoring
        LocalTime startTime = LocalTime.now();
        System.out.println("The factory started working at: " + startTime);

        for (Map.Entry entry : geodatasets.entrySet()) {
            int y = (int)entry.getKey();
            Dataset d = (Dataset) entry.getValue();
            String filename = "cowWorld_" + y + ".geojson";

            List<Feature> features = geoJsonProcessor(filename);
            d.addAllFacts(features.stream()
                    .filter(feature -> !feature.getProperty("NAME").equals("Antarctica"))
                    .map(feature -> new Territory(feature, y))
                    .collect(Collectors.toList()));

            for (Entity e : d.getFacts()) {
                Territory t = (Territory) e;
                Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
                Transaction tx = session.beginTransaction();
                session.save(t, 1);
                tx.commit();
                System.out.println("Saved " + t.getMapKey() + " to the database at " + LocalTime.now());
                territories.put(t.getMapKey(), t);
            }

            @SuppressWarnings("duplication")
            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
            Transaction tx = session.beginTransaction();
            session.save(d, 1);
            tx.commit();
            session.clear();
            System.out.println("Completed " + y + " at " + LocalTime.now());
        }

        // Hex Tiles get joined globally, because their arrangement is fixed, regardless of which tiles are in which
        // territory in any given year.
        new HexFactory().joinHexes();

        // Territory neighbors and munging territories with COW State facts are both dependent on the year, so we can
        // operate on both functions together.
        for (int year : geodatasets.keySet()) {
            new HexFactory().findTerritoryNeighbors(year);
            new HexFactory().makeCowRelations(year);
        }

        // Finally, we dump the hex-shaped multi-polygons into files for observation and visual validation (do these
        // hex
        System.out.println("\n...making geojson files...");
        Collection<Territory> territoryStream = territories.values().stream()
                .filter(t -> !t.getName().equals("Antarctica"))
                .collect(Collectors.toList());
        makeFeatureCollection(territoryStream);


        new HexFactory().makeStateBorders();

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
        System.out.println("The simulation is ready to find territory neighbors for " + year + " at: " + LocalTime.now());
        String query = "MATCH (t1:Territory{year:{year}})-[:INCLUDES]->(h1:Tile)-[:ABUTS]-(h2:Tile)<-[:INCLUDES]-(t2:Territory{year:{year}})\n" +
                "WHERE t1 <> t2 AND t1.year = t2.year\n" +
                "MERGE (t1)-[b:BORDERS{during:{year}}]->(t2)\n" +
                "WITH t1, t2\n" +
                "MATCH (y:Year{name:toString({year})})\n" +
                "MERGE (y)-[d:DURING]->(t1)\n" +
                "MERGE (t2)-[e:DURING]->(y)";

        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));

        System.out.println("Connected the borders of territories as of " + year );
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
        Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
        Transaction tx = session.beginTransaction();
        session.save(tile, 1);
        tx.commit();
        session.clear();
    }

    private static void makeFeatureCollection(Collection<Territory> territories) {
        for (Territory t : territories) {
            FeatureCollection featureCollection = new FeatureCollection();
            String key = t.getMapKey();
            String filepath = "src/main/resources/historicalHexMaps/" + t.getYear() + "/" + key + ".geojson";
            Feature territoryFeature = makeFeatures(t);
            featureCollection.add(territoryFeature);
            ObjectMapper geoFeature = new ObjectMapper();
            try {
                geoFeature.writeValue(new File(filepath), featureCollection);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static void makeCowRelations(int year) {
        System.out.println("Linking territory data to war data by COW ccode for " + year + " at: " + LocalTime.now());
        String query = "MATCH (t:Territory{year:{year}}), (s:State)-[m:MEMBER]-(f:MembershipFact)\n" +
                "WHERE f.from.year <={year} AND f.until.year >= {year} AND s.cowcode = t.cowcode \n" +
                "MERGE (s)-[h:OCCUPIED]->(t)";
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));
    }

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

    static private LngLatAlt lngLatAlt(GeoCoord coordinates) {
        LngLatAlt lla = new LngLatAlt();
        lla.setLatitude(coordinates.lat);
        lla.setLongitude(coordinates.lng);
        return lla;
    }

    private void makeStateBorders() {
        // This won't work unless state system data has already been loaded.
        String query = "MATCH (s:State)-[:OCCUPIED]-(t:Territory)-[b:BORDERS]-(tt:Territory)-[:OCCUPIED]-(ss:State) \n" +
                "WHERE s<>ss AND t<>tt AND t.year=tt.year=b.during\n" +
                "MERGE (s)-[:BORDERS_WITH{during:b.during}]->(ss)";
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map());
    }

}

