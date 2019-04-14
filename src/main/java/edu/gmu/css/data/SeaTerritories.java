package edu.gmu.css.data;

import edu.gmu.css.entities.Territory;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class SeaTerritories {

    public static Map<String, Territory> SEAS;

    static Territory seas1816 = new Territory("Seas", 1816);

    static Territory seas1880 = new Territory("Seas", 1880);

    static Territory seas1914 = new Territory("Seas", 1914);

    static Territory seas1938 = new Territory("Seas", 1938);

    static Territory seas1945 = new Territory("Seas", 1945);

    static Territory seas1994 = new Territory("Seas", 1994);

    static {
        Map<String, Territory> seaNodes = new HashMap<>();
        seaNodes.put(seas1816.getMapKey(), seas1816);
        seaNodes.put(seas1880.getMapKey(), seas1880);
        seaNodes.put(seas1914.getMapKey(), seas1914);
        seaNodes.put(seas1938.getMapKey(), seas1938);
        seaNodes.put(seas1945.getMapKey(), seas1945);
        seaNodes.put(seas1994.getMapKey(), seas1994);
        SEAS = Collections.unmodifiableMap(seaNodes);
    }

}
