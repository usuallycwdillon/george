package edu.gmu.css.entities;


import edu.gmu.css.agents.Tile;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.relations.Inclusion;
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
public class State extends Polity implements Steppable {
    /**
     *
     */
    @Id
    @GeneratedValue
    private Long id;
    @Property
    private String cowcode;
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

    public void step(SimState simState) {
        Long step = simState.schedule.getSteps();
        weeklyExpense(step);
        collectTax();
        recruit();
    }


    @Override
    public Long getId() {
        return id;
    }

    public String getCowCode() {
        return cowcode;
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


    @Override
    protected void recruit(int cohort) {

    }

    @Override
    protected void recruit() {
        int requirement = resources.getPax() - securityStrategy.getPax();
        if (requirement < 0) {
            int weekly = (requirement * -1) / 52;
            double share = weekly / (territory.getTileLinks().size() * 1.0);
            int recruits = (int) Math.round(share);
            for (Inclusion i : territory.getTileLinks()) {
                Tile t = i.getTile();
                if (t.getPopulation() - recruits > 0) {
                    t.setPopulation(t.getPopulation() - recruits);
                    resources.addPax(recruits);
                } else {
                    resources.addPax(t.getPopulation());
                    t.setPopulation(0);
                }
            }
        }
    }

    private void weeklyExpense(Long step) {
        double expenses = resources.getTreasury() / WorldOrder.annum.getWeeksThisYear();
        resources.subtractTreasury(expenses);
    }

    @Override
    protected void collectTax() {
        Resources revenue = new Resources.ResourceBuilder().build();
        for (Inclusion i : territory.getTileLinks()) {
            revenue.addTreasury(i.getTile().payTaxes());
        }
        // if the weekly revenue is greater than 1.07 x a week's worth of budget, decrease the tax
        if ((revenue.getTreasury() * 1.07) > (resources.getTreasury() / (WorldOrder.annum.getWeeksThisYear() - 1))) {
            for (Inclusion i : territory.getTileLinks()) {
                i.getTile().setTaxRate(i.getTile().getTaxRate() * 0.9);
            }
        }
        // or adjust it up if it's not high enough
        if (revenue.getTreasury() < ((resources.getTreasury() * 1.01) / (WorldOrder.annum.getWeeksThisYear() - 1))) {
            for (Inclusion i : territory.getTileLinks()) {
                i.getTile().setTaxRate(i.getTile().getTaxRate() * 0.9);
            }
        }
    }

    @Override
    public boolean getPolityData(int year) {
        DiscretePolityFact dpf = StateQueries.getPolityData(this, year);
        if (dpf != null) {
            polityFact = dpf;
            return true;
        } else {
            return false;
        }
    }


}
