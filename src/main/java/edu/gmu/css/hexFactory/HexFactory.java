package edu.gmu.css.hexFactory;


import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.agents.Tile;

import edu.gmu.css.service.Neo4jSessionFactory;
import org.geotools.data.FileDataStore;
import org.geotools.data.FileDataStoreFinder;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.ogm.config.Configuration;
import org.neo4j.ogm.session.SessionFactory;
import org.opengis.feature.simple.SimpleFeature;

import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;

import java.io.*;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;


public class HexFactory {
    /**
     * This factory will add hexes to the database attributable to territories and states via Facts, following a
     * similar pattern as the war/peace data.
     * <p>
     * (Dataset)-[CONTRIBUTES]->(TerritoryFact)<-[OCCUPIES]-(State/Polity)
     * (Year)<-[DURING]-/     \--[OCCUPATION_OF]->(Tile)
     */
    public static Map<String, Tile> globalHexes = new HashMap<>();

    private static boolean debugging = true;
//    private final SessionFactory sessionFactory;

    private static Map<String, Set<String>> hexTerritoryMap = new HashMap<>();
    private static int count = 0;
    private static int resolution = 4;
    private static int unclaimedIndex = 0;
    private static Map<String, Territory> territories = new HashMap<>();
    private static String[] yearString = {"1815", "1880", "1914", "1945", "1994"};
    private static int[] yearInt = {1815, 1880, 1914, 1945, 1994};
//    private static int[] yearInt = {1994};


    public HexFactory() {

    }

    private void makeTerritories(SimpleFeatureCollection collection, int year) {

        String filename = "cntry" + year + ".shp";
//        Dataset dataset =  Neo4jSessionFactory.getInstance().getNeo4jSession()
//                .queryForObject(Dataset.class, "MATCH (ds:Dataset{filename:{filename}}) RETURN ds",
//                        MapUtil.map("filename", filename));

        try (SimpleFeatureIterator iterator = collection.features()) {
            while (iterator.hasNext()) {
                SimpleFeature thisFeature = iterator.next();
                String iname = thisFeature.getAttribute("NAME").toString();

                if (iname.equals("Antarctica")) {
                    iterator.next();
                } else {
                    String name = iname;
                    if (name.equals("unclaimed")) {
                        name = iname + " " + unclaimedIndex;
                        unclaimedIndex += 1;
                    }
                    Territory t;
                    String keyname = name + " of " + year;
                    if (territories.containsKey(keyname)) {
                        System.out.println("... and we seem to have a key match in the territories map");
                        t = territories.get(keyname);
                        t.updateOccupation(thisFeature);
                    } else {
                        t = new Territory(thisFeature, name, resolution, year);
                        territories.put(keyname, t);
                    }

                    Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
                    Transaction tx = session.beginTransaction();

//                    dataset.addFacts(t);

                    session.save(t);
//                    session.save(dataset);
                    tx.commit();
                    session.clear();
                }
            }
        }
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


    public static void main(String[] args) throws Exception {

//        for (int y : yearInt) {
//            String filepath = "src/main/data/shapefiles/" + y + "/" + "cntry" + y + ".shp";
//            File file = new File(filepath);
//            if (!file.exists() || !filepath.endsWith(".shp")) {
//                throw new Exception("Well, that didn't work. Was it a shapefile?: " + filepath);
//            }
//
//            FileDataStore store = FileDataStoreFinder.getDataStore(file);
//            SimpleFeatureSource featureSource = store.getFeatureSource();
//            SimpleFeatureCollection collection = featureSource.getFeatures();
//
//            new HexFactory().makeTerritories(collection, y);
//            System.out.println("Territories and their hex Tiles have been made for " + y);
//        }

        Collection<Tile> tileCollection = Neo4jSessionFactory.getInstance().getNeo4jSession().loadAll(Tile.class);

        globalHexes.putAll(tileCollection.stream().collect(Collectors.toMap(Tile::getAddress,
                        Function.identity())));

        System.out.println("About to lattice them hexes...");
        new HexFactory().joinHexes();

        for (int y : yearInt) {
            new HexFactory().findTerritoryNeighbors(y);
        }

        System.exit(0);

    }

}

