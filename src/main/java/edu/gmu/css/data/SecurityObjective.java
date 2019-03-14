package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;
import java.util.Objects;

public enum SecurityObjective {
    PUNISH(0),
    COERCE(2),
    DEFEAT(4),
    CONQUER(6),
    RESIST(1),
    RETALIATE(3),
    DEFEND(5),
    RECONQUER(7);

    public final int value;

    SecurityObjective(int val) {
        value = val;
    }

    private static final EnumMap<SecurityObjective, Integer> _map = new EnumMap<>(SecurityObjective.class);

    // Initialize this map with enum values
    static {
        for (SecurityObjective objective : SecurityObjective.values())
            _map.put(objective, objective.value);
    }

    public static int valueOf(SecurityObjective objective) {
        return _map.get(objective);
    }

    public static SecurityObjective name(int val) {
        for (Map.Entry<SecurityObjective, Integer> entry : _map.entrySet()) {
            if (entry.getValue() == val) {
                return entry.getKey();
            }
        }
        return null;
    }

}