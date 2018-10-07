package edu.gmu.css.service;

import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.core.IMap;
import edu.gmu.css.agents.Tile;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class TileCacheService {

    private HazelcastInstance hazelcastInstance;
    private IMap<String, Tile> globalHexes;

    public TileCacheService(HazelcastInstance hazelcastInstance) {
        this.hazelcastInstance = hazelcastInstance;
    }

    public void init() {
        globalHexes = hazelcastInstance.getMap("globalHexes");
    }

    public Tile getTile(String address) {
        return globalHexes.get(address);
    }

    public void addTile(Tile tile) {
        globalHexes.put(tile.getAddress(), tile);
    }

    public void addTiles(Collection<Tile> tileCollection) {
        Map<String, Tile> localTiles = new HashMap<>();
        for (Tile tile : tileCollection) {
            localTiles.put(tile.getAddress(), tile);
        }
        globalHexes.putAll(localTiles);
    }

    public void updateTile(Tile tile) {
        globalHexes.put(tile.getAddress(), tile);
    }

    public void deleteTile(Tile tile) {
        globalHexes.delete(tile.getAddress());
    }

}
