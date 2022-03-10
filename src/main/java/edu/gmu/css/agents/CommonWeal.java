package edu.gmu.css.agents;

import edu.gmu.css.entities.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.LeadershipServiceImpl;
import edu.gmu.css.service.PersonServiceImpl;
import edu.gmu.css.util.MTFWrapper;
import edu.gmu.css.worldOrder.WorldOrder;
import org.jgrapht.Graph;
import org.jgrapht.alg.connectivity.ConnectivityInspector;
import org.jgrapht.alg.scoring.AlphaCentrality;
import org.jgrapht.alg.scoring.BetweennessCentrality;
import org.jgrapht.generate.WattsStrogatzGraphGenerator;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.util.SupplierUtil;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;
import java.util.function.Supplier;
import java.util.stream.Collectors;

@NodeEntity
public class CommonWeal extends Entity implements Steppable {

    @Id @GeneratedValue
    private Long id;
    @Property
    private String name;
    @Transient
    private int size;
    @Transient
    private Map<Entity, Double> entityPosition = new HashMap<>();
    @Transient
    private Graph<String, DefaultEdge> graph;
    @Transient
    private MTFWrapper random = new MTFWrapper(WorldOrder.getSeed()); // JGraphT requires an implementation of Java's util.Random class
    @Transient
    private WattsStrogatzGraphGenerator<String, DefaultEdge> wsg;
    @Transient
    private Supplier<String> vSupplier;
    @Transient
    private double rebel = 0.002;
    @Transient
    public ConnectivityInspector<String, DefaultEdge> inspector;
    @Relationship(type="REPRESENTS_POPULATION")
    private Territory territory;
    @Relationship(type="RESIDES_IN", direction = Relationship.INCOMING)
    private List<Person> personList = new ArrayList<>();
    @Relationship(type="LEADERSHIP_FROM", direction = Relationship.INCOMING)
    private Leadership leadership;
    @Transient
    private Map<String, Person> personMap;


    public CommonWeal() {

    }

    public CommonWeal(Territory t, boolean newGraph) {
        this.territory = t;
        this.entityPosition = new HashMap<>();
        this.personMap = new HashMap<>();
        this.name = "Residents of " + t.getName();

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

    @PostLoad
    public void getPeople() {
        this.personList.addAll(new PersonServiceImpl().loadAll(name.split("of ",2)[1]));
        this.personList.stream().forEach(p -> p.setCommonWeal(this) );
        this.leadership = new LeadershipServiceImpl().getCommonWealLeadership(this);
        this.loadPersonMap();
    }


    @Override
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
        return entityPosition.get(pd.getProcess().getIssue()) > 0.40;
    }


    public Double evaluateNeedForPeace(WarParticipationFact f) {
        War war = f.getWar();
        Double support = random.nextDouble();
        entityPosition.put(war, support);
        return support;
    }

    public Double evaluatePeaceWillingess(WarParticipationFact f) {
        return entityPosition.get(f.getWar());
    }

    public void addIssue(Issue i, WorldOrder wo) {
        Issue issue = i;
        WorldOrder worldOrder = wo;
        double neutral = (territory.getSatisfaction() / 2.0) + 0.17; // between 17-67% pop is ambivalent
        double pro = ((1.0 - neutral) * (worldOrder.random.nextDouble() / 2.0) ) + neutral;
        double o;
        for (Person p : personMap.values()) {
            if (p.isLeadershipRole()) {
                o = leadership.takeInformedRandomOpinion(issue, worldOrder);
            } else {
                o = worldOrder.random.nextDouble();
            }
            if (o > pro) {
                p.addIssue(issue,1);
            } else if (o < neutral) {
                p.addIssue(issue,-1);
            } else {
                p.addIssue(issue,0);
            }
        }
        this.socialize(issue, worldOrder);
        entityPosition.put(issue, getAvgSupport(issue));
    }

    public void addWar(War w, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        War war = w;
        for (WarParticipationFact f : war.getParticipations()) {
            if (f.getPolity().equals(this.getTerritory().getPolity())) {
                for (Person p : personMap.values()) {
                    int o = p.takeWarOpinion(f);
                    p.addIssue(w, o);
                }
            }
        }
        this.socialize(war, worldOrder);
        entityPosition.put(war, getAvgSupport(war));
    }

