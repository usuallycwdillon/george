package edu.gmu.css.service;

import edu.gmu.css.entities.Territory;
import org.neo4j.ogm.id.IdStrategy;

public class NameIdStrategy implements IdStrategy {

    public NameIdStrategy() {
    }

    @Override
    public String generateId(Object entity) {
        Territory territory = (Territory) entity;
        return territory.getMapKey();
    }
}
