package edu.gmu.css.queries;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Leadership;
import edu.gmu.css.data.EconomicPolicy;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.*;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.ml.neuralnet.sofm.LearningFactorFunction;

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


//        Neo4jSessionFactory.getInstance().getNeo4jSession().query(Territory.class, query, params)
//            .forEach(t -> territoryMap.put(t.getMapKey(), loadWithRelations(t.getMapKey(), wo)));
        return territoryMap;
    }

    public static Territory loadWithRelations(String mapKey, WorldOrder wo) {
        Territory t = Neo4jSessionFactory.getInstance().getNeo4jSession().load(Territory.class, mapKey, 1);
        int year = t.getYear();
        if (t.getPolity().getClass() == State.class) {
            State s = (State) t.getPolity();
            s.setTerritory(t);
            CommonWeal cw = t.findCommonWeal();
            Leadership l = cw.getLeadership();
            l.setPolity(s);
            s.setLeadership(l);
            s.setResources((StateQueries.getMilResources(s, year)).multipliedBy(1.1));
            s.setEconomicPolicy(new EconomicPolicy(0.6, 0.4, (StateQueries.getInitialTaxRate(s, year) / 0.9)));
            if (s.getResources()==null) { // make something up
                s.setResources(new Resources.ResourceBuilder()
                        .pax(s.getPopulation() * 0.01).treasury(s.getTerritory().getCurrentSDP() * 0.02).build());
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


