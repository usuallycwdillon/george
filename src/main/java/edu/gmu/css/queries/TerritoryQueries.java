package edu.gmu.css.queries;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Leadership;
import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.*;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.WorldOrder;

import javax.xml.transform.Result;
import java.util.*;


public class TerritoryQueries {


    public static Map<String, Territory> getStateTerritories(int startYear, WorldOrder wo) {
        Map<String, Territory> territoryMap = new HashMap<>();
        String query = "MATCH (m:MembershipFact)-[:MEMBER]-(s:State)-[:OCCUPIED]-(t:Territory{year:$year}) " +
                       "WHERE t.cowcode = s.cowcode AND (m.from.year <= $year OR m.from.year IS NULL) " +
                       "RETURN t";
        Map<String, Object> params = new HashMap<>();
        params.put("year", startYear);
        Iterable<Territory> territories = Neo4jSessionFactory.getInstance().getNeo4jSession().query(Territory.class, query, params);

        Neo4jSessionFactory.getInstance().getNeo4jSession().query(Territory.class, query, params)
            .forEach(t -> territoryMap.put(t.getMapKey(), loadWithRelations(t.getMapKey(), wo)));

        return territoryMap;
    }

    public static Territory loadWithRelations(String mapKey, WorldOrder wo) {
        Territory t = Neo4jSessionFactory.getInstance().getNeo4jSession().load(Territory.class, mapKey, 1);
        int year = t.getYear();
        if (WorldOrder.DEBUG && t.getPolity() == null) {
            System.out.println(t.getMapKey() + " is not a known state government; creating a blank polity.");
            Polity p = new Polity();
            p.setTerritory(t);
            t.setPolity(p, 0L);
        }
        if (t.getPolity().getClass() == State.class) {
            State s = (State) t.getPolity();
            Leadership l = new Leadership();
            l.setPolity(s);
            s.setTerritory(t);
            s.setLeadership(l);
//            s.loadInstitutionData(year, wo);
            s.setResources(StateQueries.getMilResources(s, year));
            s.setEconomicPolicy(new EconomicPolicy(0.6, 0.4, (StateQueries.getInitialTaxRate(s, year) / 0.95)));
            if (s.getResources()==null) { // make something up
                s.setResources(new Resources.ResourceBuilder().pax(25).treasury(1000.0).build());
                System.out.println("I made up some military resources for " + s.getName());
            }
            s.setSecurityStrategy(s.getResources());
            if (!s.findPolityData(year)) {
                s.setNeutralPolityFact();
                System.out.println("No polity fact for " + s.getName());
            }
            s.setWarParams(wo.getModelRun().getWarParameters());
            wo.allTheStates.add(s);
            wo.allTheLeaders.add(l);
        }
        return t;
    }

    public static Map<String, Territory> getWaterTerritories() {
        String [] seas = {"World Oceans", "Black Sea", "Caspian Sea"};
        Map<String, Territory> waterTerritories = new HashMap<>();
        for (String key : seas) {
            Territory territory = Neo4jSessionFactory.getInstance().getNeo4jSession().load(Territory.class, key, 1);
            Ungoverned u = new Ungoverned(territory);
            territory.setPolity(u, 0L);
            waterTerritories.put(key, territory);
        }
        return waterTerritories;
    }



}


