package edu.gmu.css.service;

import edu.gmu.css.entities.*;
import org.neo4j.ogm.model.Result;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;


public class FactServiceImpl extends GenericService<Fact> implements FactService {

    public Year getRelatedYear(Fact f) {
        Long factId = f.getId();
        String query = "MATCH (f:Fact) WHERE id(f) = $param MATCH (f)-[:DURING]-(y:Year) RETURN y";
        Year year = session.queryForObject(Year.class, query, Collections.singletonMap("param", factId));
        return year;
    }

    public Institution getRelatedInstitution(Fact f) {
        Long factId = f.getId();
        String query = "MATCH (f:Fact) WHERE id(f) = $param MATCH (f)--(i:Institution) RETURN i";
        Institution i = session.queryForObject(Institution.class, query, Collections.singletonMap("param", factId));
        return i;
    }

    public Fact getMilPerFact(String yr, Polity p) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", p.getId());
        params.put("name", yr);
        String q = "MATCH (p:Polity) WHERE id(p) = $id WITH p MATCH (p)-[:MILPER]-(m:MilPerFact)-[:DURING]-(y:Year{name:$name}) RETURN m";
        Fact f = session.queryForObject(MilPerFact.class, q, params);
        return f;
    }

    public Fact getMilExFact(String yr, Polity p) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", p.getId());
        params.put("name", yr);
        String q = "MATCH (p:Polity) WHERE id(p) = $id WITH p MATCH (p)-[:MILEX]-(m:MilExFact)-[:DURING]-(y:Year{name:$name}) RETURN m";
        Fact f = session.queryForObject(MilExFact.class, q, params);
        return f;
    }

    public Fact getInitialTaxRate(State s, int y) {
        Map<String, Object> params = new HashMap<>();
        params.put("cowcode", s.getCowcode());
        params.put("during", y);
        String query = "MATCH (s:State{cowcode:$cowcode})-[:SIM_TAX_RATE{during:$during}]->(f:TaxRateFact) RETURN f";
        Fact f = session.queryForObject(TaxRateFact.class, query,params);
        return f;
    }

    public Double getNeighborAverageCostPerPax(State s, int y) {
        Map<String, Object> params = new HashMap<>();
        params.put("cowcode", s.getCowcode());
        params.put("during", y);
        String query = "MATCH (s:State{cowcode:$cowcode})-[:SHARES_BORDER]->(:BorderFact)-[:BORDERS_WITH]->(:Border{year:$during}" +
                ")<-[:BORDERS_WITH]-(:BorderFact)<-[:SHARES_BORDER]-(n:State) \n" +
                "MATCH (n)-[:MILEX]->(x:MilExFact{during:$during}) WITH n,s,x\n" +
                "MATCH (n)-[:MILPER]->(p:MilPerFact{during:$during}) WITH n, s, x, p\n" +
                "WITH sum(x.value) AS costs, sum(p.value) AS pax\n" +
                "RETURN costs/pax AS cpp";
        Result r = session.query(query, params, true);
        return (Double) (r.iterator().next().get("cpp"));
    }


    @Override
    Class<Fact> getEntityType() {
        return Fact.class;
    }

}
