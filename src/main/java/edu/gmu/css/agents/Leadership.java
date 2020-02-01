package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.data.Issue;
import edu.gmu.css.data.World;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.War;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.entities.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Leadership implements Steppable {

    private Long id;
    private int type;
    private Polity polity;
    private Map<String, Person> leaders = new HashMap<>();
    public MersenneTwisterFast random;

    public Leadership() {

    }

    public Leadership(MersenneTwisterFast mtf) {
        random = mtf;
    }

    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        random = worldOrder.random;
        updateEconomicPolicy();
        updateSecurityPolicy();

    }

    public Long getId() {
        return id;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Map<String, Person> getLeaders() {
        return leaders;
    }

    public void setLeaders(Map<String, Person> leaders) {
        this.leaders = leaders;
    }

    private void updateSecurityPolicy() {
        if (polity != null) {
            Resources current = polity.getSecurityStrategy();
        } else {

        }
    }

    private void updateEconomicPolicy() {
        if(polity != null) {

        }

    }

    public WarProcess initiateWarProcess(Polity target, WorldOrder wo) {
        SecurityObjective objective = chooseSecurityObjective();
        Resources force = warStrategy(target, objective, wo);
        WarProcess p = new WarProcess(polity, target, force, objective, wo.getStepNumber());
        if(objective.value / 2.0 > 2.0) {
            recruit(force);
        }
        return p;
    }

    public Double evaluateWarNeed(Issue i) {
        // TODO: Leadership's evaluation of need to go to war over an issue should be extended with threat assessment.
        return random.nextDouble();
    }

    public PeaceProcess considerPeace(War war) {
        WorldOrder worldOrder = war.getWorldOrder();
        Long step = worldOrder.getStepNumber();
        Issue i = new Issue.IssueBuilder().institution(war).duration(2).build();
        i.setStopper(worldOrder.schedule.scheduleRepeating(i));
        // TODO: Wars need a duration or the Issue's step method needs to handle null for wars.
        PeaceProcess pp = new PeaceProcess(polity, i, step);
        worldOrder.getAllTheProcs().add(pp);
        pp.setStopper(worldOrder.schedule.scheduleRepeating(pp));
        return pp;
    }

    public boolean reconsiderPeace() {
        boolean decision = false;
        if (random.nextDouble() < 0.50) {
            decision = true;
        }
        return decision;
    }


    void initiatePeaceProcess() {

    }

    void intiateTradeProcess() {

    }

    void initiateOrgProcess() {

    }

    void initiateDiplomaticProcess() {

    }

    void initiateAllianceProcess() {

    }

    void initiateStatehoodProcess() {

    }

    void joinWarProcess() {

    }

    void joinPeaceProcess() {

    }

    void joinTradeProcess() {

    }

    void joinOrgProcess() {

    }

    void joinDiplomaticProcess() {

    }

    void joinAllianceProcess() {

    }

    void joinStatehoodProcess() {

    }


    private SecurityObjective chooseSecurityObjective() {
        // This method of arbitrarily selecting a strategic objective is a placeholder for some realistic logic
        int goal = random.nextInt(4) * 2;
        SecurityObjective objective = SecurityObjective.name(goal);
        return objective;
    }

    public Resources respondToThreat(ProcessDisposition disposition, Resources threat) {
        // commit resources in response to threat upto twice the threat
        Resources available = polity.getResources().evaluativeAvailableDifference(threat.multipliedBy(2.0));
        return available;
    }

    public boolean evaluateWarWillingness(ProcessDisposition pd) {
        double respond = random.nextGaussian();
        // Ref Cioffi-Revilla (1998) Politics and Uncertainty, p 160. (P_B), there is some probability that...
        return respond < 0.80;
    }

    private Resources warStrategy(Polity target, SecurityObjective objective, WorldOrder wo) {
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
        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values
//        System.out.println(target.getTerritory().getMapKey() + " ...what a problem");
        switch (goal) {
            case 0: // Punish
                red = (int) (target.getForces() * wo.getRED_PUNISH() );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * wo.getBLUE_PUNISH()) );
                threat = (target.getTreasury() * wo.getTHREAT_PUNISH());
                risk = (polity.getTreasury() * wo.getRISK_PUNISH());
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 1: // Coerce
                red = (int) (target.getForces() * wo.getRED_COERCE() );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * wo.getBLUE_COERCE() ) );
                threat = (target.getTreasury() * wo.getTHREAT_COERCE() );
                risk = (polity.getTreasury() * wo.getRISK_COERCE() );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 2:  // Defeat
                red = (int) (target.getForces() * wo.getRED_DEFEAT() );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * wo.getBLUE_DEFEAT() ) );
                threat = (target.getTreasury() * wo.getTHREAT_DEFEAT() );
                risk = (polity.getTreasury() * wo.getRISK_DEFEAT() );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 3:  // Conquer
                red = (int) (target.getForces() * wo.getRED_CONQUER() );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * wo.getBLUE_CONQUER() ) );
                threat = (target.getTreasury() * wo.getTHREAT_CONQUER() );
                risk = (polity.getTreasury() * wo.getRISK_CONQUER() );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
        }
        // default warStrategy is 0 forces/resources
        return strategy;
    }

    private void recruit(Resources risk) {


    }



}
