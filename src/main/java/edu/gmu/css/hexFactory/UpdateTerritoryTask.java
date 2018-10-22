package edu.gmu.css.hexFactory;

import edu.gmu.css.entities.Territory;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.geojson.Feature;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;


import java.io.Serializable;

public class UpdateTerritoryTask implements Runnable, Serializable {

    private final Territory t;
    private final Feature feature;


    public UpdateTerritoryTask(Territory t, Feature thisFeature) {
        this.t = t;
        this.feature = thisFeature;
    }

    @Override
    public void run() {
        if (t.getName().equals(null)) {System.out.println("this name is null");}
        System.out.println("...and we seem to have a key match on " + t.getName() + " in the territories map...");
        try {
            t.updateOccupation(feature);
            Thread.sleep(50);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Updated " + t.getName() + " with more hexes.");
    }
}
