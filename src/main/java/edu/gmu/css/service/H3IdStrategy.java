package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;
import org.neo4j.ogm.id.IdStrategy;

public class H3IdStrategy implements IdStrategy {

    @Override
    public Object generateId(Object entity) {
        Tile tile = (Tile) entity;
        return tile.getAddress();
    }
}
