package edu.gmu.css.data;

import edu.gmu.css.entities.Dataset;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class GeoDatasetData {

    public static Map<Integer, Dataset> GEODATASETS;


    static Dataset map1816 = new Dataset(
            "cowWorld_1816.geojson",
            "world 1816",
            0.9);

    static Dataset map1880 = new Dataset(
            "cowWorld_1880.geojson",
            "world 1880",
            0.9);

    static Dataset map1914 = new Dataset(
            "cowWorld_1914.geojson",
            "world 1914",
            0.9);

    static Dataset map1938 = new Dataset(
            "cowWorld_1938.geojson",
            "world 1938",
            0.9);

    static Dataset map1945 = new Dataset(
            "cowWorld_1945.geojson",
            "world 1945",
            0.9);

    static Dataset map1994 = new Dataset(
            "cowWorld_1994.geojson",
            "world 1994",
            0.9);

    static {
        Map<Integer, Dataset> mapdata = new HashMap<>();
        mapdata.put(1816, map1816);
//        mapdata.put(1880, map1880);
//        mapdata.put(1914, map1914);
//        mapdata.put(1938, map1938);
//        mapdata.put(1945, map1945);
//        mapdata.put(1994, map1994);
        GEODATASETS = Collections.unmodifiableMap(mapdata);
    }

}
