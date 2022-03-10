package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Grid;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;
import org.neo4j.ogm.model.Result;

import java.util.*;

public class TileServiceImpl extends GenericService<Tile> implements TileService {

    public final List<Tile> findNeighbors(Tile t, WorldOrder wo) {
        String ay = t.getAddressYear();
        List<Tile> neighbors = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();
        params.put("addressYear", ay);
        String q = "MATCH (t:Tile{addressYear:$addressYear})-[:ABUTS]-(n:Tile) RETURN n.addressYear AS tileAddress";
        Result result = session.query(q, params, true);
        Iterator it = result.iterator();
        while(it.hasNext()) {
            Map<String, Object> resultMap = (Map<String, Object>) it.next();
            String address = (String) resultMap.get("tileAddress");
            neighbors.add(wo.tiles.get(address));
        }
        return neighbors;
     }

    public Set<String> loadIncludedTiles(Territory ter) {
        Territory territory = ter;
        Set<String> inclusionSet = new HashSet<>();
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", ter.getMapKey());
        String q = "MATCH (t:Territory{mapKey:$mapKey})-[i:INCLUDES]->(tt:Tile) RETURN tt.addressYear AS tileAddress";
        Result r = session.query(q, params, true);
        Iterator it = r.iterator();
        while(it.hasNext()) {
            Map<String, Object> resultMap = (Map<String, Object>) it.next();
            inclusionSet.add((String) resultMap.get("tileAddress"));
        }
        return inclusionSet;
    }

    public Tile find(String id) {
        return session.load(Tile.class, id);
    }

    public Map<String, Tile> loadAll(int y) {
        Map<String, Tile> tiles = new HashMap<>();
        session.loadAll(Tile.class, new Filter("year", ComparisonOperator.EQUALS, y))
                .forEach(tile -> tiles.put(tile.getAddressYear(), tile));
        return tiles;
    }

    public List<Tile> getGridTiles(Grid g) {
        List<Tile> resultTiles = new ArrayList<>();
        session.loadAll(Tile.class, new Filter("address", ComparisonOperator.EQUALS, g.getAddress()))
                .forEach(t -> resultTiles.add(t));
        return resultTiles;
    }

    public void updateThisTile(Tile entity) {
        session.save(entity, 0);
//        return find(entity.getAddressYear());
    }

    @Override
    Class<Tile> getEntityType() {
        return Tile.class;
    }
}
