package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Person;
import edu.gmu.css.util.MTFWrapper;
import edu.gmu.css.worldOrder.WorldOrder;
import org.jgrapht.Graph;
import org.jgrapht.alg.scoring.BetweennessCentrality;
import org.jgrapht.generate.WattsStrogatzGraphGenerator;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.util.SupplierUtil;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;
import java.util.function.Supplier;

public class TerritorialWeal implements Steppable {

    private String name;
    private int size = 1000;
    private Territory territory;
    private Map<Entity, Double> entityPosition;
    private Map<String, Person> personMap;
    private Graph<String, DefaultEdge> graph;
    private MTFWrapper random = new MTFWrapper(WorldOrder.modelRun.getSeed()); // JGraphT requires an implementation of Java's util.Random class
    private Supplier<String> vSupplier = new Supplier<String>() {
        private int id = 0;
        @Override
        public String get() {
            String nodeId = "v" + id++;
            personMap.put(nodeId, new Person(nodeId));
            return nodeId;
        }
    };

    private WattsStrogatzGraphGenerator<String, DefaultEdge> wsg = new WattsStrogatzGraphGenerator<> (
            size, 4, 0.33, true, random);


    public TerritorialWeal() {

    }

    public TerritorialWeal(Territory t, boolean newGraph) {
        this.territory = t;
        this.entityPosition = new HashMap<>();
        this.personMap = new HashMap<>();
        this.name = t.getName() + "_weal";
        if (newGraph) {
            graph = newGraph(t);
            getBetweenness();
        }
//        System.out.println("Graphs and betweenness is calculated...");
    }


    public void step(SimState simState) {

    }

    public Double gaugeSupport(Entity e) {
        Double support = random.nextDouble();
        entityPosition.put(e, support);
        return support;
    }

    public Graph newGraph(Territory t) {
        Graph<String, DefaultEdge> localGraph = new SimpleGraph<>(
                vSupplier, SupplierUtil.createDefaultEdgeSupplier(), false);
        wsg.generateGraph(localGraph);
        return localGraph;
    }

    public void getBetweenness() {
        BetweennessCentrality bc = new BetweennessCentrality(graph);
        Map<String, Double> betweennessScores = bc.getScores();
        for (Map.Entry<String, Double> e : betweennessScores.entrySet()) {
            Person p = personMap.get(e.getKey());
            p.setBcScore(e.getValue());
        }
    }

    public static <K, V extends Comparable<? super V>> Map<K, V> sortByValue(Map<K, V> map, int n) {
        List<Map.Entry<K, V>> list = new ArrayList<>(map.entrySet());
        list.sort(Map.Entry.comparingByValue());
        Collections.reverse(list);
        Map<K, V> result = new LinkedHashMap<>();
        for (Map.Entry<K, V> entry : list.subList(0, n)) {
            result.put(entry.getKey(), entry.getValue());
        }
        return result;
    }

}
