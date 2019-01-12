package edu.gmu.css.agents;

import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.ProcessDisposition;
import edu.gmu.css.entities.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;

public class Leadership implements Steppable {

    private Long id;
    private int type;
    private Polity polity;
    public WorldOrder worldOrder;

    public Leadership() {   }

    public Leadership(SimState simState) {
        worldOrder = (WorldOrder) simState;
    }

    public void step(SimState simState) {
        worldOrder = (WorldOrder) simState;
        updateEconomicPolicy();
        updateSecurityStrategy();

    }

    private void updateSecurityStrategy() {
        if (polity != null) {
            
        }

    }

    private void updateEconomicPolicy() {
        if(polity != null) {

        }

    }

    public void initiateWarProcess(Polity target) {
        SecurityObjective objective = chooseSecurityObjective();
        Resources force = warStrategy(target, objective);
        Process process = new WarProcess(polity, target, force, objective);
        worldOrder.schedule.scheduleRepeating(process);
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
        int goal = worldOrder.random.nextInt(4) * 2;
        SecurityObjective objective = SecurityObjective.given(goal);
        return objective;
    }

    public Resources respondToThreat(ProcessDisposition disposition, Resources threat) {
        // commit resources in response to threat upto twice the threat
        Resources available = polity.getResources().evaluativeAvailableDifference(threat.multipliedBy(2.0));
        return available;
    }

    public boolean shouldEscalate() {
        double respond = worldOrder.random.nextGaussian();
        // See Cioffi-Revilla (1998) Politics and Uncertainty, p 160. (P_B)
        return respond < 0.50;
    }

    private Resources warStrategy(Polity target, SecurityObjective objective) {
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
        switch (goal) {
            case 0: // Punish
                red = (int) (target.getForces() * WorldOrder.RED_PUNISH);
                blue = (int) (polity.getForces() * (worldOrder.random.nextDouble() * WorldOrder.BLUE_PUNISH) );
                threat = (target.getTreasury() * WorldOrder.THREAT_PUNISH);
                risk = (polity.getTreasury() * WorldOrder.RISK_PUNIISH);
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 1: // Coerce
                red = (int) (target.getForces() * WorldOrder.RED_COERCE);
                blue = (int) (polity.getForces() * (worldOrder.random.nextDouble() * WorldOrder.BLUE_COERCE) );
                threat = (target.getTreasury() * WorldOrder.THREAT_COERCE);
                risk = (polity.getTreasury() * WorldOrder.RISK_COERCE);
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 2:  // Defeat
                red = (int) (target.getForces() * WorldOrder.RED_DEFEAT);
                blue = (int) (polity.getForces() * (worldOrder.random.nextDouble() * WorldOrder.BLUE_DEFEAT) );
                threat = (target.getTreasury() * WorldOrder.THREAT_DEFEAT);
                risk = (polity.getTreasury() * WorldOrder.RISK_DEFEAT);
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 3:  // Conquer
                red = (int) (target.getForces() * WorldOrder.RED_CONQUER);
                blue = (int) (polity.getForces() * (worldOrder.random.nextDouble() * WorldOrder.BLUE_CONQUER) );
                threat = (target.getTreasury() * WorldOrder.THREAT_CONQUER);
                risk = (polity.getTreasury() * WorldOrder.RISK_CONQUER);
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
        }
        // default warStrategy is 0 forces/resources
        return strategy;
    }




}
