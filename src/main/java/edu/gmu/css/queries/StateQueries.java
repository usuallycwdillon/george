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
                "WHERE f.from.year <= $from OR f.from IS NULL RETURN s";
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
        if (n==null) {
            return s;
        } else {
            return n;
        }
    }

    public static DiscretePolityFact getPolityData(Polity p, int year) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", p.getId());
        params.put("year", year);
        String query = "MATCH (p:Polity)<-[d:DESCRIBES_POLITY_OF]-(f:DiscretePolityFact) " +
                "WHERE id(p) = $id AND d.from.year <= $year <= d.until.year " +
                "RETURN f ORDER BY d.from LIMIT 1";
        DiscretePolityFact dpf = dpf = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .queryForObject(DiscretePolityFact.class, query, params);
        if (dpf != null) {
            dpf.setPolity(p);
            return dpf;
        } else {
            return null;
        }
    }

    public static List<Polity> getNeighborhoodWithoutAllies(Polity p) {
        Territory territory = p.getTerritory();
        List<Polity> polities = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();
        params.put("year", territory.getYear());
        params.put("mapKey", territory.getMapKey());
        String query = "MATCH (t:Territory{mapKey:{mapKey}})-[:OCCUPIED]-(p1:Polity)-[e:ENTERED]-(apf:AllianceParticipationFact)" +
                "-[:ENTERED_INTO]-(a:Alliance)-[:ONE_OF]-(l:List), (a)-[:ENTERED_INTO]-()-[e2:ENTERED]-(o:Polity) \n" +
                "WHERE e.from.year <= {year} AND e.until.year > {year} AND l.type <> \"Entente\" AND " +
                " e2.from.year <= {year} AND e2.until.year > {year} \n" +
                "WITH COLLECT(o) AS allies, t \n" +
                "MATCH (t)-[:BORDERS{during:{year}}]->(:Border)-[:BORDERS{during:{year}}]-(n:Territory)-[:BORDERS{during:{year}}]-(:Border)-[:BORDERS{during:{year}}]-(o:Territory) \n" +
                "WHERE t <> n AND t <> o \n" +
                "WITH COLLECT(n) + COLLECT(o) AS ter, t, allies \n" +
                "UNWIND ter AS z \n" +
                "MATCH (z)-[:OCCUPIED]-(p:Polity) \n" +
                "WHERE NOT p IN allies \n" +
                "WITH COLLECT(p) as potential \n" +
                "RETURN potential";
        Iterable<Polity> result = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .query(Polity.class, query, params);
        if(result != null) {
            for(Polity e: result) {
                Polity op = WorldOrder.getAllTheStates().stream()
                        .filter(t -> t.getId().equals(e.getId()))
                        .findAny()
                        .orElse(null);
                polities.add(op);
            }
        }
        return polities;
    }

}
