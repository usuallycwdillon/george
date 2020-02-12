package edu.gmu.css.queries;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Fact;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.neo4j.ogm.model.Result;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class TileQueries {

    public int findPopulation(Tile t, int y) {
        int pop = 0;
        Map<String, Object> params = new HashMap<>();
        params.put("h3Id", t.getH3Id());
        params.put("year", y);
        String query = "MATCH (t:Tile{h3Id:$h3Id})-[:SIM_POPULATION{during:$year}]-(f:Fact) RETURN f ";
        Fact f = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, query, params);
        pop = (Integer) f.getValue();
        return pop;
    }

    public int findUrbanPop(Tile t, int y) {
        int uPop = 0;
        Map<String, Object> params = new HashMap<>();
        params.put("h3Id", t.getH3Id());
        params.put("year", y);
        String query = "MATCH (t:Tile{h3Id:$h3Id})-[:SIM_URBAN_POPULATION{during:$year}]-(f:Fact) RETURN f ";
        Fact f = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, query, params);
        uPop = (Integer) f.getValue();
        return uPop;
    }

    public Double findWealth(Tile t, int y) {
        double wealth = 0;
        Map<String, Object> params = new HashMap<>();
        params.put("h3Id", t.getH3Id());
        params.put("year", y);
        String query = "MATCH (t:Tile{h3Id:$h3Id})-[:SIM_WEALTH{during:$year}]-(f:Fact) RETURN f ";
        Fact f = Neo4jSessionFactory.getInstance().getNeo4jSession().queryForObject(Fact.class, query, params);
        wealth = (Double) f.getValue();
        return wealth;
    }

    public static void loadTileData(Tile t, int y) {
        Tile tile = t;
        int year = y;
        int pop = 0;
        int uPop = 0;
        double wealth= 0;

        String pRel = "SIM_POPULATION_" + year;
        String uRel = "SIM_URBAN_POPULATION_" + year;
        String wRel = "SIM_WEALTH_" + year;

        Map<String, Object> params = new HashMap<>();
        params.put("h3Id", tile.getH3Id());

        String query = "MATCH (t:Tile{h3Id:$h3Id})-[:" + pRel + "]-(pf:Fact), (t)-[:" + uRel + "]-(uf:Fact), " +
                       "(t)-[:" + wRel + "]-(wf:Fact) RETURN pf.value AS p, uf.value AS u, wf.value AS w";
        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, params);

        Iterator it = result.iterator();
        while ( it.hasNext() ) {
            Map<String, Object> item = (Map<String, Object>) it.next();
            pop = item.get("p")!=null ? ((Number) item.get("p")).intValue() : 0;
            uPop = item.get("u")!=null ? ((Number) item.get("u")).intValue() : 0;
            wealth = item.get("w")!=null ? ((Number) item.get("w")).doubleValue() : 0.0;
        }

        tile.setPopulation(pop);
        tile.setUrbanization(uPop);
        tile.setWealth(wealth);

        // weal
//        this.weal = new TileWeal(this);

    }




}
