package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Tile;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.HashMap;
import java.util.Map;

public class TileWeal implements Steppable {

    private Tile tile;
    private Map<Entity, Double> entityPositions; // could be a process or an institution
    private MersenneTwisterFast random;


    public TileWeal() {

    }

    public TileWeal(Tile tile) {
        this.tile = tile;
        entityPositions = new HashMap<>();
        random = new MersenneTwisterFast();
    }


    public void step(SimState simState) {

    }

    public Double considerSupport(Entity e) {
        Double support = 0.0;
        if (entityPositions.containsKey(e)) {
            support = entityPositions.get(e);
            return support;
        } else {
            support = random.nextDouble();
            entityPositions.put(e, support);
            return support;
        }
    }

}
