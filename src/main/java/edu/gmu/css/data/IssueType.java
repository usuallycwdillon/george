package edu.gmu.css.data;

import java.util.EnumMap;
import java.util.Map;

public enum IssueType {
    ALLIANCE_PRO("Desire for alliance with "),
    ALLIANCE_ANTI("Dispute over another state's alliance with "),
    PEACE("Desire peace with "),
    TERRITORY_PRO("Agree to territorial boundary with "),
    TERRITORY_ANTI("Dispute territorial claim of "),
    POLICY_PRO("Desire for new policy regarding "),
    POLICY_ANTI("Dispute over some policy of "),
    REGIME("Dispute over regime of "),
    TRADE_PRO("Desire new trade with "),
    TRADE_ANTI("Trade Dispute with ");

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
