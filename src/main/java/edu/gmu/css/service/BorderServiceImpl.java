package edu.gmu.css.service;

import edu.gmu.css.entities.Border;
import edu.gmu.css.entities.Territory;

import java.util.HashMap;
import java.util.Map;

public class BorderServiceImpl extends GenericService<Border> implements BorderService {

    public Border borderBetweenTerritories(Territory f, Territory t) {
        String source = f.getMapKey();
        String target = t.getMapKey();
        Map<String, String> params = new HashMap<>();
        params.put("source", source);
        params.put("target", target);
        String q = "MATCH (:Territory{mapKey:$source})-[:BORDERS]->(b:Border)<-[:BORDERS]-(:Territory{mapKey:$target}) RETURN b";
        return session.queryForObject(Border.class, q, params);
    }

    @Override
    Class<Border> getEntityType() {
        return Border.class;
    }
}
