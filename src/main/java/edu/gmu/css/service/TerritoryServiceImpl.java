package edu.gmu.css.service;

import edu.gmu.css.entities.CommonWeal;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.entities.Ungoverned;
import edu.gmu.css.relations.Inclusion;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;
import org.neo4j.ogm.model.Result;
import java.util.*;
import java.util.stream.Collectors;

public class TerritoryServiceImpl extends GenericService<Territory> implements TerritoryService {

    public Map<String, Territory> getStateTerritories(int startYear) {
        Map<String, Territory> territoryMap = new HashMap<>();
        String query = "MATCH (m:MembershipFact)-[:MEMBER]-(s:State)-[o]-(t:Territory{year:$year}) " +
                "WHERE t.cowcode = s.cowcode AND (m.from.year <= $year OR m.from.year IS NULL) " +
                "RETURN t";
        Map<String, Object> params = new HashMap<>();
        params.put("year", startYear);
        session.query(Territory.class, query, params).forEach(t -> territoryMap.put(t.getMapKey(), t));
        for (Map.Entry e : territoryMap.entrySet()) {
            Territory et = (Territory) e.getValue();
            et.setTileLinks(loadIncludedTiles(et.getMapKey()));
        }
        return territoryMap;
    }


    public Map<String, Territory> loadWaterTerritories() {
        Map<String, Territory> waterTerritories = new HashMap<>();
        Filter filter = new Filter("environment",ComparisonOperator.EQUALS, "Water");
        Collection<Territory> water = session.loadAll(Territory.class, filter, 1);
        for(Territory t : water) {
            waterTerritories.put(t.getMapKey(), t);
            t.setPolity(new Ungoverned(t), 0L);
        }
        return waterTerritories;
    }


    public Result loadTiles(Territory t) {
        Territory territory = t;
        Map<String, Object> params = new HashMap<>();
        params.put("mapKey", territory.getMapKey());
        String q = "MATCH (t:Territory{mapKey:$mapKey}) CALL wog.getTileWithDataFromTerritory(t) YIELD value RETURN value";
        return session.query(q, params);
    }

    public Set<Inclusion> loadIncludedTiles(String key) {
        Set<Inclusion> inclusionSet = new HashSet<>();
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", key);
        String q = "MATCH (t:Territory{mapKey:$mapKey})-[i:INCLUDES]->(tt:Tile) RETURN t, i, tt";
        Iterable<Inclusion> inclusions = session.query(Inclusion.class, q, params);
        for(Inclusion i : inclusions) inclusionSet.add(i);
        return inclusionSet;
    }

    public CommonWeal loadCommonWeal(String key) {
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", key);
        params.put("name", "Residents of " + key);
        String query = "MATCH (:Territory{mapKey:$mapKey})-[:REPRESENTS_POPULATION]-(c:CommonWeal{name:$name}) RETURN c";
        return session.queryForObject(CommonWeal.class, query, params);
    }

    @Override
    Class<Territory> getEntityType() {
        return Territory.class;
    }
}
