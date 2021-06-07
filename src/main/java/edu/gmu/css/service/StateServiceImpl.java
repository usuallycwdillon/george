package edu.gmu.css.service;

import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.State;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.worldOrder.WorldOrder;
import io.netty.handler.codec.serialization.ObjectEncoder;

import java.util.*;

public class StateServiceImpl extends GenericService<State> implements StateService {

    public State findStateForTerritory(Territory t) {
        Territory territory = t;
        String q = "MATCH (t:Territory{mapKey:$mapKey})<-[:OCCUPIED]-(s:State) RETURN s";
        State s = session.queryForObject(State.class,q, Collections.singletonMap("mapKey", t.getMapKey()));
        return s;
    }

    public List<State> getRiskyNeighbors(Long id, Integer yr) {
        List<State> states = new ArrayList<>();
        List<State> valid = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("year", yr);
        String q = "MATCH (p1:State) WHERE id(p1)={id}" +
                "OPTIONAL MATCH (p1)-[:ENTERED]-(apf1:AllianceParticipationFact)-[:ENTERED_INTO]-(a:Alliance)-[:ENTERED_INTO]-(" +
                "apf2:AllianceParticipationFact)-[:ENTERED]-(o:State)\n" +
                "WHERE apf1.from.year <= {year} AND apf1.until.year > {year} AND apf2.from.year <= {year} AND " +
                "apf2.until.year > {year} AND a.ssType<>'Entente'\n" +
                "WITH COLLECT(o) AS allies, p1\n" +
                "MATCH (p1)-[:OCCUPIED]-(t:Territory{year:{year}})-[:BORDERS{during:{year}}]->(:Border)-[:BORDERS{" +
                "during:{year}}]-(nt:Territory)-[:BORDERS{during:{year}}]-(:Border)-[:BORDERS{during:{year}}]-(ot:Territory)\n" +
                "WHERE t <> nt AND t <> ot \n" +
                "WITH COLLECT(nt) + COLLECT(ot) AS ter, t, allies\n" +
                "UNWIND ter AS z \n" +
                "OPTIONAL MATCH (z)<-[:OCCUPIED]-(p:State) \n" +
                "WHERE NOT p IN allies \n" +
                "WITH COLLECT(p) as potential \n" +
                "RETURN potential";
        Iterable<State> result = session.query(State.class, q, params);
        Iterator<State> it = result.iterator();
        it.forEachRemaining(states::add);
        return states;
    }


    @Override
    Class<State> getEntityType() {
        return State.class;
    }
}
