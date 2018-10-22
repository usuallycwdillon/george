package edu.gmu.css.service;

import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.core.IMap;
import edu.gmu.css.entities.Territory;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class TerritoryCacheService {

    private HazelcastInstance hazelcastInstance;
    private IMap<String, Territory> territories;

    public TerritoryCacheService(HazelcastInstance hazelcastInstance) {
        this.hazelcastInstance = hazelcastInstance;
    }

    public void init() {
        territories = hazelcastInstance.getMap("territories");
    }

    public Territory getTerritory(String name) {
        return territories.get(name);
    }

    public void addTerritory(Territory territory) {
        territories.set(territory.getName(), territory);
    }

    public void addTerritories(Collection<Territory> territoryCollection) {
        Map<String, Territory> localTerritories = new HashMap<>();
        for (Territory territory : territoryCollection) {
            localTerritories.put(territory.getName(), territory);
        }
        territories.putAll(localTerritories);
    }

    public void updateTerritory(Territory territory) {
        territories.put(territory.getName(), territory);
    }

    public void deleteTerritory(Territory territory) {
        territories.delete(territory.getName());
    }

}
