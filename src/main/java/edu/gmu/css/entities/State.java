package edu.gmu.css.entities;


import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Issue;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.data.World;
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
//        Long step = worldOrder.schedule.getSteps();
//        System.out.println(name + " in step " + worldOrder.getStepNumber());
        // distribute resources
        // Pay military the weekly expense
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
        long step = worldOrder.getStepNumber();
        Issue issue = i;
        Polity t = issue.getTarget();
//        // Not used, yet
//        for (DiplomaticRepresentation r : representedAt) {
//            if (r.getInstitution().isParticipant(t)) {
//                System.out.println("Evaluating war need with " + t.getTerritory().getName() + " with whom " + name + " has dip relations.");
//            }
//        }
        if (evalRandomStateResolve(issue)) {                                            // 1.3
            WarProcess proc = new WarProcess(issue, step);                              // 2.0
            issue.setProcess(proc);                                                     // 2.1
            worldOrder.addProc(proc);                                                   // 2.2
            proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));               // 2.3

            // link the this state to the process and prepare security strategy
            ProcessDisposition pdo = new ProcessDisposition(this, proc, step);    // 3.0
            SecurityObjective so = leadership.chooseSecurityObjective(issue);           // 3.1
            pdo.setObjective(so);                                                       // 3.2
            Resources warStrategy = warStrategy(t,so,worldOrder);                       // 3.3
            pdo.commit(warStrategy);                                                    // 3.4
            pdo.setSide(0);                                                             // 3.5
            pdo.setN(true);                                                             // 3.6
            this.addProcess(pdo);                                                       // 3.7
            proc.addProcessParticipant(pdo);                                            // 3.8
            militaryStrategy.increaseBy(warStrategy);                                   // 3.9
            // TODO: There is surely some housekeeping here to adjust the securityStrategy to include this committment

            // link the target to the process
            ProcessDisposition pdt = new ProcessDisposition(t, proc, step);             // 4.0
            pdt.setSide(1);                                                             // 4.1
            t.addProcess(pdt);                                                          // 4.2
            proc.addProcessParticipant(pdt);                                            // 4.3
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean evaluateWarNeed(ProcessDisposition pd, long step) {
        if (evalRandomStateResolve(pd.getProcess().getIssue())) {
            pd.setN(true);
            return true;
        }
        return false;
    }

    private boolean evalRandomStateResolve(Issue i) {
        Issue issue = i;
        double leadershipOpinion = leadership.evaluateWarNeed(issue);
        double popularOpinion = territory.commonWeal.evaluateWarNeed(issue);
        int autocracyFactor = polityFact.getAutocracyRating();
        int democracyFactor = polityFact.getDemocracyRating();
        int div = autocracyFactor + democracyFactor;
        double divisor = div == 0 ? 1.0 : div * 1.0;
        return ((leadershipOpinion * autocracyFactor) + (popularOpinion * democracyFactor)) / divisor > 1.0;
    }

    @Override
    public boolean evaluateWarWillingness(ProcessDisposition pd) {
        /*
         *  Is the State willing to undertake action (commit resources) for this conflict?
         *    1. Is the leadership willing (tax, recruit, etc) ?
         *    2. Is the commonWeal willing (pay tax, get drafted, ect) ?
         */
        return leadership.evaluateWarWillingness(pd) && territory.commonWeal.evaluateWarWillingness(pd);
    }

    @Override
    public boolean evaluateAttackSuccess(ProcessDisposition pd) {
        WarProcess war = (WarProcess) pd.getProcess();
        int commitment = pd.getCommitment().getPax();
        int magnitude = war.getInvolvement().getPax();
        int extent = war.getProcessDispositionList().size();
        return magnitude / extent < commitment;
    }

    @Override
    public void collectTax() {
        double revenue = 0.0;
        for (Inclusion i : territory.getTileLinks()) {
            revenue += i.getTile().payTaxes();
        }
        this.resources.addTreasury(revenue);
    }

    private Resources warStrategy(Polity opponent, SecurityObjective objective, WorldOrder wo) {
        int goal;
        if (objective.value % 2 == 0) {
            goal = objective.value / 2;
        } else {
            goal = ((objective.value - 1) / 2);
        }
        int red;
        int blue;
        double threat;
        double risk;
        Map<String, Double> warParams = wo.getModelRun().getWarParameters();
        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values
//        System.out.println(target.getTerritory().getMapKey() + " ...what a problem");
        switch (goal) {
            case 0: // Punish (Strike)
                red = (int) (opponent.getForces() * warParams.get("RED_PUNISH") );
                blue = (int) (getForces() * (wo.random.nextDouble() * warParams.get("BLUE_PUNISH")) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_PUNISH"));
                risk = (getTreasury() * warParams.get("RISK_PUNISH"));
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 1: // Coerce (Show of Force)
                red = (int) (opponent.getForces() * warParams.get("RED_COERCE") );
                blue = (int) (getForces() * (wo.random.nextDouble() * warParams.get("BLUE_COERCE") ) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_COERCE") );
                risk = (getTreasury() * warParams.get("RISK_COERCE") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 2:  // Defeat (Swiftly Defeat)
                red = (int) (opponent.getForces() * warParams.get("RED_DEFEAT") );
                blue = (int) (getForces() * (wo.random.nextDouble() * warParams.get("BLUE_DEFEAT") ) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_DEFEAT") );
                risk = (getTreasury() * warParams.get("RISK_DEFEAT") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 3:  // Conquer (Win Decisively)
                red = (int) (opponent.getForces() * warParams.get("RED_CONQUER") );
                blue = (int) (getForces() * (wo.random.nextDouble() * warParams.get("BLUE_CONQUER") ) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_CONQUER") );
                risk = (getTreasury() * warParams.get("RISK_CONQUER") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
        }
        // default warStrategy is 0 forces/resources
        return strategy;
    }

}
