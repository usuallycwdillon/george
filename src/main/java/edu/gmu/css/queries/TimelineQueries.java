package edu.gmu.css.queries;

import edu.gmu.css.entities.Week;
import edu.gmu.css.entities.Year;
import edu.gmu.css.service.Neo4jSessionFactory;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

public class TimelineQueries {

    public static Year getYearFromIntVal(int fromYear) {
        String yearQ = "MATCH (y:Year{name:$name}) RETURN y";
        Map<String, String> yparam = new HashMap<>();
        yparam.put("name", fromYear+"");
        return Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Year.class, yearQ, yparam);
    }

    public static Week getFirstWeek(Year year) {
        String n = year.getName();
        Map<String, String> param = new HashMap<>();
        param.put("name", n);
        String q = "MATCH (y:Year{name:$name})-[:PART_OF]-(w:Week) RETURN w ORDER BY w.stepNumber LIMIT 1";
        Week w = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Week.class, q, param);
        return w;
    }

    public static Year getNextYear(Year year) {
        String n = year.getName();
        Map<String, String> param = new HashMap<>();
        param.put("name", n);
        String q = "MATCH (ty:Year{name:$name})-[:NEXT_YEAR]->(ny:Year) RETURN ny";
        return Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Year.class, q, param);
    }

    public static Year getLastYear(Year year) {
        String n = year.getName();
        Map<String, String> param = new HashMap<>();
        param.put("name", n);
        String q = "MATCH (ty:Year{name:$name})<-[:NEXT_YEAR]-(py:Year) RETURN py";
        return Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Year.class, q, param);
    }

    public static Week getNextWeek(Week w) {
        String n = w.getName();
        Map<String, String> param = new HashMap<>();
        param.put("name", n);
        String q = "MATCH (tw:Week{name:$name})-[:NEXT_WEEK]->(nw:Week) RETURN nw";
        return Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Week.class, q, param);
    }

    public static Week getLastWeek(Week w) {
        String n = w.getName();
        Map<String, String> param = new HashMap<>();
        param.put("name", n);
        String q = "MATCH (tw:Week{name:$name})<-[:NEXT_WEEK]-(pw:Week) RETURN pw";
        return Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Week.class, q, param);
    }

    public static LinkedList<Week> getWeeksInYear(Year y) {
        String n = y.getName();
        Map<String, String> param = new HashMap<>();
        param.put("name", n);
        String q = "MATCH (y:Year{name:$name})-[:PART_OF]-(w:Week) RETURN w ORDER BY w.stepNumber LIMIT 53";
        Iterable<Week> r =  Neo4jSessionFactory.getInstance().getNeo4jSession().query(Week.class, q, param);
        LinkedList<Week> weeks = StreamSupport.stream(r.spliterator(), false)
                .collect(Collectors.toCollection(LinkedList::new));
        return weeks;
    }



}
