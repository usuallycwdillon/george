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
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class HexFactory {

    private static Map<Integer, Dataset> geodatasets = DatasetData.GEODATASETS;
    private static int[] yearInt = {1815, 1880, 1914, 1945, 1994};
    //    private static int[] yearInt = {1815};
    private static int resolution = 4;
    private static int unclaimedIndex = 0;

    public static Map<String, Territory> territories = new HashMap<>();
    public static Map<Long, Tile> globalHexes = new HashMap<>();


    public static void main(String args[]) throws Exception {

        Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();

        LocalTime startTime = LocalTime.now();
        System.out.println("The simulation began at: " + startTime);

        for (Map.Entry<Integer, Dataset> entry : geodatasets.entrySet()) {
            Dataset d = entry.getValue();
            int y = entry.getKey();
            new HexFactory().dataset2Hexes(y, d);
        }

        Thread.sleep(10000);
        session.clear();

        System.out.println("The time is " + LocalTime.now() + " and it's about to lattice them hexes...");
        new HexFactory().joinHexes();

        System.out.println("The simulation is ready to find territory neighbors at: " + LocalTime.now());
        for (int y : yearInt) {
            new HexFactory().findTerritoryNeighbors(y);
        }

        System.out.println("The simulation completed at: " + LocalTime.now());

    }


    private void joinHexes() {
        Map<Long, Tile> missingHexes = new HashMap<>();
        Iterator it = globalHexes.entrySet().iterator();
        Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();

        while (it.hasNext()) {
            Transaction tx = session.beginTransaction();
            Map.Entry pair = (Map.Entry) it.next();
            Tile tile = (Tile) pair.getValue();

            for (Long h : tile.getNeighborIds()) {
                if (globalHexes.containsKey(h)) {
                    tile.addNeighbor(globalHexes.get(h));
                } else {
                    Tile newHex = new Tile(h);
                    missingHexes.put(h, newHex);
                    tile.addNeighbor(newHex);
                }
            }

            session.save(tile);
            tx.commit();
        }

        if (missingHexes.size() != 0) {
            globalHexes.putAll(missingHexes);
        }

        session.clear();
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

    private void dataset2Hexes (int year, Dataset dataset) {

        Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();

//        for (Map.Entry<Integer, Dataset> entry : geodatasets.entrySet()) {
            Dataset d = dataset;
            int y = year;
            // Dynamically get the geojson file associated with the year
            String filename = "world_" + y + ".geojson";
            String filepath = "src/main/resources/historicalBasemaps/" + filename;
            File file = new File(filepath);

//            if (!file.exists() || !filepath.endsWith(".geojson")) {
//                throw new Exception("Well, that didn't work. Was it on the right path?: " + filepath);
//            }

            // Read the file into a geojson-jackson feature collection object
            FeatureCollection collection = null;
            try (InputStream inputStream = new FileInputStream(file)) {
                collection = new ObjectMapper().readValue(inputStream, FeatureCollection.class);
            } catch (Exception e) {
                System.out.println("Well, that didn't work. Was it on the right path?: " + filepath);
                e.printStackTrace();
            }

            String problem = "_empty_string_";
            int iteration = 0;
            try {
                Iterator<Feature> iterator = collection.iterator();
                while (iterator.hasNext()) {
                    iteration++;
                    Feature thisFeature = iterator.next();
                    String iname = thisFeature.getProperty("NAME");

                    problem = iname;

                    if (iname.equals("Antarctica")) {
                        iterator.remove();
                    } else {
                        String name = iname;
                        if (name.equals("unclaimed")) {
                            name = iname + "_" + unclaimedIndex;
                            unclaimedIndex++;
                        }
                        Territory t;
                        String keyname = name + "_" + y;
                        if (keyname.equals("null")) {System.out.println("...hey, that keyname is null!");}
                        if (territories.containsKey(keyname)) {
                            t = territories.get(keyname);
                        } else {
                            String abbr = thisFeature.getProperty("WB_CNTRY");
                            Double area = thisFeature.getProperty("AREA");
                            t = new Territory(name, abbr, area, y, resolution, thisFeature);
                            territories.put(keyname, t);
                        }
                        d.addFacts(t);
                        t.getTilesFromAddresses();
                        Transaction tx = session.beginTransaction();
                        session.save(t, 2);
                        tx.commit();
                        System.out.println("Saved " + keyname + " to the database ," + LocalTime.now());
                    }
                    Transaction tx = session.beginTransaction();
                    session.save(d, 2);
                    tx.commit();
                    Thread.sleep(50);
                }

                Thread.sleep(2000);

            } catch (Exception e) {
                System.out.println("There was a problem with iteration ," + iteration + " with ," + problem);
                e.printStackTrace();
            }

            System.out.println("Completed " + y + " at " + LocalTime.now());
//        }
    }

}

