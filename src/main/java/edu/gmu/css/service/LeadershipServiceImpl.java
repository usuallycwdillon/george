package edu.gmu.css.service;

import edu.gmu.css.agents.Leadership;
import edu.gmu.css.agents.CommonWeal;

import java.util.Collections;

public class LeadershipServiceImpl extends GenericService<Leadership> implements LeadershipService {

    public Leadership getCommonWealLeadership(CommonWeal cw) {
        String q = "MATCH (l:Leadership{leaderOf:$name}) RETURN l";
        Leadership l = session.queryForObject(Leadership.class, q, Collections.singletonMap("name", cw.getName()));
        return l;
    }

    @Override
    Class<Leadership> getEntityType() {
        return Leadership.class;
    }
}
