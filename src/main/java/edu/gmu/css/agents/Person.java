package edu.gmu.css.agents;

import edu.gmu.css.entities.Entity;
import edu.gmu.css.relations.KnowsRelation;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;
import java.util.stream.Collectors;

@NodeEntity
public class Person extends Entity implements Steppable {

    @Id @GeneratedValue
    private Long id;
    @Property
    private String name;
    @Property
    private String address;
    @Property
    private double bcScore;
    @Property
    private double ecScore;
    @Property
    private boolean leadershipRole;
    @Property
    private String birthplace;
    @Transient
    private double sentiment;
    @Transient
    private Map<Entity, Integer> opinions = new HashMap<>();
    @Relationship(type="KNOWS")
    List<KnowsRelation> circle = new ArrayList<>();


    public Person() {
    }

    public Person(String n) {
        this.name = n;
        this.sentiment = 0.0;
        this.bcScore = 0.0;
        this.leadershipRole = false;
    }


    public void step(SimState simState) {
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return this.name;
    }

    public double getBcScore() {
        return bcScore;
    }

    public void setBcScore(double bcScore) {
        this.bcScore = bcScore;
    }

    public double getEcScore() {
        return ecScore;
    }

    public void setEcScore(double ecScore) {
        this.ecScore = ecScore;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public boolean isLeadershipRole() {
        return leadershipRole;
    }

    public void setLeaderRole(boolean leaderRole) {
        this.leadershipRole = leaderRole;
    }

    public Integer getIssueOpinion(Entity e) {
        return opinions.get(e);
    }

    public void setIssueOpinion(Entity e, int o) {
        opinions.put(e, o);
    }

    public void addIssue(Entity e, int o) {
        opinions.put(e,o);
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBirthplace() {
        return birthplace;
    }

    public void setBirthplace(String birthplace) {
        this.birthplace = birthplace;
    }

    public double getSentiment() {
        return sentiment;
    }

    public void setSentiment(double sentiment) {
        this.sentiment = sentiment;
    }

    public Map<Entity, Integer> getOpinions() {
        return opinions;
    }

    public void setOpinions(Map<Entity, Integer> opinions) {
        this.opinions = opinions;
    }

    public List<Person> getCircle() {
        return circle.stream().map(KnowsRelation::getKnown).collect(Collectors.toList());
    }

    public boolean addToCircle(Person p) {
        this.circle.add(new KnowsRelation(this, p));
        return true;
    }

    public boolean removeFromCircle(Person p) {
        this.circle.remove(p);
        return true;
    }
}
