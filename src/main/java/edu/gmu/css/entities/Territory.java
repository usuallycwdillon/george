package edu.gmu.css.entities;

import com.uber.h3core.H3Core;

import com.uber.h3core.util.GeoCoord;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.hexFactory.*;

import edu.gmu.css.service.NameIdStrategy;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.Feature;
import org.geojson.Geometry;
import org.geojson.LngLatAlt;
import org.geojson.MultiPolygon;
import org.jetbrains.annotations.NotNull;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;
import sim.engine.SimState;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.*;

@NodeEntity
public class Territory extends Entity implements Serializable {

    Map<Long, Tile> globalHexes = HexFactory.globalHexes;

    @Id @GeneratedValue (strategy = NameIdStrategy.class)
    String mapKey;
    //    Long id;
    String name;
    String cowcode;
    Long creationDate;
    String abbr;
    Double area = 0.0;
    int year;
    int resolution;

    List<Long> hexList;

    @Relationship(type="OCCUPATION_OF")
    Set<Tile> hexSet;

    @Relationship(type="BORDERS")
    Set<Territory> neighbors;


    public Territory() {
        this.resolution = 4;
        this.creationDate = 0L;
        this.name = "Unnamed";
        this.area = 0.0;
        this.hexSet = new HashSet<>();
        this.hexList = new ArrayList<>();
    }

    public Territory(String name, String abbr, Double area, int year, int resolution) {
        this();
        this.year = year;
        this.creationDate = (year - 1815) * 52L;
        this.hexSet = new HashSet<>();
        this.name = name;
        this.abbr = abbr;
        this.resolution = resolution;
        if (area != null) {this.area = area;} else {this.area = 0.0;}
    }

    public Territory(String name, String abbr, Double area, int year, int resolution, Feature feature) {
        this();
        this.year = year;
        this.creationDate = (year - 1815) * 52L;
        this.hexSet = new HashSet<>();
        this.name = name;
        this.abbr = abbr;
        this.resolution = resolution;
        this.mapKey = name + " of " + year;
        if (area != null) {this.area = area;} else {this.area = 0.0;}
        buildTerritory(feature);
    }

    public Territory(Feature input, int year) {
        this();
        this.name = input.getProperty("NAME");
        this.abbr = input.getProperty("WB_CNTRY");
        this.year = year;
        this.mapKey = name + " of " + year;
        if (input.getProperty("CCODE") != null) {this.cowcode = "" + input.getProperty("CCODE");} else {this.cowcode = "";}
        if (input.getProperty("AREA") != null) {this.area = input.getProperty("AREA");} else {this.area = 0.0;}
        buildTerritory(input);
    }


    public Territory(SimState simState) {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public int getResolution() {
        return resolution;
    }

    public void setResolution(int resolution) {
        this.resolution = resolution;
    }

    public String getMapKey() {
        return mapKey;
    }

    public Set<Tile> getHexSet() {
        return hexSet;
    }

    public List<Long> getHexList() { return hexList; }

    public void addHex(Tile hex) {this.hexSet.add(hex);}

    public Set<Territory> getNeighbors() {
        return neighbors;
    }

    public void buildTerritory(Feature inputFeature) {
        getTileIdsFromPolygons(inputFeature);
        hexSet.addAll(getTilesFromAddresses());
    }

    public void updateOccupation(Feature inputFeature) {
        if (inputFeature.getProperty("AREA") != null) {
            this.area = this.area + (Double) inputFeature.getProperty("AREA");
        }
        getTileIdsFromPolygons(inputFeature);
        hexSet.addAll(getTilesFromAddresses());
    }

    private void getTileIdsFromPolygons(@NotNull Feature inputFeature) {
        // All territory elements are multipolygons, even if there is only one polygon in the array
        MultiPolygon geom = (MultiPolygon) inputFeature.getGeometry();
        int numPolygons = geom.getCoordinates().size();

        for (int i = 0; i < numPolygons; i++) {
            List<List<GeoCoord>> holes = new ArrayList<>();

            int numInnerLists = geom.getCoordinates().get(i).size();

            List<LngLatAlt> coordinates = geom.getCoordinates().get(i).get(0);
            List<GeoCoord> boundaryCoordinates = swapCoordinateOrdering(coordinates);

            if (numInnerLists > 1) {        // second thru last elements are holes in the outer polygon
                for (int il=1; il<numInnerLists; il++) {
                    List<GeoCoord> hole = swapCoordinateOrdering(geom.getCoordinates().get(i).get(il));
                    holes.add(hole);
                }
            }

            try {
                H3Core h3 = H3Core.newInstance();
                if (area == null) {
                    System.out.println("The area is null");
                }
                if (name == null) {
                    System.out.println("The name is null");
                }
                if (area < 40000.0 && !name.equals("Russian Empire of " + year)) {
                    hexList = new ArrayList<>(h3.polyfill(boundaryCoordinates, holes, resolution));
                } else {
                    int res = resolution - 1;
                    List<Long> bigList = new ArrayList<>(h3.polyfill(boundaryCoordinates, holes, res));
                    if (bigList.size() < 1) {
                        hexList = new ArrayList<>(h3.polyfill(boundaryCoordinates, holes, resolution));
                    }
                    for (Long s : bigList) {
                        hexList.addAll(h3.h3ToChildren(s, resolution));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private List<GeoCoord> swapCoordinateOrdering(@NotNull List<LngLatAlt> coordinates) {
        List<GeoCoord> h3Coords = new ArrayList<>();
        for (LngLatAlt c : coordinates) {
            GeoCoord gc = new GeoCoord(c.getLatitude(), c.getLongitude());
            h3Coords.add(gc);
        }
        return h3Coords;
    }

    public Set<Tile> getTilesFromAddresses() {
        Set<Tile> tiles = new HashSet<>();
        for (Long h : hexList) {
            if (globalHexes.containsKey(h)) {
                Tile t = globalHexes.get(h);
                tiles.add(t);
            } else  {
                Tile t = new Tile(h);
                globalHexes.put(h, t);
                tiles.add(t);
            }
        }
        return tiles;
    }

}
