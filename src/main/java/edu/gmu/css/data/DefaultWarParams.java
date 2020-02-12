package edu.gmu.css.data;


import java.util.HashMap;
import java.util.Map;

public class DefaultWarParams {

    public static Map<String, Double> WAR_PARAMS = new HashMap<>();

    static {
        WAR_PARAMS.put("RED_PUNISH", 0.2);
        WAR_PARAMS.put("RED_COERCE", 0.33);
        WAR_PARAMS.put("RED_DEFEAT", 0.5);
        WAR_PARAMS.put("RED_CONQUER", 1.0);
        WAR_PARAMS.put("BLUE_PUNISH", 0.1);
        WAR_PARAMS.put("BLUE_COERCE", 0.1);
        WAR_PARAMS.put("BLUE_DEFEAT", 0.66);
        WAR_PARAMS.put("BLUE_CONQUER", 1.0);
        WAR_PARAMS.put("THREAT_PUNISH", 0.1);
        WAR_PARAMS.put("THREAT_COERCE", 0.2);
        WAR_PARAMS.put("THREAT_DEFEAT", 0.33);
        WAR_PARAMS.put("THREAT_CONQUER", 0.5);
        WAR_PARAMS.put("RISK_PUNISH", 0.01);
        WAR_PARAMS.put("RISK_COERCE", 0.01);
        WAR_PARAMS.put("RISK_DEFEAT", 0.01);
        WAR_PARAMS.put("RISK_CONQUER", 0.01);
    }

    public Map<String, Double> getWarParams() {
        return WAR_PARAMS;
    }

}
