package edu.gmu.css.queries;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.entities.Ungoverned;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.WorldOrder;

import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;
import org.neo4j.ogm.model.Result;

import java.util.*;

public class TerritoryQueries {

//    public Map<Long, Tile> tiles = WorldOrder.tiles;

    public static Map<String, Territory> getStateTerritories(int startYear) {
        Map<String, Territory> territoryMap = new HashMap<>();
        String query = "MATCH (m:MembershipFact)-[:MEMBER]-(s:State)-[o]-(t:Territory{year:$year}) " +
                "WHERE t.cowcode = s.cowcode AND m.from.year <= $year " +
                " RETURN t";
        Map<String, Object> params = new HashMap<>();
        params.put("year", startYear);
        Iterable<Territory> result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(Territory.class, query, params);
        result.forEach(t -> territoryMap.put(t.getMapKey(), t));
        return territoryMap;
    }

    public static Territory loadWithRelations(String mapKey) {
        Territory territory = Neo4jSessionFactory.getInstance().getNeo4jSession().load(Territory.class, mapKey, 1);
        return territory;
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


