package edu.gmu.css.queries;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Leadership;
import edu.gmu.css.data.World;
import edu.gmu.css.entities.*;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.WorldOrder;

import java.util.*;

//import edu.gmu.css.worldOrder.WorldOrder.allTheLeaders;
//import edu.gmu.css.worldOrder.WorldOrder.allTheStates;

public class TerritoryQueries {


    public static Map<String, Territory> getStateTerritories(int startYear, WorldOrder wo) {
        MersenneTwisterFast random = wo.random;
        Map<String, Territory> territoryMap = new HashMap<>();
        String query = "MATCH (m:MembershipFact)-[:MEMBER]-(s:State)-[o]-(t:Territory{year:$year}) " +
                       "WHERE t.cowcode = s.cowcode AND (m.from.year <= $year OR m.from.year IS NULL) " +
                       "RETURN t";
        Map<String, Object> params = new HashMap<>();
        params.put("year", startYear);
        Neo4jSessionFactory.getInstance().getNeo4jSession().query(Territory.class, query, params)
            .forEach(t -> territoryMap.put(t.getMapKey(), loadWithRelations(t.getMapKey(), wo)));
        return territoryMap;
    }

    public static Territory loadWithRelations(String mapKey, WorldOrder wo) {
        MersenneTwisterFast random = wo.random;
        Territory t = Neo4jSessionFactory.getInstance().getNeo4jSession().load(Territory.class, mapKey, 1);
        int year = t.getYear();
        if (t.getPolity() == null) {
            System.out.println(t.getMapKey() + " is not a known state government; creating a blank polity.");
            Polity p = new Polity();
            p.setTerritory(t);
            t.setGovernment(p, 0L);
        }
        if (t.getPolity().getClass() == State.class) {
            State s = (State) t.getPolity();
            Leadership l = new Leadership(random);
            l.setPolity(s);
            s.setTerritory(t);
            s.setLeadership(l);
            s.loadInstitutionData(year);
            s.setResources(StateQueries.getMilResources(s, year));
            if (s.getResources()==null) { // make something up
                s.setResources(new Resources.ResourceBuilder().pax(10000).treasury(100000.0).build());
                System.out.println("I made up some military resources for " + s.getName());
            }
            s.setSecurityStrategy(s.getResources().multipliedBy(0.9));
            if (!s.findPolityData(year)) {
                s.setNeutralPolityFact();
                System.out.println("No polity fact for " + s.getName());
            }
            wo.allTheStates.add(s);
            wo.allTheLeaders.add(l);
            t.initiateGraph();
        }
        return t;
    }

    public static Map<String, Territory> getWaterTerritories() {
        String [] seas = {"World Oceans", "Black Sea", "Caspian Sea"};
        Map<String, Territory> waterTerritories = new HashMap<>();
        for (String key : seas) {
            Territory territory = Neo4jSessionFactory.getInstance().getNeo4jSession().load(Territory.class, key, 1);
            Ungoverned u = new Ungoverned(territory);
            territory.setGovernment(u, 0L);
            waterTerritories.put(key, territory);
        }
        return waterTerritories;
    }


}


