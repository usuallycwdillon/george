package edu.gmu.css.queries;

import edu.gmu.css.entities.State;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.neo4j.ogm.model.Result;

import java.util.*;

public class StateQueries {

    public Set<State> getStates(String system, int period) {
        Set<State> states = new HashSet<>();

        Map<String, Object> params = new HashMap<>();
        params.put("name", system); // system name
        params.put("from", period);

        String query = "MATCH (s:State)-[:MEMBER]-(f:Fact)-[:MEMBER_OF]-(y:System{name:$name}) " +
                "WHERE f.from.year <= $from RETURN s";
        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, params);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            Map<String, Map.Entry<String, Object>> values = (Map) it.next();
            for (Map.Entry e : values.entrySet()) {
                State s = (State) e.getValue();
                states.add(s);
            }
        }
        return states;
    }


    public enum SourcePeriod {
        COW,
        MAJ,
        GEX,
        GPW
    }

}
