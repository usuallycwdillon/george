package edu.gmu.css.service;

import edu.gmu.css.entities.Week;
import edu.gmu.css.entities.Year;
import edu.gmu.css.worldOrder.WorldOrder;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

public class WeekServiceImpl extends GenericService<Week> implements WeekService {

    public LinkedList<Week> getWeekOfYear(Year y) {
        LinkedList<Week> weeks = new LinkedList<>();
        String q = "MATCH (y:Year)<-[:PART_OF]-(w:Week) WHERE id(y) = $id RETURN w ORDER BY w.stepNumber";
        Iterable<Week> r = session.query(Week.class, q, Collections.singletonMap("id", y.getId()));
        Iterator<Week> rit = r.iterator();
        while(rit.hasNext()) {
            weeks.add(rit.next());
        }
        return weeks;
    }

    public Week getWeekFromSimState(WorldOrder wo) {
        long s = wo.getStepNumber() + wo.getDateIndex();
        Year y = wo.getDataYear();
        Week w = new Week(s);
        w.setYear(y);
        Long wid  = session.resolveGraphIdFor(w);
        Week rw = session.load(Week.class, wid);
        return rw;
    }

    public Week getFirstWeek(Year year) {
        String n = year.getName();
        String q = "MATCH (y:Year{name:$name})-[:PART_OF]-(w:Week) RETURN w ORDER BY w.stepNumber LIMIT 1";
        Week w = session.queryForObject(Week.class, q, Collections.singletonMap("name", n));
        return w;
    }

    public Week getNextWeek(Week w) {
        Long id = w.getId();
        String q = "MATCH (tw:Week)-[:NEXT_WEEK]->(nw:Week) WHERE id(tw) = $id RETURN nw";
        return session.queryForObject(Week.class, q, Collections.singletonMap("id", id));
    }

    public Week getLastWeek(Week w) {
        Long id = w.getId();
        String q = "MATCH (lw:Week)<-[:NEXT_WEEK]-(tw:Week) WHERE id(tw) = $id RETURN lw";
        return session.queryForObject(Week.class, q, Collections.singletonMap("id", id));
    }

    public LinkedList<Week> getWeeksInYear(Year y) {
        String n = y.getName();
        String q = "MATCH (y:Year{name:$name})<-[:PART_OF]-(w:Week) RETURN w ORDER BY w.stepNumber LIMIT 53";
        Iterable<Week> r =  session.query(Week.class, q, Collections.singletonMap("name", n));
        LinkedList<Week> weeks = StreamSupport.stream(r.spliterator(), false)
                .collect(Collectors.toCollection(LinkedList::new));
        return weeks;
    }



    @Override
    Class<Week> getEntityType() {
        return Week.class;
    }
}
