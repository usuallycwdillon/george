package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;

public enum IssueType {
    ALLIANCE_PRO("Desire alliance with target"),
    ALLIANCE_ANTI("Dispute over target's alliance"),
    PEACE("Desire peace with target"),
    TERRITORY_PRO("Agree to current territory boundaries"),
    TERRITORY_ANTI("Dispute target's territorial claim"),
    POLICY_PRO("Desire to new policy"),
    POLICY_ANTI("Dispute over target's policy"),
    REGIME("Dispute over target's regime"),
    TRADE_PRO("Desire for new trade"),
    TRADE_ANTI("Trade Dispute");

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
