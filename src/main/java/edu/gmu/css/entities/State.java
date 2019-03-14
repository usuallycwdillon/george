package edu.gmu.css.entities;


import edu.gmu.css.agents.Tile;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.*;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@NodeEntity
public class State extends Polity implements Serializable {
    /**
     *
     */
    @Id
    @GeneratedValue
    private Long id;
    @Property
    private String cowCode;
    @Property
    private String name;

    @Transient
    private double liability = 0;
    @Transient
    private double urbanPortion = 0.20;
    @Transient
    private double treasury = 1000;
    @Transient
    protected Set<Polity> suzereinSet;


    public State() {
    }


    @Override
    public Long getId() {
        return id;
    }

    public String getCowCode() {
        return cowCode;
    }

    public String getName() {
        return name;
    }

    public double getLiability() {
        return liability;
    }

    public double getUrbanPortion() {
        return urbanPortion;
    }

    public Set<Polity> getSuzereinSet() {
        return suzereinSet;
    }

    public void setSuzereinSet(Set<Polity> suzereinSet) {
        this.suzereinSet = suzereinSet;
    }

    public void addSuzerein(Polity suzereign) {
        suzereinSet.add(suzereign);
    }
}
