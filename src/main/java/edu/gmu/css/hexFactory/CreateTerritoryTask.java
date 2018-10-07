package edu.gmu.css.hexFactory;

import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.Feature;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;


import java.io.Serializable;

public class CreateTerritoryTask implements Serializable, Runnable {

    private final Territory territory;
    private final Feature feature;
    private final String name;
    private final int resolution;
    private final int year;

    public CreateTerritoryTask(Territory t, Feature thisFeature, String name, int resolution, int year) {
       this.territory = t;
       this.feature = thisFeature;
       this.name = name;
       this.resolution = resolution;
       this.year = year;
    }

    @Override
    public void run() {
        try {
            Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();
            Transaction tx = session.beginTransaction();

            territory.buildTerritory(feature, name, resolution, year);

            session.save(territory);
            tx.commit();
            session.clear();
            Thread.sleep(50);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
