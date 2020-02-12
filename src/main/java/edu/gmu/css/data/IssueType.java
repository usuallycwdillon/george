package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;

public enum IssueType {
    ALLIANCE("Alliance Endurance"),
    PEACE("Stability of Peace"),
    TERRITORY("Territorial Claim"),
    POLICY("Policy Difference"),
    REGIME("Regime or Governance"),
    TRADE("Trade Dispute");

    public final String value;

    IssueType(String v) {
        value = v;
    }

    private static final EnumMap<IssueType, String> _map = new EnumMap<>(IssueType.class);

    static {
        for (IssueType it : IssueType.values()) {
            _map.put(it, it.value);
        }
    }

    public static String valueOf(IssueType it) {
        return _map.get(it);
    }

    public static IssueType name(String v) {
        for (Map.Entry<IssueType, String> e : _map.entrySet()) {
            if (e.getValue() == v) {
                return e.getKey();
            }
        }
        return null;
    }

}
