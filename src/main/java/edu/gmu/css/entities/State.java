package edu.gmu.css.entities;


import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Issue;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.relations.AllianceParticipation;
import edu.gmu.css.relations.DiplomaticRepresentation;
import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.*;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.awt.*;
import java.io.Serializable;
import java.util.*;

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

    public void addSuzerein(Polity suzerein) {
        suzereinSet.add(suzerein);
    }


    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        Long step = worldOrder.schedule.getSteps();

        // distribute resources
        // Pay military the weekly expense
        System.out.println(name + " in step " + worldOrder.getStepNumber());
        resources.subtractTreasury(resources.getTreasury() / worldOrder.dataYear.getWeeksThisYear());
        // TODO: fund Institutions
        // TODO: Invest back into territories

        // collect resources
        adjustTaxRate(worldOrder);
        collectTax();
        recruit();
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


    @Override
    // TODO: Rewire this to consider current resources + (future income - future expenses)
    protected void adjustTaxRate(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Resources revenue = new Resources.ResourceBuilder().build();
//        for (Inclusion i : territory.getTileLinks()) {
//            revenue.addTreasury(i.getTile().payTaxes());
//        }
        // if the weekly revenue is greater than 1.07 x a week's worth of budget, decrease the tax
        if ((revenue.getTreasury() * 1.07) > (resources.getTreasury() / (worldOrder.dataYear.getWeeksThisYear()))) {
            for (Inclusion i : territory.getTileLinks()) {
                i.getTile().setTaxRate(i.getTile().getTaxRate() * 0.9);
            }
        }
        // or adjust it up if it's not high enough
        if (revenue.getTreasury() < ((resources.getTreasury() * 1.01) / (worldOrder.dataYear.getWeeksThisYear()))) {
            for (Inclusion i : territory.getTileLinks()) {
                i.getTile().setTaxRate(i.getTile().getTaxRate() * 0.9);
            }
        }
    }

    @Override
    public boolean findPolityData(int year) {
        DiscretePolityFact dpf = StateQueries.getPolityData(this, year);
        if (dpf != null) {
            polityFact = dpf;
            // setup leadership from common weal using polity data facts
//            TODO : List<String> leaders = territory.commonWeal.sortByValue(territory.commonWeal., leadershipSize);
            return true;
        } else {
            // setup leadership from common weal using 5/5 as polity data
            setNeutralPolityFact();
            return false;
        }
    }

    @Override
    public boolean evaluateWarNeed(SimState simState, Issue i) {
        // The polity has a new Issue (Change occurs) and must decide whether they perceive a need to take action. Conceptually,
        // the ProbabilisticCausality agent creates the issue and the ProcessDisposition directly, and the ProcessDisposition
        // contains the logic about whether the polity perceives a need to take military action over the new Issue. In
        // practical terms, we would have to create a Process and a ProcessDisposition (because the ProcessDisposition is
        // a Neo4j relationship and it must know both of its endpoints at creation time); and the Issue may not result in
        // a new Process after all. For convenience, the first step of the conflict logic is inside this method.
        WorldOrder worldOrder = (WorldOrder) simState;
        Issue issue = i;
        i.setStopper(worldOrder.schedule.scheduleRepeating(i));
        Polity t = issue.getTarget();

        for (DiplomaticRepresentation r : representedAt) {
            if (r.getInstitution().isParticipant(t)) {
                System.out.println("Evaluating war need with " + t.getTerritory().getName() + " with whom " + name + " has dip relations.");
            }
        }

        // TODO: Do leadership and population of p agree on need N for military action to address issue?
        // TODO: Needs some functionality to incorporate Polity IV data (leadership's weal vs the common weal) to balance
        //  calculation. ...the question may belong better in the transmission of opinions between leadership and common weal
        if (leadership.evaluateWarNeed(i) + territory.commonWeal.evaluateWarNeed(i) > 1.0) {
            WarProcess proc = leadership.initiateWarProcess(t, worldOrder);
            proc.setIssue(i);
            worldOrder.addProc(proc);
            Stoppable stoppable = worldOrder.schedule.scheduleRepeating(proc);
            proc.setStopper(stoppable);
            ProcessDisposition pd = new ProcessDisposition(this, proc, worldOrder.getStepNumber());
            // The process would not have begun if the domestic need for war had not been realized/perceived.
            pd.setN(true);
            this.addProcess(pd);
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean evaluateWarWillingness(ProcessDisposition pd) {
        return leadership.evaluateWarWillingness(pd) && territory.commonWeal.evaluateWarWillingness(pd);
    }

    @Override
    public void collectTax() {
        double revenue = 0.0;
        for (Inclusion i : territory.getTileLinks()) {
            revenue += i.getTile().payTaxes();
        }
        this.resources.addTreasury(revenue);
    }

}
