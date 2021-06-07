package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;

public enum WorldMap {
    YEAR1816(1816),
    YEAR1880(1880),
    YEAR1914(1914),
    YEAR1938(1938),
    YEAR1945(1945),
    YEAR1994(1994);

    public final Integer value;

    WorldMap(int val) {
        value = val;
    }

    private static final EnumMap<WorldMap, Integer> _world = new EnumMap<WorldMap, Integer>(WorldMap.class);

    static {
        for (WorldMap w : WorldMap.values() )
            _world.put(w, w.value);
    }

    public static Integer valueOf(WorldMap w) {
        return _world.get(w);
    }

    public static WorldMap name(Integer val) {
        for (Map.Entry<WorldMap, Integer> e : _world.entrySet() ) {
            if (e.getValue() == val) {
                return e.getKey();
            }
        }
        return null;
    }

}
