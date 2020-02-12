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

    public SecurityObjective chooseSecurityObjective(Issue i) {
        // This method of arbitrarily selecting a strategic objective is a placeholder for some realistic logic
        Issue issue = i;
        if (issue.getInstigator()==polity) { // I'm the instigator
            Polity target = issue.getTarget();
            int x = 0;
            int opfor = target.getForces();
            int myfor = polity.getForces();
            double ratio = (myfor * 1.0) / (opfor * 1.0);
            if (ratio > 4.0) {
                x = random.nextInt(15);
            } else if (ratio > 2.0) {
                x = random.nextInt(14);
            } else if (ratio >= 1.0) {
                x = random.nextInt(12);
            } else {
                x = random.nextInt(8);
            }
            if (x > 14) return SecurityObjective.name(6);
            else if (x > 12) return SecurityObjective.name(4);
            else if (x > 8) return SecurityObjective.name(2);
            else return SecurityObjective.name(0);
        } else {
            return null;
        }
    }

    public Double evaluateWarNeed(Issue i) {
        // TODO: Leadership's evaluation of need to go to war over an issue should be extended with threat assessment, but
        //  for now, it's just a random double value.
        return random.nextDouble();
    }

    public PeaceProcess considerPeace(War war, WorldOrder wo) {
        WorldOrder worldOrder = wo;
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
        Map<String, Double> warParams = wo.getModelRun().getWarParameters();
        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values
        switch (goal) {
            case 0: // Punish (Strike)
                red = (int) (target.getForces() * warParams.get("RED_PUNISH") );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * warParams.get("BLUE_PUNISH")) );
                threat = (target.getTreasury() * warParams.get("THREAT_PUNISH"));
                risk = (polity.getTreasury() * warParams.get("RISK_PUNISH"));
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 1: // Coerce (Show of Force)
                red = (int) (target.getForces() * warParams.get("RED_COERCE") );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * warParams.get("BLUE_COERCE") ) );
                threat = (target.getTreasury() * warParams.get("THREAT_COERCE") );
                risk = (polity.getTreasury() * warParams.get("RISK_COERCE") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 2:  // Defeat (Swiftly Defeat)
                red = (int) (target.getForces() * warParams.get("RED_DEFEAT") );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * warParams.get("BLUE_DEFEAT") ) );
                threat = (target.getTreasury() * warParams.get("THREAT_DEFEAT") );
                risk = (polity.getTreasury() * warParams.get("RISK_DEFEAT") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 3:  // Conquer (Win Decisively)
                red = (int) (target.getForces() * warParams.get("RED_CONQUER") );
                blue = (int) (polity.getForces() * (wo.random.nextDouble() * warParams.get("BLUE_CONQUER") ) );
                threat = (target.getTreasury() * warParams.get("THREAT_CONQUER") );
                risk = (polity.getTreasury() * warParams.get("RISK_CONQUER") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
        }
        // default warStrategy is 0 forces/resources
        return strategy;
    }

    private void recruit(Resources risk) {


    }



}
