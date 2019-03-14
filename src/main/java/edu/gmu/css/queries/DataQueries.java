package edu.gmu.css.queries;

import edu.gmu.css.service.Neo4jSessionFactory;
import org.neo4j.ogm.model.Result;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class DataQueries {

    public Map<Long, Integer> getWeeklyWarsCount() {
        Map<Long, Integer> warHistory = new HashMap<>();
        for (long i = 0L; i < 10070L; i++) {
            warHistory.put(i, 0);
        }
        String query = "WITH range(52, 10070) AS weeks \n" +
                "UNWIND weeks AS k \n" +
                "MATCH (fw:Week)-[:FROM_WEEK]-(f:WarParticipationFact)-[:UNTIL_WEEK]-(uw:Week) \n" +
                "WHERE fw.stepNumber <= k <= uw.stepNumber \n" +
                "WITH f, k \n" +
                "MATCH (f)-[:PARTICIPATED_IN]-(w:War) \n" +
                "RETURN k, count(DISTINCT w) AS wars";
        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, Collections.EMPTY_MAP, true);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            Map<String, Object> item = (Map<String, Object>) it.next();
            Long step = (Long) item.get("k");
            Integer wars = Math.toIntExact((Long) item.get("wars"));
            warHistory.put(step, wars);
        }
        return warHistory;
    }




}
