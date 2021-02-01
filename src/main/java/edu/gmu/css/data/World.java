package edu.gmu.css.data;

import javax.lang.model.type.IntersectionType;
import java.util.EnumMap;
import java.util.Map;

public enum World {
    YEAR1816(1816),
    YEAR1880(1880),
    YEAR1914(1914),
    YEAR1938(1938),
    YEAR1945(1945),
    YEAR1994(1994);

    public final Integer value;

    World(int val) {
        value = val;
    }

    private static final EnumMap<World, Integer> _world = new EnumMap<World, Integer>(World.class);

    static {
        for (World w : World.values() )
            _world.put(w, w.value);
    }

    public static Integer valueOf(World w) {
        return _world.get(w);
    }

    public static World name(Integer val) {
        for (Map.Entry<World, Integer> e : _world.entrySet() ) {
            if (e.getValue() == val) {
                return e.getKey();
            }
        }
        return null;
    }

}
