package edu.gmu.css.entities;


import edu.gmu.css.agents.Tile;
import edu.gmu.css.worldOrder.*;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class State extends Polity implements Serializable {
    /**
     *
     */
    @Id
    @GeneratedValue
    private long id;
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

//    @Transient
//    private Resources myResources = new Resources.ResourceBuilder()
//            .population(population)
//            .wealth(wealth)
//            .build();

    @Relationship(type = "OCCUPIED")                                // State can (should) occupy territories
    private Territory territory;

    @Relationship(type = "BORDERS_WITH")                                 // State's neighbors are mediated by territories they occupy
    private Set<State> bordersWith = new HashSet<>();

//    @Relationship(type = "PARTICIPATE_IN")                          // States may have wars
//    private Set<War> myWars = new HashSet<>();HashSet

//    @Relationship(type = "CONFLICT_OVER")                           // States wars are mediated by their conflicts
//    private Set<WarProcess> myWarProcs = new HashSet<>();
//
//    @Relationship(type = "MAKE_PEACE")                              // States can (should) have peace
//    private Set<PeaceProcess> myPeaceProcs = new HashSet<>();
//
//    @Relationship(type = "ENJOY")                                   // States
//    private Set<Peace> myPeace = new HashSet<>();
//
//    @Relationship(type = "BUILD_RELATION")                          // States
//    private Set<DiplomacyProcess> myDipProcs = new HashSet<>();
//
//    @Relationship(type = "MAINTAIN_RELATION")                       // States
//    private Set<Diplomacy> myDiplomacy = new HashSet<>();
//
//    @Relationship(type = "ESTABLISH_TRADE")                         // States
//    private Set<TradeProcess> myTradeProcs = new HashSet<>();

//    @Relationship(type = "DO_TRADE")                                // States
//    private Set<Trade> myTrade = new HashSet<>();

    // Neo4j OGM requires a no-argument constructor
    public State() {
    }



//    private void updateLiabilities() {
//        this.liability = myWars.stream().mapToDouble(w -> w.getCostliness()).sum();
//    }

//    private void updateResources() {
//        myResources.setPopulation(territories.stream().mapToInt(t -> t.getPopulation()).sum());
//    }






}
