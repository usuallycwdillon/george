package edu.gmu.css.service;

import edu.gmu.css.agents.CommonWeal;
import edu.gmu.css.entities.Territory;

import java.util.Collections;

public class CommonWealServiceImpl extends GenericService<CommonWeal> implements CommonWealService {

    public final CommonWeal findTerritoryCommonWeal(Territory t) {
        Territory territory = t;
        String q = "MATCH (t:Territory{mapKey:$key})<-[r:REPRESENTS_POPULATION]-(c:CommonWeal) RETURN c";
        CommonWeal cw = session.queryForObject(CommonWeal.class, q, Collections.singletonMap("key", territory.getMapKey()));
        return session.load(CommonWeal.class,cw.getId());
    }

    public CommonWeal loadFromName(String key) {
        String query = "MATCH (c:CommonWeal{name:$name}) RETURN c";
        return session.queryForObject(CommonWeal.class, query, Collections.singletonMap("name", key));
    }


    @Override
    Class<CommonWeal> getEntityType() {
        return CommonWeal.class;
    }
}
