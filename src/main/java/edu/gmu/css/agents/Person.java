package edu.gmu.css.agents;

import edu.gmu.css.entities.Entity;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.HashMap;
import java.util.Map;

public class Person extends Entity implements Steppable {

    private String name;
    private String homeTile;
    private double sentiment;
    private double bcScore;
    private boolean leaderRole;
    private Map<Entity, Integer> opinions = new HashMap<>();


    public Person() {
    }

    public Person(String n) {
        this.name = n;
        this.sentiment = 0.0;
        this.bcScore = 0;
        this.leaderRole = false;
    }


    public void step(SimState simState) {
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

    public String getHomeTile() {
        return homeTile;
    }

    public void setHomeTile(String homeTile) {
        this.homeTile = homeTile;
    }

    public boolean isLeaderRole() {
        return leaderRole;
    }

    public void setLeaderRole(boolean leaderRole) {
        this.leaderRole = leaderRole;
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
}
