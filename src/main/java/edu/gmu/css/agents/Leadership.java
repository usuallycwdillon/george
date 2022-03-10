package edu.gmu.css.agents;

import edu.gmu.css.data.IssueType;
import edu.gmu.css.data.Resources;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.AlliancePartnerImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static edu.gmu.css.worldOrder.WorldOrder.ALLIANCES;

@NodeEntity
public class Leadership extends Entity implements Serializable, Steppable {

    @Id @GeneratedValue
    private Long id;
    @Property
    private int type;
    @Property
    private String leaderOf;
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

    public String getLeaderOf() {
        return leaderOf;
    }

    public void setLeaderOf(String leaderOf) {
        this.leaderOf = leaderOf;
    }

    private void updateEconomicPolicy() {

    }

    private double updateSecurityPolicy(WorldOrder wo) {
        Map<Polity, Double> threatMatrix = polity.getThreatNet();
        if(threatMatrix.size() == 0 && polity instanceof State) {
            ((State) polity).evaluateThreatNetwork(wo);
        }
        double totals = 0.0;
        for (double d : threatMatrix.values()) {
            totals += d;
        }
        return totals / threatMatrix.size();
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

    // War Process Behaviors
    public SecurityObjective chooseSecurityObjective(Issue i, WorldOrder wo) {
        Issue issue = i;
        WorldOrder worldOrder = wo;
        if (issue.getClaimant()==polity) { // I'm the instigator
            Polity target = issue.getTarget();
            Double threat = polity.getThreatNet().get(target);
            int x = 0;
            if (threat < 1.0 && issue.getIssueType() == IssueType.TERRITORY_ANTI) {
                x = worldOrder.random.nextInt(16);
            } else if (threat < 1.0 && issue.getIssueType() != IssueType.TERRITORY_ANTI) {
                x = worldOrder.random.nextInt(14);
            } else if (threat < 2.0 && issue.getIssueType() == IssueType.TERRITORY_ANTI) {
                x = worldOrder.random.nextInt(14);
            } else if (threat < 2.0 && issue.getIssueType() != IssueType.TERRITORY_ANTI) {
                x = worldOrder.random.nextInt(12);
            } else if (threat > 2.0 && issue.getIssueType() != IssueType.TERRITORY_ANTI) {
                return SecurityObjective.PUNISH;
            } else {
                return SecurityObjective.ABIDE;
            }

            if (x > 14) return SecurityObjective.name(6);
            else if (x > 12) return SecurityObjective.name(4);
            else if (x >= 5) return SecurityObjective.name(2);
            else return SecurityObjective.name(0);
        } else {  // Realistic response to instigator
            List<ProcessDisposition> participants = issue.getProcess().getProcessDispositionList();
            double threat = 0.0;
            for (ProcessDisposition p : participants) {
                if (!p.getOwner().equals(polity)) {
                    int challenge = p.getObjective().value;
                    threat += polity.getThreatNet().get(p.getOwner());
                    if (threat < 1.0 && challenge > 3) {
                        return SecurityObjective.name(Math.min(challenge + 3, 7));
                    } else if (threat < 1.0 && challenge < 0) {
                        return SecurityObjective.ABIDE;
                    } else if (threat < 1.0 && challenge < 4) {
                        return SecurityObjective.name(challenge + 1);
                    } else if (threat > 2.0 && challenge > 3) {
                        if (ALLIANCES && ((State) polity).seekAlliedAssistance(p, worldOrder) ) {
                            return SecurityObjective.DEFEND;
                        } else {
                            return SecurityObjective.ACCEPT;
                        }
                    } else if (threat > 3.0 && challenge < 4) {
                        return SecurityObjective.ACCEPT;
                    } else {
                        if ( ((State) polity).seekAlliedAssistance(p, worldOrder) ) {
                            // calculate new threat ratio and add ally to participants on my side
                            return SecurityObjective.name(Math.min(challenge + 1, 5));
                        } else {
                            return SecurityObjective.RETALIATE;
                        }
                    }
                }
            }
            return null;
        }
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

    public double takeInformedRandomOpinion(Issue i, WorldOrder wo) {
        /**
         *  What is the chance a leader will be in favor of armed conflict given the comparative threat of the enemy
         */
        Issue issue = i;
        Double threatRatio = 0.0;
        Double chance = wo.random.nextDouble();
        if (issue.getClaimant()==polity) { // I'm the instigator; get target's threat profile
            threatRatio = polity.getThreatNet().get(issue.getTarget());
            if (issue.getIssueType()==IssueType.POLICY_ANTI) {
                if (threatRatio < 0.5) {
                    return chance * 0.2;
                } else if (threatRatio < 1.0) {
                    return chance * 0.1;
                } else if (threatRatio < 3.0) {
                    return chance * 0.05;
                } else if (threatRatio < 100.0) {
                    return chance * 0.01;
                } else return chance * 0.001;
            } else if (issue.getIssueType()==IssueType.REGIME) {
                if (threatRatio < 0.5) {
                    return chance * 0.25;
                } else if (threatRatio < 1.0) {
                    return chance * 0.1;
                } else if (threatRatio < 3.0) {
                    return chance * 0.01;
                } else if (threatRatio < 100.0) {
                    return chance * 0.001;
                } else return chance * 0.0001;
            } else {
                if (threatRatio < 0.5) {
                    return chance * 0.25;
                } else if (threatRatio < 1.0) {
                    return chance * 0.1;
                } else if (threatRatio < 3.0) {
                    return chance * 0.025;
                } else if (threatRatio < 100.0) {
                    return chance * 0.015;
                } else return chance * 0.001;
            }
        } else { // I'm the target; get the instigator's threat profile
            Polity opponent = issue.getClaimant();
            threatRatio = polity.getThreatNet().get(opponent);
            for (ProcessDisposition p : issue.getProcess().getProcessDispositionList()) {
                if (p.getOwner().equals(opponent)) {
                    if (p.getObjective().value < 0) return chance * 0.001;
                }
            }
            if (issue.getIssueType()==IssueType.POLICY_ANTI) {
                if (threatRatio < 0.5) {
                    return chance * 0.50;
                } else if (threatRatio < 1.0) {
                    return chance * 0.48;
                } else if (threatRatio < 3.0) {
                    return chance * 0.45;
                } else if (threatRatio < 100.0) {
                    return chance * 0.42;
                } else return chance * 0.40;
            } else if (issue.getIssueType()==IssueType.REGIME) {
                if (threatRatio < 0.5) {
                    return chance * 1.0;
                } else if (threatRatio < 1.0) {
                    return chance * 1.0;
                } else if (threatRatio < 3.0) {
                    return chance * 1.0;
                } else if (threatRatio < 100.0) {
                    return chance * 0.99;
                } else return chance * 0.98;
            } else {
                if (threatRatio < 0.5) {
                    return chance * 0.99;
                } else if (threatRatio < 1.0) {
                    return chance * 0.98;
                } else if (threatRatio < 3.0) {
                    return chance * 0.97;
                } else if (threatRatio < 100.0) {
                    return chance * 0.96;
                } else return chance * 0.95;
            }
        }
    }

    public double getAvgSupport(Entity e) {
        Entity i = e;
        double tally = 0.0;
        for (Person p : leaders.values()) {
            tally += p.getIssueOpinion(i);
        }
        double avg = tally / leaders.size();
//        if(DEBUG) {
//            String name;
//            if (i.getClass().equals(Issue.class)) {
//                name = ((Issue) i).getFact().getName();
//            } else {
//                name = "unk cause";
//            }
//            long pros = leaders.values().stream().filter(p -> p.getIssueOpinion(i)==1).count();
//            long cons = leaders.values().stream().filter(person -> person.getIssueOpinion(i).equals(-1)).count();
//            long neuts = leaders.values().stream().filter(person -> person.getIssueOpinion(i).equals(0)).count();
//            System.out.println("issue: " + name + ":: pros: " + pros + "; cons: " + cons +
//                    "; neuts: " + neuts + " -- average " + avg);
//        }
        return avg;
    }

    public double evaluateWarNeed(Issue i, WorldOrder wo) {
        Issue issue = i;
        WorldOrder worldOrder = wo;
        if (!commonWeal.getEntityPositionMap().containsKey(issue)) {
            this.commonWeal.addIssue(issue, worldOrder);
        } else {
            this.commonWeal.socialize(issue, worldOrder);
        }
        return getAvgSupport(issue);
    }

    public double evaluateWarWillingness(Issue i, WorldOrder wo) {
        this.commonWeal.socialize(i, wo);
        return getAvgSupport(i);
    }

    public double evaluatePeaceNeed(War w, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        War war = w;
        if (!this.commonWeal.getEntityPositionMap().containsKey(war)) {
            this.commonWeal.addWar(war, worldOrder);
        }
        return getAvgSupport(war);
    }

    public double evaluatePeaceWillingness(War w, WorldOrder wo) {
        this.commonWeal.socialize(w, wo);
        return getAvgSupport(w);
    }


    private double evaluateEnemyThreatWithAlliedSupport(Map<State, Resources> help, State enemy) {
        double ourPop = polity.getTerritory().getPopulationTrans();
        double ourSDP = polity.getPublicSDP();
        double ourMilPer = polity.getMilitaryStrategy().getPax();
        double ourMilEx = polity.getMilitaryStrategy().getTreasury();

        for (Map.Entry<State, Resources> e : help.entrySet()) {
            ourPop += e.getKey().getPopulation();
            ourSDP += e.getKey().getPublicSDP();
            ourMilPer += e.getValue().getPax();
            ourMilEx += e.getValue().getTreasury();
        }

        double theirPop = enemy.getPopulation();
        double theirSDP = enemy.getPublicSDP();
        double theirMilPer = enemy.getMilitaryStrategy().getPax();
        double theirMilEx = enemy.getMilitaryStrategy().getTreasury();

        double avgMilEx2SDP = (ourMilEx + theirMilEx) / (ourSDP + theirSDP);
        double avgMilPer2Pop = (ourMilPer + theirMilPer) / (ourPop + theirPop);
        double ourThreat = ( (ourMilEx/ourSDP) / avgMilEx2SDP ) * ( (ourMilPer/ourPop) / avgMilPer2Pop);
        double theirThreat = ( (theirMilEx/theirSDP) / avgMilEx2SDP) * ( (theirMilPer/theirPop) / avgMilPer2Pop);

        return theirThreat / ourThreat;
    }

    private boolean askAlliesForHelp(WorldOrder wo, Issue i) {
        List<State> potentialHelp = new ArrayList<>();
        for (AllianceParticipationFact a : polity.getAlliances()) {
            List<String> partners = new AlliancePartnerImpl().getAlliancePartnerIds(a);
            for (String c : partners) {
                potentialHelp.add(wo.allTheStates.get(c));
            }
        }
        for (State s : potentialHelp) {
            return s.evaluateDefensePactImplementationNeed(polity, i);
        }
        return false;
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

    public Resources respondToThreat(ProcessDisposition disposition, Resources threat) {
        // commit resources in response to threat upto twice the threat
        Resources available = polity.getResources().afterSubtracting(threat.multipliedBy(2.0));
        return available;
    }

    private void recruit(Resources risk) {

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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Leadership that = (Leadership) o;

        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        return getLeaderOf() != null ? getLeaderOf().equals(that.getLeaderOf()) : that.getLeaderOf() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + (getLeaderOf() != null ? getLeaderOf().hashCode() : 0);
        return result;
    }
}
