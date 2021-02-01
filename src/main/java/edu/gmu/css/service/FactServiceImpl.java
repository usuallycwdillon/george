package edu.gmu.css.service;

import edu.gmu.css.entities.Fact;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Year;
import java.util.Collections;


public class FactServiceImpl extends GenericService<Fact> implements FactService {

    public Year getRelatedYear(Fact f) {
        Long factId = f.getId();
        String query = "MATCH (f:Fact) WHERE id(f) = {param} MATCH (f)-[:DURING]-(y:Year) RETURN y";
        Year year = session.queryForObject(Year.class, query, Collections.singletonMap("param", factId));
        return year;
    }

    public Institution getRelatedInstitution(Fact f) {
        Long factId = f.getId();
        String query = "MATCH (f:Fact) WHERE id(f) = {param} MATCH (f)--(i:Institution) RETURN i";
        Institution i = session.queryForObject(Institution.class, query, Collections.singletonMap("param", factId));
        return i;
    }


    @Override
    Class<Fact> getEntityType() {
        return Fact.class;
    }

}
