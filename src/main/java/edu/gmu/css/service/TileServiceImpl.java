package edu.gmu.css.service;

import com.uber.h3core.H3Core;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Territory;
import org.jetbrains.annotations.NotNull;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;

import java.util.*;
import java.util.stream.Collectors;

public class TileServiceImpl extends GenericService<Tile> implements TileService {

    public final Set<Tile> findNeighbors(Tile t) {
        String ay = t.getAddressYear();
        Set<Tile> neighbors = new HashSet<>();
        Map<String, Object> params = new HashMap<>();
        params.put("addressYear", ay);
        String q = "MATCH (t:Tile{addressYear:$addressYear})-[:ABUTS]-(n:Tile)  RETURN n";
        Iterable<Tile> result = session.query(Tile.class,q,params);
        Iterator it = result.iterator();
        while(it.hasNext()) {
            neighbors.add((Tile) it.next());
        }
        return neighbors;
     }

    public Set<Tile> loadIncludedTiles(Territory ter) {
        Territory territory = ter;
        Set<Tile> inclusionSet = new HashSet<>();
        Map<String, String> params = new HashMap<>();
        params.put("mapKey", ter.getMapKey());
        String q = "MATCH (t:Territory{mapKey:$mapKey})-[i:INCLUDES]->(tt:Tile) RETURN tt";
        Iterable<Tile> inclusions = session.query(Tile.class, q, params);
        for(Tile t : inclusions) {
            inclusionSet.add(t);
            t.setLinkedTerritory(territory);
        }
        return inclusionSet;
    }

    public Map<String, Tile> loadAll(int y) {
        Map<String, Tile> tiles = new HashMap<>();
        session.loadAll(Tile.class, new Filter("year", ComparisonOperator.EQUALS, y))
                .forEach(tile -> tiles.put(tile.getAddressYear(), tile));
//        Tile t = tiles.get("840d837ffffffff.1816");
//        System.out.println(t.toString());
        return tiles;
    }

    @Override
    Class<Tile> getEntityType() {
        return Tile.class;
    }
}
