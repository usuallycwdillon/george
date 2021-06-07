package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Grid;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class GridServiceImpl extends GenericService<Grid> implements GridService {

    public final Grid findGridForTile(String a) {
        Map<String, Object> params = new HashMap<>();
        params.put("address", a);
        Grid g = session.queryForObject(Grid.class, "MATCH (g:Grid{address:$address}) RETURN g LIMIT 1", params);
        return g;
    }

    public final Grid findGridForTile(Tile t) {
        String query = "MATCH (t:Tile)-[:ON_R4GRID]->(g:Grid) WHERE t.addressYear = $param RETURN g";
        Map<String, Object> params = new HashMap<>();
        params.put("addressYear", t.getAddressYear());
        Grid g = session.queryForObject(Grid.class, query, Collections.singletonMap("param", t.getAddressYear()));
        return g;
    }

    @Override
    Class<Grid> getEntityType() {
        return Grid.class;
    }
}
