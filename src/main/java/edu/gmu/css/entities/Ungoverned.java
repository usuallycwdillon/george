package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import sim.engine.SimState;
import sim.engine.Steppable;

@NodeEntity
public class Ungoverned extends Polity implements Steppable {
    @Id
    @GeneratedValue
    private Long id;


    public Ungoverned() {

    }

    public Ungoverned(Territory t) {
        this.territory = t;
    }

    public void step(SimState simState) {

    }

    public Long getId() {
        return this.id;
    }

}
