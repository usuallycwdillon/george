package edu.gmu.css.service;

import edu.gmu.css.entities.Year;

import java.util.Collections;

public class YearServiceImpl extends GenericService<Year> implements YearService {

    public Year getYearFromIntVal(int fromYear) {
       String name = "" + fromYear;
       return session.queryForObject(Year.class, "MATCH (y:Year{name:$name}) RETURN y",
               Collections.singletonMap("name", name));
    }

    public Year getNextYear(Year year) {
        String n = year.getName();
        String q = "MATCH (ty:Year{name:$name})-[:NEXT_YEAR]->(ny:Year) RETURN ny";
        return session.queryForObject(Year.class, q, Collections.singletonMap("name",n));
    }

    public Year getLastYear(Year year) {
        String n = year.getName();
        String q = "MATCH (ty:Year{name:$name})<-[:NEXT_YEAR]-(ly:Year) RETURN ly";
        return session.queryForObject(Year.class, q, Collections.singletonMap("name",n));
    }


    @Override
    Class<Year> getEntityType() {
        return Year.class;
    }
}