    public double getAvgSupport(Entity e) {
        Entity i = e;
        String name;
        double tally = 0.0;
        for (Person p : personMap.values()) {
            tally += p.getIssueOpinion(i);
        }
        if (i.getClass().equals(Issue.class)) {
            name = ((Issue) i).getFact().getName();
        } else {
            name = "unk cause";
        }

        double avg = tally / personList.size();
//        if(DEBUG) {
//            long pros = personMap.values().stream().filter(p -> p.getIssueOpinion(i)==1).count();
//            long cons = personMap.values().stream().filter(person -> person.getIssueOpinion(i).equals(-1)).count();
//            long neuts = personMap.values().stream().filter(person -> person.getIssueOpinion(i).equals(0)).count();
//            System.out.println("issue: " + name + ":: pros: " + pros + "; cons: " + cons +
//                    "; neuts: " + neuts + " -- average " + avg);
//        }
        return avg;
    }

    public void socialize(Entity e, WorldOrder wo) {
        Entity entity = e;
        WorldOrder worldOrder = wo;
        double openness = worldOrder.random.nextDouble();
        if (entityPosition.containsKey(entity)) {
            for (int i=0;i<7;i++) {
                for (Person p : personMap.values()) {
                    p.shareOpinion(entity, worldOrder);
                }
            }
        }
        entityPosition.put(entity, getAvgSupport(entity));
    }


    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Leadership getLeadership() {
        if (leadership!=null) {
            return leadership;
        } else {
            leadership = new LeadershipServiceImpl().getCommonWealLeadership(this);
            return leadership;
        }
    }

    public Map<String, Person> findLeaders() {
        Map<String, Person> leaderMap = new HashMap<>();
        for (Person p : personList) {
            if(p.isLeadershipRole()) leaderMap.put(p.getName(), p);
        }
        return leaderMap;
    }

    public void setLeadership(Leadership leadership) {
        this.leadership = leadership;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public Map<Entity, Double> getEntityPositionMap() {
        return entityPosition;
    }

    public void setEntityPositionMap(Map<Entity, Double> entityPosition) {
        this.entityPosition = entityPosition;
    }

    public Graph<String, DefaultEdge> getGraph() {
        return graph;
    }

    public void setGraph(Graph<String, DefaultEdge> graph) {
        this.graph = graph;
    }

    public MTFWrapper getRandom() {
        return random;
    }

    public void setRandom(MTFWrapper random) {
        this.random = random;
    }

    public WattsStrogatzGraphGenerator<String, DefaultEdge> getWsg() {
        return wsg;
    }

    public double getRebel() {
        return rebel;
    }

    public void setRebel(double rebel) {
        this.rebel = rebel;
    }

    public ConnectivityInspector<String, DefaultEdge> getInspector() {
        return inspector;
    }

    public Territory getTerritory() {
        return territory;
    }

    public void setTerritory(Territory territory) {
        this.territory = territory;
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

    public void calculateEigenValues() {
        AlphaCentrality<String, DefaultEdge> ec = new AlphaCentrality<>(graph);
        Map<String, Double> eigenvalues = ec.getScores();
        for (Map.Entry<String, Double> e : eigenvalues.entrySet()) {
            Person p = personMap.get(e.getKey());
            p.setEcScore(e.getValue());
        }
        Polity p = territory.getPolity();
        int leadershipSize = (p.getPolityFact().getAutocracyRating() * 10) + 1; // between 1 and 101
        Set<String> leaderIds = sortByValue(eigenvalues, leadershipSize).keySet();
        Map<String, Person> leaders = new HashMap<>();
        for (String s : leaderIds) {
            Person l = personMap.get(s);
            leaders.put(s,l);
            l.setLeaderRole(true);
        }
        p.getLeadership().setLeaders(leaders);
    }

    public void loadPersonMap() {
        if(personList == null || personList.size() == 0) {
            this.personList = new ArrayList<>(new PersonServiceImpl().loadAll(territory.getMapKey()));
        }
        personMap = personList.stream().collect(Collectors.toMap(Person::getName, a -> a));
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


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CommonWeal)) return false;
        if (!super.equals(o)) return false;

        CommonWeal that = (CommonWeal) o;

        if (!getId().equals(that.getId())) return false;
        return getName().equals(that.getName());
    }

    @Override
    public int hashCode() {
        int result = getId().hashCode();
        result = 31 * result + getName().hashCode();
        return result;
    }
}
