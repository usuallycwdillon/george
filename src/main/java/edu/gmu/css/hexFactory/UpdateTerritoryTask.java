package edu.gmu.css.hexFactory;

import edu.gmu.css.entities.Territory;
import org.geojson.Feature;


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
//        try {
//            t.updateOccupation(feature);
//            Thread.sleep(50);
//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        }
        System.out.println("Updated " + t.getName() + " with more hexes.");
    }
}
