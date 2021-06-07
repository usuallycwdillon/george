package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;
import org.neo4j.ogm.id.IdStrategy;

public class AddressYearStrategy implements IdStrategy {

    public AddressYearStrategy() {

    }

    @Override
    public Object generateId(Object entity) {
        Tile tile = (Tile) entity;
        return tile.getAddressYear();
    }
}
