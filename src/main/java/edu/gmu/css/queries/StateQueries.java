package edu.gmu.css.queries;

import edu.gmu.css.entities.*;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.model.Result;

import java.util.*;

public class StateQueries {

    public List<State> getStates(String system, int period) {
        List<State> states = new ArrayList<>();

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

    public static Resources getMilResources(Polity polity, int year) {
        Long id = polity.getId();
        int pax = 0;
        int exp = 0;
        String name = year + "";
        // MilPer
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("name", name);
        String paxQuery = "MATCH (p:Polity)-[:MILPER]-(m:MilPerFact)-[:DURING]-(y:Year{name:$name}) " +
                "WHERE id(p) = $id RETURN m";
        String exQuery = "MATCH (p:Polity)-[:MILEX]-(m:MilExFact)-[:DURING]-(y:Year{name:$name}) " +
                "WHERE id(p) = $id RETURN m";

        Fact milperfact = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, paxQuery, params);
        if (milperfact != null) {
            Long num = ((Long) milperfact.getValue()) * 1000;
            pax = num != null ? num.intValue() : null;
        }
        Fact milexfact = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, exQuery, params);
        if (milexfact != null) {
            Long amt = ((Long) milexfact.getValue()) * 1000;
            exp = amt != null ? amt.intValue() : null;
        }
        return new Resources.ResourceBuilder().pax(pax).treasury(exp).build();
    }


    public static Territory getTerritoryFromDatabase(State s) {
        String cowCode = s.getCowCode();
        Map<String, Object> params = new HashMap<>();
        params.put("cowcode", cowCode);
        params.put("year", WorldOrder.getStartYear());
        String territoryQuery = "MATCH (p:State{cowcode:$cowcode})-[:OCCUPIED]-(t:Territory{year:$year}) RETURN t";
        return Neo4jSessionFactory.getInstance().getNeo4jSession()
                .queryForObject(Territory.class, territoryQuery, params);
    }


    public static State getStateFromDatabase(Territory t) {
        State s = null;
        String mapKey = t.getMapKey();
        String name = WorldOrder.getStartYear() + "";
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey",mapKey);
        params.put("name", name);
        String query = "MATCH (t:Territory)-[:OCCUPIED]-(s:State)-[:DURING]-(:Year{name:$name}) WHERE id(t) = $mapKey RETURN s";
        State n = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(State.class, query, params);
        if (n.equals(null)) {
            return s;
        } else {
            return n;
        }
    }

}
