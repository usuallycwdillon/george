package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.entities.Ungoverned;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.model.Result;

import java.util.*;

public class TerritoryServiceImpl extends GenericService<Territory> implements TerritoryService {

    public Map<String, Territory> getStateTerritories(int startYear, WorldOrder wo) {

        Map<String, Territory> territoryMap = new HashMap<>();
        String query = "MATCH (m:MembershipFact)-[:MEMBER]-(s:State)-[o]-(t:Territory{year:$year}) " +
                "WHERE t.cowcode = s.cowcode AND (m.from.year <= $year OR m.from.year IS NULL) " +
                "RETURN t";
        Map<String, Object> params = new HashMap<>();
        params.put("year", startYear);
        session.query(Territory.class, query, params)
                .forEach(t -> territoryMap.put(t.getMapKey(), findTerritoryFromTileMap(t, wo)));
        return territoryMap;
    }

    private Territory findTerritoryFromTileMap(Territory t, WorldOrder wo) {
        Territory territory = t;
        WorldOrder worldOrder = wo;
        List<Tile> tileList = loadIncludedTiles(territory.getMapKey(), wo);
        Tile tile = tileList.get(1);
        Map<String, Tile> tileMap = wo.getTiles();
        if(tileMap.containsKey(tile.getAddressYear() )) {
            return tileMap.get(tile.getAddressYear()).getLinkedTerritory();
        } else {
            territory.setTileLinks(new HashSet<>(loadIncludedTiles(territory.getMapKey(), wo)));
            return territory;
        }
    }

    public Map<String, Territory> loadWaterTerritories(int y) {
        int year = y;
        Map<String, Territory> waterTerritories = new HashMap<>();
//        Filter waterfilter = new Filter("environment",ComparisonOperator.EQUALS, "Water");
//        Filter yearFilter = new Filter("year", ComparisonOperator.EQUALS, year);
//        Filters filter = waterfilter.and(yearFilter);
//        Collection<Territory> water = session.loadAll(Territory.class, filter, 1);
        Map<String, Object> params = new HashMap<>();
        params.put("environment", "Water");
        params.put("year", year);
        String query = "MATCH (t:Territory{environment:$environment, year:$year}) RETURN t";
        Iterable<Territory> water = session.query(Territory.class,query, params);
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
        String q = "MATCH (t:Territory{mapKey:$mapKey})-[:INCLUDES]->(i:Tile) RETURN t, i";
        return session.query(q, params);
    }

    public List<Tile> loadIncludedTiles(String key, WorldOrder wo) {
        List<Tile> tileList = new ArrayList();
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", key);
        String q = "MATCH (t:Territory{mapKey:$mapKey})-[i:INCLUDES]->(tt:Tile) RETURN tt.addressYear";
        Result r = session.query(q, params);
        Iterator it = r.iterator();
//        Iterable<String> inclusions = session.query(Tile.class, q, params);
        while (it.hasNext()) {
            tileList.add(wo.tiles.get(it.next()));
        }
//        for(Tile t : inclusions) tileList.add(t);
        return tileList;
    }



    @Override
    Class<Territory> getEntityType() {
        return Territory.class;
    }
}
