package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;

public enum Domain {
    WAR("War"),
    PEACE("Peace"),
    ALLIANCE("Alliance"),
    TRADE("Trade"),
    DIPLOMACY("Diplomacy"),
    CULTURE("Culture"),
    SOCIETY("Society"),
    STATEHOOD("Statehood"),
    RELIGION("Religion"),
    GEOGRAPHY("Territory"),
    BORDER("Border");

    public final String value;

    Domain(String val) {
        value = val;
    }

    private static final EnumMap<Domain, String> _map = new EnumMap<>(Domain.class);

    // Initialize map with static enum values
    static {
        for (Domain domain : Domain.values())
            _map.put(domain, domain.value);
    }

    public static String valueOf(Domain d) {
        return _map.get(d);
    }

    public static Domain name(String val) {
        for (Map.Entry<Domain, String> entry : _map.entrySet() ) {
            if (entry.getValue() == val) {
                return entry.getKey();
            }
        }
        return null;
    }

}
