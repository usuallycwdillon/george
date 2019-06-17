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


    public Person() {
    }

    public Person(String n) {
        this.name = n;
        this.sentiment = 0.0;
        this.bcScore = 0;
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
}
