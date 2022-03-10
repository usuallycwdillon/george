package edu.gmu.css.service;

import com.uber.h3core.H3Core;
import com.uber.h3core.exceptions.DistanceUndefinedException;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.model.Result;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;

public class AttackPathImpl extends GenericService<Tile>{

    public Map<String, Object> findAttackPath(Territory s, Territory t, WorldOrder wo) {
        if(!isAttackGraphLoaded("territoryTiles")) loadTerritoryTilesSubgraph();
        if(!isAttackGraphLoaded("tileLattice")) loadTileLatticeSubgraph();
        String yr = "." + s.getYear();
        Map<String, Object> attackPath = new HashMap<>();
        String[] pathMap = new String[] {"empty"};
        Map<String, String> params = new HashMap<>();
        params.put("start", s.getMapKey());
        params.put("finish", t.getMapKey());
        String q = "MATCH (source:Territory{mapKey:$start}), (target:Territory{mapKey:$finish}) \n" +
                "CALL gds.shortestPath.dijkstra.stream('territoryTiles', {sourceNode:source, targetNode:target}) \n" +
                "YIELD index, path WITH index, nodes(path) AS route, size(nodes(path)) AS len \n" +
                "WITH *, \n" +
                "CASE len \n" +
                "  WHEN 4 THEN [ route[1].address, route[2].address ] \n" +
                "  WHEN 5 THEN [ route[1].address, route[3].address ] \n" +
                "  WHEN 7 THEN [ route[1].address, route[2].address, route[4].address, route[5].address ] \n" +
                "  WHEN 10 THEN  [ route[1].address, route[2].address, route[4].address, route[5].address, route[7].address, route[8].address ] \n" +
                "  ELSE ['tooFar'] END AS waypoints \n" +
                "RETURN waypoints ";
        if (DEBUG) System.out.println("From " + s.getMapKey() + " to " + t.getMapKey());
        Result r = session.query(q,params,true);
        Iterator<Map<String, Object>> rit = r.iterator();
        while (rit.hasNext()) {
            pathMap = (String[]) rit.next().get("waypoints");
        }
        int len = pathMap.length;
        int dist = 3;
        switch (len) {
            case 1:
                String a = this.getRandomTileFromTerritory(s, wo);
                String b = this.getRandomTileFromTerritory(t, wo);
                dist += countTilesBetween(a, b);
                attackPath.put("first", a + yr);
                attackPath.put("last",  b + yr);
                attackPath.put("hops",  dist);
                break;
            case 2:
                attackPath.put("first", pathMap[0] + yr);
                attackPath.put("last" , pathMap[1] + yr);
                attackPath.put("hops" , dist);
                break;
            case 4:
                dist += countTilesBetween(pathMap[1], pathMap[2]);
                attackPath.put("first", pathMap[0] + yr);
                attackPath.put("last" , pathMap[3] + yr);
                attackPath.put("hops" , dist);
                break;
            case 6:
                dist += countTilesBetween(pathMap[1], pathMap[2]);
                dist += countTilesBetween(pathMap[3], pathMap[4]);
                dist += 2;
                attackPath.put("first", pathMap[0] + yr);
                attackPath.put("last" , pathMap[5] + yr);
                attackPath.put("hops" , dist);
                break;
        }
        return attackPath;
    }

    private boolean isAttackGraphLoaded(String g) {
        Result r = session.query("CALL gds.graph.exists($g) YIELD exists", Collections.singletonMap("g",g), true);
        Boolean isThere = (Boolean) r.iterator().next().get("exists");
        return isThere;
    }

    private boolean loadTileLatticeSubgraph() {
        String q = "CALL gds.graph.create('tileLattice', \n" +
                "{Tile:{label:'Tile'},Tile:{label:'Tile'}},\n" +
                "{ABUTS:{type:'ABUTS', orientation:'UNDIRECTED'}}\n" +
                ") YIELD graphName, nodeCount, relationshipCount";
        Result r = session.query(q, Collections.emptyMap(), false);
        return (r.iterator().next().get("graphName").toString() == "tileLattice");
    }

    private String getRandomTileFromTerritory(Territory t, WorldOrder wo) {
        Territory territory = t;
        Tile h;
        if (territory.getPopulatedTileLinks().size() > 0) {
            h = territory.getPopulatedTileLinks().iterator().next();
        } else {
            h = territory.getTileLinks(wo).iterator().next();
        }
        return h.getAddress();
    }

    private boolean loadTerritoryTilesSubgraph() {
        String q = "CALL gds.graph.create(\"territoryTiles\", \n" +
                "{Territory:{label:'Territory'},Tile:{label:'Tile'}},\n" +
                "{INCLUDES:{type:'INCLUDES',orientation:'UNDIRECTED'},ABUTS:{type:'ABUTS', orientation:'UNDIRECTED'}}\n" +
                ") YIELD graphName, nodeCount, relationshipCount;";
        Result r = session.query(q, Collections.emptyMap(), false);
        return (r.iterator().next().get("graphName").toString() == "territoryTiles");
    }

    private int countTilesBetween(String a, String b) {
        int tiles = 2;
        try {
            H3Core h3 = H3Core.newInstance();
            tiles += h3.h3Distance(a, b);
        } catch (Exception e) {
            return tiles;
        }
        return tiles;
    }


    @Override
    Class<Tile> getEntityType() {
        return Tile.class;
    }
}
