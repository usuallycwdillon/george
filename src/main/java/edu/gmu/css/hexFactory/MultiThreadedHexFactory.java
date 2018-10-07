package edu.gmu.css.hexFactory;


import com.fasterxml.jackson.databind.ObjectMapper;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.FeatureCollection;
import org.geojson.Feature;
import org.geojson.GeoJsonObject;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;
import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.config.Config;
import com.hazelcast.core.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.*;

public class MultiThreadedHexFactory {

    private static String[] yearString = {"1815", "1880", "1914", "1945", "1994"};
//    private static int[] yearInt = {1815, 1880, 1914, 1945, 1994};
    private static int[] yearInt = {1815};
    public static Map<String, Tile> globalHexes;
    private static Map<String, Set<String>> hexTerritoryMap;
    private static Map<String, Territory> territories;

    private static int count = 0;
    private static int resolution = 4;
    private static int unclaimedIndex = 0;

    public static HazelcastInstance hzi;

    public MultiThreadedHexFactory() {
    }

    private void joinHexes() {
        Map<String, Tile> missingHexes = new HashMap<>();
        Iterator it = globalHexes.entrySet().iterator();
        while (it.hasNext()) {
            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
            Transaction tx = session.beginTransaction();

            Map.Entry pair = (Map.Entry) it.next();
            Tile tile = (Tile) pair.getValue();

            for (String h : tile.getNeighborAddresses()) {
                if (globalHexes.containsKey(h)) {
                    tile.addNeighbor(globalHexes.get(h));
                    session.save(tile);
                } else {
                    Tile newHex = new Tile(h);
                    missingHexes.put(h, newHex);
                    tile.addNeighbor(newHex);
                    session.save(tile);
                }
            }
            tx.commit();
            it.remove(); // avoids a ConcurrentModificationException
        }

        if (missingHexes.size() != 0) {
            globalHexes.putAll(missingHexes);
//                joinHexes();
        }

        System.out.println("There were " + missingHexes.size() + " missing hex Tiles.");
    }

    private void findTerritoryNeighbors(int year) {
        String query = "MATCH (t1:Territory{year:{year}})-[:OCCUPATION_OF]->(h1:Tile)-[:ABUTS]-(h2:Tile)<-[:OCCUPATION_OF]-(t2:Territory{year:{year}}) " +
                "WHERE t1 <> t2 AND t1.year = t2.year " +
                "MERGE (t1)-[b:BORDERS{during:{year} } ]->(t2) " +
                "MERGE (t1)-[d:DURING]->(y:Year{name:toString({year})}) " +
                "MERGE (t2)-[e:DURING]->(y)";
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));
    }

    public static void main(String args[]) throws Exception {

        Config hazelConfig = new Config();
        // For testing and debugging locally, we can create a two-node hazelcast cluster within this jvm
        hzi = Hazelcast.newHazelcastInstance(hazelConfig);

        // The hazelcast client object provides access to the cluster from this application
        ClientConfig hazelClientConfig = new ClientConfig();
        HazelcastInstance hazelcastClient = HazelcastClient.newHazelcastClient(hazelClientConfig);

        IExecutorService executor = hzi.getExecutorService("executor");

        globalHexes = hzi.getMap("globalHexes");
//        hexTerritoryMap = hzi.getMap("hexTerritoryMap");
        hexTerritoryMap = new HashMap<>();
        territories = hzi.getMap("territories");

        for (int y : yearInt) {
            // /home/cw/Code/george/src/main/data/historicalBasemaps/world_1815.geojson
            String filepath = "src/main/data/historicalBasemaps/world_" + y + ".geojson";
            File file = new File(filepath);
            if (!file.exists() || !filepath.endsWith(".geojson")) {
                throw new Exception("Well, that didn't work. Was it on the right path?: " + filepath);
            }

            FeatureCollection collection = null;
            try (InputStream inputStream = new FileInputStream(file)) {
                collection = new ObjectMapper().readValue(inputStream, FeatureCollection.class);
            } catch (Exception e) {
                e.printStackTrace();
            }


            String filename = "world_" + y + ".geojson";
            Dataset dataset =  Neo4jSessionFactory.getInstance().getNeo4jSession()
                    .queryForObject(Dataset.class, "MATCH (ds:Dataset{filename:{filename}}) RETURN ds",
                            MapUtil.map("filename", filename));

            Iterator<Feature> iterator = collection.iterator();
            while (iterator.hasNext()) {
                Feature thisFeature = iterator.next();
                String iname = thisFeature.getProperty("NAME");

                if (iname.equals("Antarctica")) {
                    iterator.next();
                } else {
                    String name = iname;
                    if (name.equals("unclaimed")) {
                        name = iname + unclaimedIndex;
                        unclaimedIndex++;
                    }

                    Territory t;
                    String keyname = name + " of " + y;
                    if (territories.containsKey(keyname)) {
                        System.out.println("...and we seem to have a key match in the territories map...");
                        t = territories.get(keyname);
                        executor.execute(new UpdateTerritoryTask(t, thisFeature));
                    } else {
                        Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
                        Transaction tx = session.beginTransaction();

                        System.out.println("We're going to create a new territory.");
                        t = new Territory();
                        executor.execute(new CreateTerritoryTask(t, thisFeature, name, resolution, y));

                        dataset.addFacts(t);
                        session.save(dataset);

                        tx.commit();
                        session.clear();
                    }
                }
            }
        }

        System.out.println("About to lattice them hexes...");
        new MultiThreadedHexFactory().joinHexes();

        for (int y : yearInt) {
            new MultiThreadedHexFactory().findTerritoryNeighbors(y);
        }

        hazelcastClient.shutdown();

        System.exit(0);
    }

}

