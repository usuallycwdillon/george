package edu.gmu.css.data;


import java.util.HashMap;
import java.util.Map;

public class DefaultWarParams {

    public static Map<String, Double> WAR_PARAMS = new HashMap<>();

    static {
        WAR_PARAMS.put("RED_PUNISH", 2.69897);
        WAR_PARAMS.put("RED_COERCE", 3.69897);
        WAR_PARAMS.put("RED_DEFEAT", 4.69897);
        WAR_PARAMS.put("RED_CONQUER", 5.69897);
        WAR_PARAMS.put("BLUE_PUNISH", 0.028125);
        WAR_PARAMS.put("BLUE_COERCE", 0.05625);
        WAR_PARAMS.put("BLUE_DEFEAT", 0.1125);
        WAR_PARAMS.put("BLUE_CONQUER", 0.225);
        WAR_PARAMS.put("THREAT_PUNISH", 2.69897);
        WAR_PARAMS.put("THREAT_COERCE", 3.69897);
        WAR_PARAMS.put("THREAT_DEFEAT",  4.69897);
        WAR_PARAMS.put("THREAT_CONQUER", 5.69897);
        WAR_PARAMS.put("RISK_PUNISH", 0.028125);
        WAR_PARAMS.put("RISK_COERCE", 0.05625);
        WAR_PARAMS.put("RISK_DEFEAT", 0.1125);
        WAR_PARAMS.put("RISK_CONQUER", 0.225);
        WAR_PARAMS.put("MARCHING_PACE", 6.0);
        WAR_PARAMS.put("WAR_NEED_MIN", 0.10);
        WAR_PARAMS.put("WAR_WILLING_MIN", -0.10);
    }

    public Map<String, Double> getWarParams() {
        return WAR_PARAMS;
    }

}
