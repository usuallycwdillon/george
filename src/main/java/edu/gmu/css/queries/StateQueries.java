//package edu.gmu.css.queries;
//
//import edu.gmu.css.data.Resources;
//import edu.gmu.css.entities.*;
//import edu.gmu.css.service.Neo4jSessionFactory;
//import edu.gmu.css.worldOrder.WorldOrder;
//import org.neo4j.ogm.model.Result;
//import sim.engine.SimState;
//
//import java.util.*;
//import java.util.stream.Collectors;
//import java.util.stream.StreamSupport;
//
//public class StateQueries {
//
//    public static List<State> getStates(String system, int period) {
//        /*
//         * Provided the name of a system and an integer value of the year the system begins, return the list of States
//         * in the system.
//         */
//        List<State> states = new ArrayList<>();
//        Map<String, Object> params = new HashMap<>();
//        params.put("name", system); // system name
//        params.put("from", period);
//
//        String query = "MATCH (s:State)-[:MEMBER]-(f:Fact)-[:MEMBER_OF]-(y:System{name:$name}) " +
//                "WHERE f.from.year <= $from OR f.from IS NULL RETURN s";
//        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, params);
//        Iterator it = result.iterator();
//        while (it.hasNext()) {
//            Map<String, Map.Entry<String, Object>> values = (Map) it.next();
//            for (Map.Entry e : values.entrySet()) {
//                State s = (State) e.getValue();
//                states.add(s);
//            }
//        }
//        return states;
//    }
//
//    public static List<State> getCowStatesDuringPeriod(int fy, int uy) {
//        List<State> states = new ArrayList<>();
//        Map<String, Object> params = new HashMap<>();
//        params.put("name", "COW State System"); // system name
//        params.put("from", fy);
//        params.put("until", uy);
//        String q = "MATCH (s:State)-[:MEMBER]-(f:Fact)-[:MEMBER_OF]-(y:System{name:$name}) " +
//                "WHERE f.from.year <= $from <= f.until.year OR f.from IS NULL " +
//                "RETURN s";
//        Iterable<State> result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(State.class, q, params);
//        return StreamSupport.stream(result.spliterator(), false).collect(Collectors.toCollection(ArrayList::new));
//    }
//
//    public static Resources getMilResources(Polity polity, int year) {
//        Long id = polity.getId();
//        int pax = 0;
//        int exp = 0;
//        String name = year + "";
//        // MilPer
//        Map<String, Object> params = new HashMap<>();
//        params.put("id", id);
//        params.put("name", name);
//        String paxQuery = "MATCH (p:Polity)-[:MILPER]-(m:MilPerFact)-[:DURING]-(y:Year{name:$name}) " +
//                "WHERE id(p) = $id RETURN m";
//        String exQuery = "MATCH (p:Polity)-[:MILEX]-(m:MilExFact)-[:DURING]-(y:Year{name:$name}) " +
//                "WHERE id(p) = $id RETURN m";
//
//        MilPerFact milperfact = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                .queryForObject(MilPerFact.class, paxQuery, params);
//        if (milperfact != null) {
//            Double num = milperfact.getValue();
//            pax = num != null ? num.intValue() : 0;
//        }
//        MilExFact milexfact = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                .queryForObject(MilExFact.class, exQuery, params);
//        if (milexfact != null) {
//            Double amt = milexfact.getValue();
//            exp = amt != null ? amt.intValue() : 0;
//        }
//
//        return new Resources.ResourceBuilder().pax(pax).treasury(exp).build();
//    }
//
//    public static Double getInitialTaxRate(State s, int y) {
//        Map<String, Object> params = new HashMap<>();
//        params.put("cowcode", s.getCowcode());
//        params.put("during", y);
//        String query = "MATCH (s:State{cowcode:$cowcode})-[:SIM_TAX_RATE{during:$during}]->(f:TaxRateFact) RETURN f";
//        TaxRateFact f = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                .queryForObject(TaxRateFact.class, query,params);
//        return f.getValue() * 1.1; // Accounting for 10% bump on policy costs other than military
//    }
//
//
////    public static Territory getTerritoryFromDatabase(State s) {
////        String cowCode = s.getCowcode();
////        Map<String, Object> params = new HashMap<>();
////        params.put("cowcode", cowCode);
////        params.put("year", WorldOrder.getFromYear());
////        String territoryQuery = "MATCH (p:State{cowcode:$cowcode})-[:OCCUPIED]-(t:Territory{year:$year}) RETURN t";
////        return Neo4jSessionFactory.getInstance().getNeo4jSession()
////                .queryForObject(Territory.class, territoryQuery, params);
////    }
////
////
////    public static State getStateFromDatabase(Territory t) {
////        State s = null;
////        String mapKey = t.getMapKey();
////        String name = WorldOrder.getFromYear() + "";
////        Map<String, Object> params = new HashMap<>();
////        params.put("mapKey",mapKey);
////        params.put("name", name);
////        String query = "MATCH (t:Territory)-[:OCCUPIED]-(s:State)-[:DURING]-(:Year{name:$name}) WHERE id(t) = $mapKey RETURN s";
////        State n = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(State.class, query, params);
////        if (n==null) {
////            return s;
////        } else {
////            return n;
////        }
////    }
//
//    public static List<Polity> getNeighborhoodWithoutAllies(Polity p, SimState simState) {
//        WorldOrder worldOrder = (WorldOrder) simState;
//        Territory territory = p.getTerritory();
//        List<Polity> polities = new ArrayList<>();
//        Map<String, Object> params = new HashMap<>();
//        params.put("year", territory.getYear());
//        params.put("mapKey", territory.getMapKey());
//        String query = "MATCH (t:Territory{mapKey:{mapKey}})-[:OCCUPIED]-(p1:Polity)-[e:ENTERED]-(apf:AllianceParticipationFact)" +
//                "-[:ENTERED_INTO]-(a:Alliance)-[:ONE_OF]-(l:List), (a)-[:ENTERED_INTO]-()-[e2:ENTERED]-(o:Polity) \n" +
//                "WHERE e.from.year <= {year} AND e.until.year > {year} AND l.type <> \"Entente\" AND " +
//                " e2.from.year <= {year} AND e2.until.year > {year} \n" +
//                "WITH COLLECT(o) AS allies, t \n" +
//                "MATCH (t)-[:BORDERS{during:{year}}]->(:Border)-[:BORDERS{during:{year}}]-(n:Territory)-[:BORDERS{during:{year}}]-(:Border)-[:BORDERS{during:{year}}]-(o:Territory) \n" +
//                "WHERE t <> n AND t <> o \n" +
//                "WITH COLLECT(n) + COLLECT(o) AS ter, t, allies \n" +
//                "UNWIND ter AS z \n" +
//                "MATCH (z)-[:OCCUPIED]-(p:Polity) \n" +
//                "WHERE NOT p IN allies \n" +
//                "WITH COLLECT(p) as potential \n" +
//                "RETURN potential";
//        Iterable<Polity> result = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                .query(Polity.class, query, params);
//        if(result != null) {
//            for(Polity e: result) {
//                Polity op = worldOrder.getAllTheStates().stream()
//                        .filter(t -> t.getId().equals(e.getId()))
//                        .findAny()
//                        .orElse(null);
//                polities.add(op);
//            }
//        }
//        return polities;
//    }
//
//    public static boolean areAllies(Polity p, Polity t) {
//
//        return false;
//    }
//
//    public static boolean sharePeace(Polity p, Polity t) {
//
//        return false;
//    }
//
//}
