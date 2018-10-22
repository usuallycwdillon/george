package edu.gmu.css.hexFactory;

import edu.gmu.css.entities.Territory;
import org.geojson.Feature;



import java.io.Serializable;

public class CreateTerritoryTask implements Serializable, Runnable {
    private final Feature feature;
    private final int resolution;
    private final Territory territory;

    public CreateTerritoryTask(Territory t, Feature thisFeature, int resolution) {
       this.feature = thisFeature;
       this.resolution = resolution;
       this.territory = t;
    }

    @Override
    public void run() {
        try {
            territory.buildTerritory(feature);
            Thread.sleep(50);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
