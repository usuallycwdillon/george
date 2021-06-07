package edu.gmu.css.service;

import edu.gmu.css.agents.Leadership;
import edu.gmu.css.entities.CommonWeal;

import java.util.HashMap;
import java.util.Map;

public class LeadershipServiceImpl extends GenericService<Leadership> implements LeadershipService {

    public final Leadership getCommonWealLeadership(CommonWeal cw) {
        Map<String, Object> params = new HashMap<>();
        params.put("name", cw.getName());
        String q = "MATCH (cw:CommonWeal{name:$name})<-[:LEADERSHIP_FROM]-(l:Leadership) RETURN l";
        Leadership l = session.queryForObject(Leadership.class, q,params);
        if(l != null) {
            cw.setLeadership(l);
            l.setCommonWeal(cw);
            return l;
        } else {
            return null;
        }
    }

//    @Override
//    public Leadership load(Long id) {
//        return session.load(Leadership.class, id);
//    }

    @Override
    Class<Leadership> getEntityType() {
        return Leadership.class;
    }
}
