package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;

public enum AllianceType {
    NONAGGRESSION("Type IIa: Non-Aggression"),
    NEUTRALITY("Type II: Neutrality"),
    ENTENTE("Type III: Entente"),
    DEFENSE("Type I: Defense Pact");

    public final String value;

//    AllianceType() {
//    }

    AllianceType(String val) {
        value = val;
    }

    private static final EnumMap<AllianceType, String> _map = new EnumMap<>(AllianceType.class);

    static {
        for (AllianceType aType : AllianceType.values())
            _map.put(aType, aType.value);
    }

    public static String valueOf(AllianceType aType) {
        return _map.get(aType);
    }

    public static AllianceType name(String val) {
        for (Map.Entry<AllianceType, String> entry : _map.entrySet()) {
            if (entry.getValue() == val) {
                return entry.getKey();
            }
        }
        return null;
    }
}
