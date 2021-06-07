package edu.gmu.css.service;

import edu.gmu.css.entities.CommonWeal;
import edu.gmu.css.entities.Territory;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class CommonWealServiceImpl extends GenericService<CommonWeal> implements CommonWealService {

    public final CommonWeal findTerritoryCommonWeal(Territory t) {
        Territory territory = t;
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", territory.getMapKey());
        String q = "MATCH (t:Territory{mapKey:{key}})<-[r:REPRESENTS_POPULATION]-(c:CommonWeal) RETURN t, r, c";
        CommonWeal c = session.queryForObject(CommonWeal.class, q, Collections.singletonMap("key", territory.getMapKey()));
        return c;
    }

    public CommonWeal loadCommonWeal(String key) {
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", key);
        params.put("name", "Residents of " + key);
        String query = "MATCH (:Territory{mapKey:$mapKey})-[:REPRESENTS_POPULATION]-(c:CommonWeal{name:$name}) RETURN c";
        CommonWeal c = session.queryForObject(CommonWeal.class, query, params);
        return c;
    }


    @Override
    Class<CommonWeal> getEntityType() {
        return CommonWeal.class;
    }
}
