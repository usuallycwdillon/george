package edu.gmu.css.hexFactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.data.DatasetData;
import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.Feature;
import org.geojson.FeatureCollection;
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

    private static Map<Integer, Dataset> geodatasets = DatasetData.GEODATASETS;
    private static int resolution = 4;
    private static int unclaimedIndex = 0;

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
                    .map(feature -> new Territory(feature, y))
                    .collect(Collectors.toList()));

            for (Territory t : d.getFacts()) {
                Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
                Transaction tx = session.beginTransaction();
                session.save(t, 2);
                tx.commit();
                System.out.println("Saved " + t.getMapKey() + " to the database at " + LocalTime.now());

                territories.put(t.getMapKey(), t);
            }

            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
            Transaction tx = session.beginTransaction();
            session.save(d, 1);
            tx.commit();
            session.clear();
            System.out.println("Completed " + y + " at " + LocalTime.now());
        }

        new HexFactory().joinHexes();

        for (int year : geodatasets.keySet()) {
            new HexFactory().findTerritoryNeighbors(year);
        }
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

        String query = "MATCH (t1:Territory{year:{year}})-[:OCCUPATION_OF]->(h1:Tile)-[:ABUTS]-(h2:Tile)<-[:OCCUPATION_OF]-(t2:Territory{year:{year}})\n" +
                "WHERE t1 <> t2 AND t1.year = t2.year\n" +
                "MERGE (t1)-[b:BORDERS{during:{year}}]->(t2)\n" +
                "WITH t1, t2\n" +
                "MATCH (y:Year{name:toString({year})})\n" +
                "MERGE (y)-[d:DURING]->(t1)\n" +
                "MERGE (t2)-[e:DURING]->(y)";

        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));
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

}

