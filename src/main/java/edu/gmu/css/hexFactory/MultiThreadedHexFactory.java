//package edu.gmu.css.hexFactory;
//
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import edu.gmu.css.agents.Tile;
//import edu.gmu.css.data.DatasetData;
//import edu.gmu.css.entities.Dataset;
//import edu.gmu.css.entities.Territory;
//import edu.gmu.css.service.*;
//import org.geojson.FeatureCollection;
//import org.geojson.Feature;
//import org.neo4j.helpers.collection.MapUtil;
//import org.neo4j.ogm.session.Session;
//import org.neo4j.ogm.transaction.Transaction;
//import com.hazelcast.config.Config;
//import com.hazelcast.core.*;
//
//import java.io.File;
//import java.io.FileInputStream;
//import java.io.InputStream;
//import java.time.LocalTime;
//import java.util.*;
//
//
//public class MultiThreadedHexFactory {
//
//    private static Map<Integer, Dataset> geodatasets= DatasetData.GEODATASETS;
//    private static String[] yearString = {"1815", "1880", "1914", "1945", "1994"};
//    private static int[] yearInt = {1815, 1880, 1914, 1945, 1994};
////    private static int[] yearInt = {1815};
//    public static IMap<Long, Tile> globalHexes;
//    private static IMap<String, Territory> territories;
//
//    private static int count = 0;
//    private static int resolution = 4;
//    private static int unclaimedIndex = 0;
//
////    public static HazelcastInstance hci;
//    public static HazelcastInstance hzi;
//
//    public MultiThreadedHexFactory() {
//    }
//
//    private void revisitHexLists() {
//        for (Map.Entry<String, Territory> entry : territories.entrySet()) {
//            String key = entry.getKey();
//            Territory t = (Territory) territories.executeOnKey(key,
//                    new TerritoryHexSetProcessor());
//            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
//            Transaction tx = session.beginTransaction();
//            session.save(t, 2);
//            tx.commit();
//            session.clear();
//        }
//    }
//
//    private void joinHexes() {
//        Map<Long, Tile> missingHexes = new HashMap<>();
//        Iterator it = globalHexes.entrySet().iterator();
//        while (it.hasNext()) {
//            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
//            Transaction tx = session.beginTransaction();
//            Map.Entry pair = (Map.Entry) it.next();
//            Tile tile = (Tile) pair.getValue();
////            Long key = (Long) pair.getKey();
////            String processThread = (String) globalHexes.executeOnKey(key,
////                    new TileJoinEntryProcessor(tile));
//            for (Long h : tile.getNeighborIds()) {
//                if (globalHexes.containsKey(h)) {
//                    tile.addNeighbor(globalHexes.get(h));
//                } else {
//                    Tile newHex = new Tile(h);
//                    missingHexes.put(h, newHex);
//                    tile.addNeighbor(newHex);
//                }
//            }
//            session.save(tile);
//            tx.commit();
////            it.remove(); // avoid a ConcurrentModificationException
//        }
//
//        if (missingHexes.size() != 0) {
//            globalHexes.putAll(missingHexes);
////                joinHexes();
//        }
//
//        System.out.println("There were " + missingHexes.size() + " missing hex Tiles.");
//    }
//
//    private void findTerritoryNeighbors(int year) {
//        String query = "MATCH (t1:Territory{year:{year}})-[:OCCUPATION_OF]->(h1:Tile)-[:ABUTS]-(h2:Tile)<-[:OCCUPATION_OF]-(t2:Territory{year:{year}}) " +
//                "WHERE t1 <> t2 AND t1.year = t2.year " +
//                "MERGE (t1)-[b:BORDERS{during:{year} } ]->(t2) " +
//                "MERGE (t1)-[d:DURING]->(y:Year{name:toString({year})}) " +
//                "MERGE (t2)-[e:DURING]->(y)";
//        Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, MapUtil.map("year", year));
//    }
//
//    public static void main(String args[]) throws Exception {
//
//        LocalTime startTime = LocalTime.now();
//        System.out.println("The simulation began at: " + startTime);
//
////        For testing and debugging locally, we can create a two-node hazelcast cluster within this jvm
//        Config config = new Config();
//        hzi = Hazelcast.newHazelcastInstance(config);
//        HazelcastInstance hzj = Hazelcast.newHazelcastInstance(config);
//
//
////        Config hazelConfig = new Config();
////        hazelConfig.setLiteMember(true);
////        hci = Hazelcast.newHazelcastInstance(hazelConfig);
//
//        globalHexes = hzi.getMap("globalHexes");
//        globalHexes.clear();
//
//        territories = hzi.getMap("territories");
//        territories.clear();
//
//        territories.addEntryListener( new TerritoryEntryListener(hzi), true );
//        System.out.println( "EntryListener registered" );
//
//        LocalTime workTime = LocalTime.now();
//        System.out.println("The real work began at: " + workTime);
//
//        for (Map.Entry<Integer, Dataset> entry : geodatasets.entrySet()) {
//            Dataset d = entry.getValue();
//            // Dynamically get the geojson file associated with the year
//            String filename = "world_" + entry.getKey() + ".geojson";
//            String filepath = "src/main/resources/historicalBasemaps/" + filename;
//            File file = new File(filepath);
//            if (!file.exists() || !filepath.endsWith(".geojson")) {
//                throw new Exception("Well, that didn't work. Was it on the right path?: " + filepath);
//            }
//
//            // Read the file into a geojson-jackson feature collection object
//            FeatureCollection collection = null;
//            try (InputStream inputStream = new FileInputStream(file)) {
//                collection = new ObjectMapper().readValue(inputStream, FeatureCollection.class);
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//
//            String problem = "_empty_string_";
//            int iteration = 0;
//            try {
//                Iterator<Feature> iterator = collection.iterator();
//                while (iterator.hasNext()) {
//                    iteration++;
//                    Feature thisFeature = iterator.next();
//                    String iname = thisFeature.getProperty("NAME");
//
//                    problem = iname;
//
//                    if (iname.equals("Antarctica")) {
//                        iterator.remove();
//                    } else {
//                        String name = iname;
//                        if (name.equals("unclaimed")) {
//                            name = iname + "_" + unclaimedIndex;
//                            unclaimedIndex++;
//                        }
//                        Territory t;
//                        String keyname = name + "_" + entry.getKey();
//                        if (keyname.equals("null")) {System.out.println("...hey, that keyname is null!");}
//                        if (territories.containsKey(keyname)) {
//                            t = territories.get(keyname);
//                            String offloadedThread = (String) territories.executeOnKey(keyname,
//                                    new TerritoryUpdateFeatureProcessor(thisFeature));
//                            System.out.println(offloadedThread);
//                        } else {
//                            String abbr = thisFeature.getProperty("WB_CNTRY");
//                            Double area = thisFeature.getProperty("AREA");
//                            t = new Territory(name, abbr, area, entry.getKey(), resolution);
//                            territories.put(keyname, t);
//                            String offloadedThread = (String) territories.executeOnKey(keyname,
//                                    new TerritoryCreateFeatureProcessor(thisFeature));
//                            System.out.println(offloadedThread);
//                        }
//
//                        d.addFacts(t);
//                        System.out.println(" The globalHexMap has " + globalHexes.size() + " hex Tiles.");
//                    }
//                }
//            } catch (Exception e) {
//                System.out.println("There was a problem with iteration" + iteration + " with " + problem);
//                e.printStackTrace();
//            }
//
//            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
//            Transaction tx = session.beginTransaction();
//            session.save(d, 2);
//            tx.commit();
//            session.clear();
//            System.out.println("Complete " + entry.getKey() + " at " + LocalTime.now());
//        }
//
//        System.out.println("Now, it's " + LocalTime.now() + " and we're about to update territory hexLists with Tiles.");
//        new MultiThreadedHexFactory().revisitHexLists();
//
//        System.out.println("The time is " + LocalTime.now() + " and it's about to lattice them hexes...");
//        new MultiThreadedHexFactory().joinHexes();
//
//        System.out.println("The simulation is ready to find territory neighbors at: " + LocalTime.now());
//        for (int y : yearInt) {
//            new MultiThreadedHexFactory().findTerritoryNeighbors(y);
//        }
//
//        System.out.println("The simulation completed at: " + LocalTime.now());
////        hci.shutdown();
//        hzj.shutdown();
//        hzi.shutdown();
//
//        System.exit(0);
//    }
//
//
//
//}
//
