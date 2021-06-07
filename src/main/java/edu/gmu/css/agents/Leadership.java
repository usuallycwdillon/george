package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.data.Issue;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.data.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import javax.management.relation.RelationNotFoundException;
import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@NodeEntity
public class Leadership extends Entity implements Serializable, Steppable {

    @Id @GeneratedValue
    private Long id;
    @Property
    private int type;
    @Relationship(type="LEADERSHIP_OF")
    private Polity polity;
    @Relationship(type="LEADERSHIP_FROM", direction = Relationship.INCOMING)
    private CommonWeal commonWeal;
    @Transient
    private Map<String, Person> leaders = new HashMap<>();

    public Leadership() {

    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        this.polity.updateEconomicPolicy(this, worldOrder);
        if (worldOrder.getStepNumber() % 26 == 0) {
            updateSecurityPolicy(worldOrder);
        }
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

    private void updateEconomicPolicy() {

    }

    private void updateSecurityPolicy(WorldOrder wo) {
        Map<Polity, Double> threatMatrix = polity.getThreats();
        if(threatMatrix.size() == 0 && polity instanceof State) {
            ((State) polity).evaluateThreatNetwork(wo);
        }
        double totals = 0.0;
        for (double d : threatMatrix.values()) {
            totals += d;
        }
        double generalThreat = totals / threatMatrix.size();

    }

    public CommonWeal getCommonWeal() {
        return commonWeal;
    }

    public void setCommonWeal(CommonWeal commonWeal) {
        this.commonWeal = commonWeal;
    }

    public void findLeaders() {
        if (leaders.size()==0) {
            this.leaders = commonWeal.findLeaders();
        }
    }

    public SecurityObjective chooseSecurityObjective(Issue i, WorldOrder wo) {
        // This method of arbitrarily selecting a strategic objective is a placeholder for some realistic logic
        Issue issue = i;
        WorldOrder worldOrder = wo;
        if (issue.getInstigator()==polity) { // I'm the instigator
            Polity target = issue.getTarget();
            int x = 0;
            double opfor = target.getForces();
            double myfor = polity.getForces();
            double ratio = (myfor * 1.0) / (opfor * 1.0);
            if (ratio > 4.0) {
                x = worldOrder.random.nextInt(15);
            } else if (ratio > 2.0) {
                x = worldOrder.random.nextInt(14);
            } else if (ratio >= 1.0) {
                x = worldOrder.random.nextInt(12);
            } else {
                x = worldOrder.random.nextInt(8);
            }
            if (x > 14) return SecurityObjective.name(6);
            else if (x > 12) return SecurityObjective.name(4);
            else if (x > 8) return SecurityObjective.name(2);
            else return SecurityObjective.name(0);
        } else {
        // Match or elevate security objective of instigator
            List<ProcessDisposition> participants = issue.getProcess().getProcessDispositionList();
            for (ProcessDisposition p : participants) {
                if (!p.getOwner().equals(polity)) {
                    int challenge = p.getObjective().value;
                    if (polity.getResources().getPax() > p.getOwner().getResources().getPax() && challenge < 5) {
                        return SecurityObjective.name(challenge + 3);
                    } else {
                        return SecurityObjective.name(challenge + 1);
                    }
                }
            }
            return null;
        }
    }

    public Double evaluateWarNeed(Issue i, WorldOrder wo) {
        // TODO: Leadership's evaluation of need to go to war over an issue should be extended with threat assessment, but
        //  for now, it's just a random double value.
        return wo.random.nextDouble();
    }

    public double considerPeace(WarParticipationFact f, WorldOrder wo) {
        WarParticipationFact participation = f;
        double tMetric = participation.getCost().getTreasury() / participation.getCommitment().getTreasury();
        double pMetric = participation.getCost().getPax() / participation.getCommitment().getPax();
        double threshold = wo.random.nextDouble(true, false);
        if (tMetric > 1.0) threshold += 0.1;
        if (pMetric > 0.5) threshold += 0.1;
        return Math.min(threshold, 0.9999999);
    }


    public boolean reconsiderPeace(WorldOrder wo) {
        boolean decision = wo.random.nextDouble() < 0.50;
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

    public boolean evaluateWarWillingness(ProcessDisposition pd, WorldOrder wo) {
        double respond = wo.random.nextGaussian();
        // Ref Cioffi-Revilla (1998) Politics and Uncertainty, p 160. (P_B), there is some probability that...
        return respond < 0.0;
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
