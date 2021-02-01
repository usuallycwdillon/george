package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TileServiceImpl extends GenericService<Tile> implements TileService {

    public final Iterable<Tile> findNeighbors(Tile t) {
        Map<String, Object> params = new HashMap<>();
        params.put("address", t.getAddress());
        String q = "MATCH (t:Tile{address:$address})-[a:ABUTS]->(n:Tile) RETURN t, a, n";
        Iterable<Tile> result = session.query(Tile.class, q, params);
        return result;
     }




    @Override
    Class<Tile> getEntityType() {
        return Tile.class;
    }
}
