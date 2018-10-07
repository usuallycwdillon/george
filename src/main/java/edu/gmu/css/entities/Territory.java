package edu.gmu.css.entities;

import com.uber.h3core.H3Core;

import com.uber.h3core.util.GeoCoord;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.hexFactory.*;

import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.Feature;
import org.geojson.Geometry;
import org.geojson.LngLatAlt;
import org.geojson.MultiPolygon;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.*;

@NodeEntity
public class Territory extends Entity implements Serializable{

    @Id @GeneratedValue
    Long id;
    long creationDate;
    String name;
    String abbr;
    Double area;
    int year;
    int resolution;

    public static Map<String, Tile> globalHexes = MultiThreadedHexFactory.hzi.getMap("globalHexes");

    @Relationship(type="OCCUPATION_OF")
    Set<Tile> hexSet;

    @Relationship(type="BORDERS")
    Set<Territory> neighbors;


    public Territory() {
        this.creationDate = 0L;
        this.hexSet = new HashSet<>();
    }

    public Territory(String name, String abbr, Double area, long stepNo) {
        this();
        this.name = name;
        this.abbr = abbr;
        this.area = area;
        this.creationDate = stepNo;
    }


    public void updateOccupation(Feature inputFeature) {
        this.area += inputFeature.getProperty("AREA");
        getTilesFromPolygons(inputFeature);
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

    public void buildTerritory(Feature inputFeature, String name, int resolution, int year) {
        this.year = year;
        this.resolution = resolution;
        this.name = name + " of " + year;
        this.abbr = inputFeature.getProperty("WB_CNTRY");
        this.area = inputFeature.getProperty("AREA");
        getTilesFromPolygons(inputFeature);
    }

    private void getTilesFromPolygons(Feature inputFeature) {
        MultiPolygon geom = (MultiPolygon) inputFeature.getGeometry();
        int numGeometries = geom.getCoordinates().size();

        System.out.println("Creating territory " + name);

        for (int i = 0; i < numGeometries; i++) {
            int numInnerLists = geom.getCoordinates().get(i).size();
            if (numInnerLists > 1) {
                System.out.println(name + " has more than one inner geometry list!");
            }

            List<LngLatAlt> coordinates = geom.getCoordinates().get(i).get(0);
            List<GeoCoord> boundaryCoordinates = new ArrayList<>();
            for (LngLatAlt c : coordinates) {
                GeoCoord gc = new GeoCoord(c.getLatitude(), c.getLongitude());
                boundaryCoordinates.add(gc);
            }

            List<String> hexList = new ArrayList<>();
            List<List<GeoCoord>> holes = new ArrayList<>();

            try {
                H3Core h3 = H3Core.newInstance();
                if (area < 40000.0 && !name.equals("Russian Empire")) {
                    hexList = new ArrayList<>(h3.polyfillAddress(boundaryCoordinates, holes, resolution));
                } else {
                    int res = resolution - 1;
                    List<String> bigList = new ArrayList<>(h3.polyfillAddress(boundaryCoordinates, holes, res));
                    for (String s : bigList) {
                        hexList.addAll(h3.h3ToChildren(s, resolution));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

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


    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("Tile{");
        sb.append("id=").append(id);
        sb.append("creationDate=").append(creationDate);
        sb.append("name=").append(name);
        sb.append("abbr=").append(abbr);
        sb.append("area=").append(area);
        sb.append("year=").append(year);
        sb.append("resolution=").append(resolution);
        return sb.toString();
    }
}
