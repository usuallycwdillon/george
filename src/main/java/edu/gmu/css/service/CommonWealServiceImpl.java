package edu.gmu.css.service;

import edu.gmu.css.entities.CommonWeal;
import edu.gmu.css.entities.Territory;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class CommonWealServiceImpl extends GenericService<CommonWeal> implements CommonWealService {

    public CommonWeal findTerritoryCommonWeal(Territory t) {
        Territory territory = t;
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", territory.getMapKey());
        String q = "MATCH (t:Territory{mapKey:{key}})<-[r:REPRESENTS_POPULATION]-(c:CommonWeal) RETURN t, r, c";
        CommonWeal c = session.queryForObject(CommonWeal.class, q, Collections.singletonMap("key", territory.getMapKey()));
        return c;
    }


    @Override
    Class<CommonWeal> getEntityType() {
        return CommonWeal.class;
    }
}
