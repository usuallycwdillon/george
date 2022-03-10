package edu.gmu.css.service;

import edu.gmu.css.entities.State;
import org.neo4j.ogm.model.Result;

import java.util.*;

public class ThreatNetworkServiceImpl extends GenericService<State> {

    public List<String> getRiskyNeighbors(Long id, Integer yr) {
        List<String> states = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("year", yr);
        String q = "MATCH (p1:State) WHERE id(p1) = $id \n" +
                "OPTIONAL MATCH (p1)-[:ENTERED]-(apf1:AllianceParticipationFact)-[:ENTERED_INTO]-(a:Alliance)-[:ENTERED_INTO]-(" +
                "apf2:AllianceParticipationFact)-[:ENTERED]-(o:State)\n" +
                "WHERE apf1.from.year <= $year AND apf1.until.year > $year AND apf2.from.year <= $year AND " +
                "apf2.until.year > $year AND a.ssType<>'Entente'\n" +
                "WITH COLLECT(o) AS allies, p1\n" +
                "MATCH (p1)-[:OCCUPIED]-(t:Territory{year:$year})-[:BORDERS{during:$year}]->(:Border)-[:BORDERS{" +
                "during:$year}]-(nt:Territory)-[:BORDERS{during:$year}]-(:Border)-[:BORDERS{during:$year}]-(ot:Territory)\n" +
                "WHERE t <> nt AND t <> ot \n" +
                "WITH COLLECT(nt) + COLLECT(ot) AS ter, t, allies\n" +
                "UNWIND ter AS z \n" +
                "MATCH (z)<-[:OCCUPIED]-(p:State) \n" +
                "WHERE NOT p IN allies \n" +
                "WITH COLLECT(DISTINCT p.cowcode) as potential \n" +
                "UNWIND potential AS cow RETURN cow ";
        Result result = session.query(q, params, true);
        Iterator<Map<String, Object>> rit = result.iterator();
        while (rit.hasNext()) {
            states.add( (String) rit.next().get("cow") );
        }
        return states;
    }

    public List<String> getAnyNeighbor(Long id, Integer yr) {
        List<String> states = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("year", yr);
        String q = "MATCH (p1:State) WHERE id(p1)=$id \n" +
                "MATCH (p1)-[:OCCUPIED]-(t:Territory{year:$year})-[:BORDERS{during:$year}]->(:Border)-[:BORDERS{\n" +
                "during:$year}]-(nt:Territory)-[:BORDERS{during:$year}]-(:Border)-[:BORDERS{during:$year}]-(ot:Territory) \n" +
                "WHERE t <> nt AND t <> ot \n" +
                "WITH COLLECT(nt) + COLLECT(ot) AS ter, t \n" +
                "UNWIND ter AS z \n" +
                "MATCH (z)<-[:OCCUPIED]-(p:State)-[:MEMBER]->(mf:MembershipFact) \n" +
                "WHERE (mf.from.year <= $year OR mf.from.year IS NULL) AND mf.until.year >= $year \n" +
                "WITH COLLECT(DISTINCT p.cowcode) as potential \n" +
                "UNWIND potential AS cow RETURN cow ";
        Result result = session.query(q, params, true);
        Iterator<Map<String, Object>> rit = result.iterator();
        while (rit.hasNext()) {
            states.add( (String) rit.next().get("cow") );
        }
        return states;
    }


    @Override
    Class<State> getEntityType() {
        return State.class;
    }
}
