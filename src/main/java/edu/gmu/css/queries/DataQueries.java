package edu.gmu.css.queries;

import edu.gmu.css.service.Neo4jSessionFactory;
import org.neo4j.ogm.model.Result;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class DataQueries {

    public static Map<Long, Integer> getWeeklyWarHistory() {
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

    public static Map<String, Double> getWarAndConflictAverages() {
        Map<Long, Integer> warOnset = new HashMap<>();
        Map<Long, Integer> warParticipation = new HashMap<>();
        Map<Long, Integer> warInitiation = new HashMap<>();
        String q = "MATCH (fw:Week)-[:FROM_WEEK]-(f:WarParticipationFact)-[:PARTICIPATED_IN]-(w:War), " +
            "(f)-[p:PARTICIPATED{initiated:true}]-(s:State) WHERE fw.stepNumber > 52 " +
            "WITH collect({week:fw.stepNumber, wars:w, part:f, init:p}) AS rows \n" +
            "MATCH (fw:Week)-[:FROM_WEEK]-(f:DisputeParticipationFact{originatedDistpute:true})-[:DISPUTED_OVER]-(d:Dispute), \n" +
            "(f)-[p:DISPUTED]-(s:State) WHERE fw.stepNumber > 52 " +
            "WITH rows + collect({week:fw.stepNumber, wars:d, part:f, init:p}) AS allRows\n" +
            "UNWIND allRows AS r\n" +
            "   WITH r.week as week, r.wars as wars, r.part as part, r.init as init\n" +
            "   RETURN DISTINCT week, count(DISTINCT wars) as wars, count(part) as states, count(init) AS inits ORDER BY week";
        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(q, Collections.EMPTY_MAP, true);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            Map<String, Object> item = (Map<String, Object>) it.next();
            Long step = (Long) item.get("week");
            Integer war = ((Number) item.get("wars")).intValue();
            Integer state = ((Number) item.get("states")).intValue();
            Integer inits = ((Number) item.get("inits")).intValue();
            warOnset.put(step, war);
            warParticipation.put(step, state);
            warInitiation.put(step, inits);
        }
        int len = 10070 - 52;
        int allOnsets = warOnset.values().stream().reduce(0, Integer::sum);
        int allStates = warParticipation.values().stream().reduce(0, Integer::sum);
        int allInits = warInitiation.values().stream().reduce(0,Integer::sum);
        Map<String, Double> averages = new HashMap<>();
        averages.put("onset", (allOnsets * 1.0 / len * 1.0));
        averages.put("participants", allStates * 1.0 / len * 1.0);
        averages.put("initiators", (allInits * 1.0 / len * 1.0));
        return averages;
    }


}
