//package edu.gmu.css.agents;
//
//import edu.gmu.css.worldOrder.*;
//import org.neo4j.ogm.annotation.GeneratedValue;
//import org.neo4j.ogm.annotation.Id;
//import org.neo4j.ogm.annotation.Relationship;
//import sim.engine.SimState;
//
//import java.util.HashSet;
//import java.util.Set;
//
//public class TerritorialPolity {
//
//    /**
//     *
//     */
//    @Id
//    @GeneratedValue
//    private long id;
//    private String stateCode;
//    private String stateName;
//    private int natResources = 500;
//    private double wealth = 500;
//    private int population = 500; // in thousands
//    private int products = 500;
//    private double productivity = 1.05;
//    private double liability = 0;
//    private double urbanPortion = 0.20;
//    private double treasury = 1000;
//
//    private Resources myResources = new Resources.ResourceBuilder()
//            .population(population)
//            .products(products)
//            .natResources(natResources)
//            .wealth(wealth)
//            .build();
//
//    private Territory territory;
//
//
//    @Relationship(type = "OCCUPIES")                                // State can (should) occupy territories
//    private Set<Tile> territories = new HashSet<>();
//
//    @Relationship(type = "BORDERS")                                 // State's neighbors are mediated by territories they occupy
//    private Set<State> neighbors = new HashSet<>();
//
//    @Relationship(type = "PARTICIPATE_IN")                          // States may have wars
//    private Set<War> myWars = new HashSet<>();
//
////    @Relationship(type = "CONFLICT_OVER")                           // States wars are mediated by their conflicts
////    private Set<WarProcess> myWarProcs = new HashSet<>();
////
////    @Relationship(type = "MAKE_PEACE")                              // States can (should) have peace
////    private Set<PeaceProcess> myPeaceProcs = new HashSet<>();
////
////    @Relationship(type = "ENJOY")                                   // States
////    private Set<Peace> myPeace = new HashSet<>();
////
////    @Relationship(type = "BUILD_RELATION")                          // States
////    private Set<DiplomacyProcess> myDipProcs = new HashSet<>();
////
////    @Relationship(type = "MAINTAIN_RELATION")                       // States
////    private Set<Diplomacy> myDiplomacy = new HashSet<>();
////
////    @Relationship(type = "ESTABLISH_TRADE")                         // States
////    private Set<TradeProcess> myTradeProcs = new HashSet<>();
//
//    @Relationship(type = "DO_TRADE")                                // States
//    private Set<Trade> myTrade = new HashSet<>();
//
//    // Neo4j OGM requires a no-argument constructor
//    public TerritorialPolity() {
//    }
//
//
//
//    public void step(SimState simState) {
//        updateResources();
//        updateLiabilities();
////        updateWarStrategy();
////        updateEconomicPolicy();
////        updateForeignPolicy();
//    }
//
//    private void updateLiabilities() {
//        this.liability = myWars.stream().mapToDouble(w -> w.getCostliness()).sum();
//    }
//
//    private void updateResources() {
//        myResources.setPopulation(territories.stream().mapToInt(t -> t.getPopulation()).sum());
//    }
//
//    private double produce() {
//        // quick Cobb-Douglass using wealth ILO capital, population ILO labor, %rural/urban ILO beta/alpha;
//        double production = (productivity * (
//                Math.pow(population, (1 - urbanPortion)) * Math.pow(wealth, urbanPortion)));
//        return production;
//    }
//
//}
