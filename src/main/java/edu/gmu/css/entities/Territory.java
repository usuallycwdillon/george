package edu.gmu.css.entities;

import com.uber.h3core.H3Core;

import com.uber.h3core.util.GeoCoord;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.hexFactory.*;

import edu.gmu.css.service.Neo4jSessionFactory;
import org.geotools.data.DefaultTransaction;
import org.geotools.data.collection.ListFeatureCollection;
import org.geotools.data.shapefile.ShapefileDataStore;
import org.geotools.data.shapefile.ShapefileDataStoreFactory;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureStore;
import org.geotools.feature.DefaultFeatureCollection;
import org.geotools.feature.simple.SimpleFeatureBuilder;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.geotools.geometry.jts.JTSFactoryFinder;
import org.geotools.referencing.crs.DefaultGeographicCRS;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;
import org.locationtech.jts.geom.*;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.*;

@NodeEntity
public class Territory extends Entity {

    @Id @GeneratedValue
    Long id;
    long creationDate;
    String name;
    String abbr;
    Double area;
    int year;
    String yearString;
    int resolution;
    public static Map<String, Tile> globalHexes = HexFactory.globalHexes;
    public H3Core h3;

    @Relationship(type="OCCUPATION_OF")
    Set<Tile> hexSet;

    @Relationship(type="BORDERS")
    Set<Territory> neighbors;


