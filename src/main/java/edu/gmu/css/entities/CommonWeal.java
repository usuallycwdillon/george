package edu.gmu.css.entities;

import edu.gmu.css.agents.Person;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.util.MTFWrapper;
import edu.gmu.css.worldOrder.WorldOrder;
import org.jgrapht.Graph;
import org.jgrapht.alg.connectivity.ConnectivityInspector;
import org.jgrapht.alg.scoring.BetweennessCentrality;
import org.jgrapht.generate.WattsStrogatzGraphGenerator;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.util.SupplierUtil;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;
import java.util.function.Supplier;

public class CommonWeal implements Steppable {

    private String name;
    private int size = 1000;
    private Territory territory;
    private Map<Entity, Double> entityPosition;
    private Map<String, Person> personMap;
    private Graph<String, DefaultEdge> graph;
    private MTFWrapper random = new MTFWrapper(WorldOrder.getSeed()); // JGraphT requires an implementation of Java's util.Random class
    private WattsStrogatzGraphGenerator<String, DefaultEdge> wsg;
    private Supplier<String> vSupplier;
    private double rebel = 0.002;
    public ConnectivityInspector<String, DefaultEdge> inspector;


    public CommonWeal() {

    }

    public CommonWeal(Territory t, boolean newGraph) {
        this.territory = t;
        this.entityPosition = new HashMap<>();
        this.personMap = new HashMap<>();
        this.name = t.getName() + "_weal";

        if (newGraph) {
            wsg = new WattsStrogatzGraphGenerator<> (
                    size, 4, 0.33, true, random);
            vSupplier = new Supplier<String>() {
                private int id = 0;
                @Override
                public String get() {
                    String nodeId = "v" + id++;
                    personMap.put(nodeId, new Person(nodeId));
                    return nodeId;
                }
            };
            graph = newGraph(t);

            calculateBetweenness();
        }
    }


    public void step(SimState simState) {

    }


    public Double evaluateWarNeed(Entity e) {
        // TODO: Change this from returning a random value to the average support after a week of public deliberation.
        //  The common weal basically asks: can we afford this issue (in people or resources)?
        Double support = random.nextDouble();
        entityPosition.put(e, support);
        return support;
    }

    public boolean evaluateWarWillingness(ProcessDisposition pd) {
        // TODO: Change this from return ing a random value to returning the average support for the Institution/Process
        //  after a week of deliberation. Now that the State/Polity has asked for taxes/recruits, is the common weal willing?
        return entityPosition.get(pd.getSubject()) > 0.34;
    }

    public Graph<String, DefaultEdge> newGraph(Territory t) {
        Graph<String, DefaultEdge> localGraph = new SimpleGraph<>(
                vSupplier, SupplierUtil.createDefaultEdgeSupplier(), false);
        wsg.generateGraph(localGraph);
        return localGraph;
    }

    public void calculateBetweenness() {
        BetweennessCentrality<String, DefaultEdge> bc = new BetweennessCentrality<>(graph);
        Map<String, Double> betweennessScores = bc.getScores();
        for (Map.Entry<String, Double> e : betweennessScores.entrySet()) {
            Person p = personMap.get(e.getKey());
            p.setBcScore(e.getValue());
        }
        Polity p = territory.getPolity();
        int leadershipSize = (p.getPolityFact().getAutocracyRating() * 10) + 1; // between 1 and 101
        Set<String> leaderIds = sortByValue(betweennessScores, leadershipSize).keySet();
        Map<String, Person> leaders = new HashMap<>();
        for (String s : leaderIds) {
            Person l = personMap.get(s);
            leaders.put(s,l);
            l.setLeaderRole(true);
        }
        p.getLeadership().setLeaders(leaders);
    }

    public void addIssue(Entity e, double d) {
        // TODO: make this dependent on person's territorial economic history for costs and population growth for wars
        double neutral = ((1.0 - d) * 0.5) + d;
        entityPosition.put(e, d);

        for (Person p : personMap.values()) {
            double r = random.nextDouble();
            if (r < d) {
                p.addIssue(e,1);
            } else if (r < neutral) {
                p.addIssue(e,0);
            } else {
                p.addIssue(e,-1);
            }
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

    public double getAvgSupport(Entity e) {
        double tally = 0.0;
        for (Person p : personMap.values()) {
            tally += p.getIssueOpinion(e);
        }
        double avg = tally / personMap.size();
//        long pros = personMap.values().stream().filter(p -> p.getIssueOpinion(i)==1).count();
//        long cons = personMap.values().stream().filter(person -> person.getIssueOpinion(i).equals(-1)).count();
//        long neuts = personMap.values().stream().filter(person -> person.getIssueOpinion(i).equals(0)).count();
//        System.out.println("Tile: " + name + ", issue: " + i.getId() + ":: pros: " + pros + "; cons: " + cons + "; neuts: " +
//                neuts + " -- average " + avg);
        return avg;
    }

    public void shareOpinion() {
        for (Map.Entry<Entity, Double> entry : entityPosition.entrySet()) {
            Entity e = entry.getKey();
            for (int days=0; days<7;days++) {
                for (Person p : personMap.values()) {
                    int po = p.getIssueOpinion(e);
                    double r = random.nextDouble();
                    if (r < rebel) {
                        int neighborhood = 0;
                        for (String v : inspector.connectedSetOf(p.getName())) {
                            Person target = personMap.get(v);
                            // TODO mitigate opinion sharing to leaders when democracy score is low
                            int to = target.getIssueOpinion(e);
                            neighborhood += to;
                        }
                        if (po < 0 && neighborhood > 0) {
                            p.setIssueOpinion(e, 0);
                        } else if (po == 0 && neighborhood < 0) {
                            p.setIssueOpinion(e, -1);
                        } else if (po == 0 && neighborhood > 0) {
                            p.setIssueOpinion(e, 1);
                        } else if (po > 0 && neighborhood < 0) {
                            p.setIssueOpinion(e, 0);
                        }
                        // otherwise, things stay the same
                    }
                }
            }
            entry.setValue(getAvgSupport(e));
        }
    }

}
