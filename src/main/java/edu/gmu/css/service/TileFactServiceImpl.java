package edu.gmu.css.service;

import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Fact;
import org.neo4j.ogm.model.Result;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class TileFactServiceImpl extends GenericService<Fact> implements FactService {

    public static void loadTileData(Tile t, int y) {
        Tile tile = t;
        int year = y;
        double pop = 0.0;
        double uPop = 0.0;
        double gtp = 0.0;
        double wea = 0.0;
        double bua = 0.0;

        String pRel = "SIM_POPULATION_" + year;
        String uRel = "SIM_URBAN_POPULATION_" + year;
        String wRel = "SIM_WEALTH_" + year;
        String gRel = "SIM_PRODUCTION_" + year;
        String bRel = "SIM_BUILT_AREA_" + year;

        Map<String, Object> params = new HashMap<>();
        params.put("h3Id", tile.getH3Id());
        params.put("pRel", pRel);
        params.put("uRel", uRel);
        params.put("wRel", wRel);
        params.put("gRel", gRel);
        params.put("bRel", bRel);

        String query = "MATCH (t:Tile{h3Id:$h3Id})-[:$pRel]-(pf:PopulationFact)" +
                "OPTIONAL MATCH (t)-[:$pRel]-(uf:UrbanPopulationFact) " +
                "OPTIONAL MATCH (t)-[:$gRel]-(gf:ProductionFact) " +
                "OPTIONAL MATCH (t)-[:$bRel]-(bf:BuiltAreaFact) " +
                "OPTIONAL MATCH (t)-[:$wRel]-(wf:WealthFact) " +
                "RETURN pf.value AS p, uf.value AS u, gf.value AS g, bf.value AS b";
        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(query, params);

        Iterator it = result.iterator();
        while ( it.hasNext() ) {
            Map<String, Object> item = (Map<String, Object>) it.next();
            pop  = item.get("p")!=null ? ((Double) item.get("p")).doubleValue() : 0.0;
            uPop = item.get("u")!=null ? (Double) item.get("u") : 0.0;
            wea  = item.get("w")!=null ? (Double) item.get("w") : 0.0;
            gtp  = item.get("g")!=null ? ((Double) item.get("g")).doubleValue() : 0.0;
            bua  = item.get("b")!=null ? ((Double) item.get("b")).doubleValue() : 0.0;
        }

        tile.setPopulation(pop);
        tile.setUrbanPopulation(uPop);
        tile.setGrossTileProduction(gtp);
        tile.setBuiltUpArea(bua);
        tile.setWealth(wea);
    }

//    public static void linkTileNeighbors(Tile t) {
//        Tile tile = t;
//        Map<String, Object> params = new HashMap<>();
//        params.put("h3Id", tile.getH3Id());
//
//        String query = "MATCH (t:Tile{h3Id:$h3Id})-[:ABUTS]-(h:Tile) RETURN h";
//        Iterable<Tile> result = Neo4jSessionFactory.getInstance().getNeo4jSession().query(Tile.class, query, params);
//        result.forEach(tile.getNeighbors()::add);
//    }


    @Override
    Class<Fact> getEntityType() {
        return Fact.class;
    }
}