    public Territory() {
        try {
            this.h3 = H3Core.newInstance();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public Territory(String name, String abbr, Double area, long stepNo) {
        this();
        this.name = name;
        this.abbr = abbr;
        this.area = area;
        this.creationDate = stepNo;
    }

    public Territory(SimpleFeature inputFeature, String name, int resolution, int year) {
        this();
        this.hexSet = new HashSet<>();
        this.creationDate = 0L;
        this.year = year;
        this.resolution = resolution;
        this.name = name + " of " + year;
        this.abbr = inputFeature.getAttribute("WB_CNTRY").toString();
        this.area = (Double) inputFeature.getAttribute("AREA");

        MultiPolygon geom = (MultiPolygon) inputFeature.getDefaultGeometry();
        int numGeometries = geom.getNumGeometries();

        System.out.println("Creating territory " + name);

        for (int i = 0; i < numGeometries; i++) {
            Geometry bounds = geom.getGeometryN(i);
            Coordinate[] coordinates = bounds.getCoordinates();
            ArrayList<GeoCoord> boundaryCoordinates = new ArrayList<>();

            for (Coordinate c : coordinates) {
                // Important! Note the order of the coordinates: long, lat
                GeoCoord gc = new GeoCoord(c.getOrdinate(1), c.getOrdinate(0));
                boundaryCoordinates.add(gc);
            }

            List<String> hexList = new ArrayList<>();
            hexList.addAll(createHexList(boundaryCoordinates, area, name, this.resolution, h3));

            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
            Transaction tx = session.beginTransaction();
            for (String h : hexList) {
                if (!globalHexes.containsKey(h)) {
                    Tile hex = new Tile(h);
//                    System.out.println(" created hex " + h);
                    this.addHexes(hex);
                    globalHexes.put(h, hex);
                    session.save(hex);
                } else {
                    Tile hex = globalHexes.get(h);
                    this.addHexes(hex);
                    session.save(hex);
                }
            }
            tx.commit();
            session.clear();
            System.out.println("Committed a geometry's worth of hexes to " + name);
        }
        System.out.println("Committed the complete territory " + name);
    }

    public void updateOccupation(SimpleFeature inputFeature) {
        this.area += (Double) inputFeature.getAttribute("AREA");

        MultiPolygon geom = (MultiPolygon) inputFeature.getDefaultGeometry();
        int numGeometries = geom.getNumGeometries();

        System.out.println("Updated territory " + this.name);

        for (int i = 0; i < numGeometries; i++) {
            Geometry bounds = geom.getGeometryN(i);
            Coordinate[] coordinates = bounds.getCoordinates();
            ArrayList<GeoCoord> boundaryCoordinates = new ArrayList<>();

            for (Coordinate c : coordinates) {
                // Important! Note the order of the coordinates: long, lat
                GeoCoord gc = new GeoCoord(c.getOrdinate(1), c.getOrdinate(0));
                boundaryCoordinates.add(gc);
            }

            List<String> hexList = new ArrayList<>();
            hexList.addAll(createHexList(boundaryCoordinates, this.area, this.name, this.resolution, h3));

            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
            Transaction tx = session.beginTransaction();
            for (String h : hexList) {
                if (!globalHexes.containsKey(h)) {
                    Tile hex = new Tile(h);
                    System.out.println(" created hex " + h);
                    this.addHexes(hex);
                    globalHexes.put(h, hex);
                    session.save(hex);
                } else {
                    Tile hex = globalHexes.get(h);
                    this.addHexes(hex);
                    session.save(hex);
                }
            }
            tx.commit();
            System.out.println("Committed updated territory " + this.name);
        }
    }

    public Long getId() {
        return this.id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Set<Tile> getHexSet() {
        return hexSet;
    }

    public void addHexes(Tile hex) {this.hexSet.add(hex);}

    public Set<Territory> getNeighbors() {
        return neighbors;
    }

    private static List createHexList(ArrayList<GeoCoord> coords, double area, String name, int resolution, H3Core h3) {
        /**
         * The getHexList method returns all the H3 hexagons whose centers are inside the coordinate boundary.
         * Very large areas (Russian Empire) are calculated at lower resolution then the 7 subordinate hexes within
         * that low-res set get returned. This seems to be required because of an incompatibility between the way H3 and
         * Java interact.
         */
        List<List<GeoCoord>> holes = new ArrayList<>();
        int res = resolution;
        List<String> hexList = new ArrayList<>();

        if (area < 40000.0 && !name.equals("Russian Empire")) {
            hexList = new ArrayList<>(h3.polyfillAddress(coords, holes, res ));
        } else {
            res = resolution - 1;
            List<String> bigList = new ArrayList<>(h3.polyfillAddress(coords, holes, res));
            for (String s: bigList) {
                hexList.addAll(h3.h3ToChildren(s, resolution));
            }
        }
        return hexList;
    }

    private static void saveShapefile(String name, String abb, Set<String> hexes, int year, H3Core h3) throws IOException {
        /**
          Takes a country name, it's abbreviation and a set of hexagons that will represent it and writes out a shapefile

         */
        String filename = "src/main/data/hexMaps/politicalBoundaryHexes_" + year + "_" + name + ".shp";
        File file = new File(filename);

        List<SimpleFeature> features = new ArrayList<>();
        GeometryFactory gf = JTSFactoryFinder.getGeometryFactory();

        DefaultFeatureCollection output = new DefaultFeatureCollection();

        final SimpleFeatureType HEX = createFeatureType();
        SimpleFeatureBuilder featureBuilder = new SimpleFeatureBuilder(HEX);

        ShapefileDataStoreFactory dataStoreFactory = new ShapefileDataStoreFactory();
        Map<String, Serializable> params = new HashMap<>();
        params.put("url", file.toURI().toURL());
        params.put("create spatial index", Boolean.TRUE);

        ShapefileDataStore dataStore = (ShapefileDataStore) dataStoreFactory.createNewDataStore(params);
        dataStore.createSchema(HEX);

        int index = 0;
        for (String h:hexes) {
            List<GeoCoord> geocoords = h3.h3ToGeoBoundary(h);
            int numVerts = geocoords.size();
            Coordinate[] coordinates = new Coordinate[numVerts + 1];
            for (int i=0; i<geocoords.size(); i++){
                coordinates[i] = new Coordinate(geocoords.get(i).lng, geocoords.get(i).lat);
            }
            coordinates[numVerts] = new Coordinate(geocoords.get(0).lng, geocoords.get(0).lat);
            Polygon polygon = gf.createPolygon(coordinates);
            Object[] values = new Object[]{polygon, index, h};
            index++;
            featureBuilder.addAll(values);

            SimpleFeature polyFeature = featureBuilder.buildFeature(h);
            features.add(polyFeature);
        }

        org.geotools.data.Transaction transaction = new DefaultTransaction("create");
        String typeName = dataStore.getTypeNames()[0];
        SimpleFeatureSource featureSource = dataStore.getFeatureSource(typeName);

        if (featureSource instanceof SimpleFeatureStore) {
            SimpleFeatureStore featureStore = (SimpleFeatureStore) featureSource;
            SimpleFeatureCollection collection = new ListFeatureCollection(HEX, features);
            featureStore.setTransaction(transaction);
            try {
                featureStore.addFeatures(collection);
                transaction.commit();
            } catch (Exception e) {
                e.printStackTrace();
                transaction.rollback();
            } finally {
                transaction.close();
            }
        } else {
            System.out.println("Writing the Shapefile failed.");
            System.exit(1); // Failure!
        }
    }

    private static SimpleFeatureType createFeatureType() {
        SimpleFeatureTypeBuilder builder = new SimpleFeatureTypeBuilder();
        builder.setName("polygon");
        builder.setCRS(DefaultGeographicCRS.WGS84);
        builder.add("the_geom", Polygon.class);
        builder.add("id", Long.class);
        builder.add("address", String.class);
        final SimpleFeatureType TYPE = builder.buildFeatureType();
        return TYPE;
    }

    public static void saveGeoJson(String name, List<Long> hexes, H3Core h3) {
        List<List<List<GeoCoord>>> polygons = h3.h3SetToMultiPolygon(hexes, true);
        System.out.println(polygons.toString());
    }


}
