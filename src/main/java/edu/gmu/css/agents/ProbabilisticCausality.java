package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.IssueType;
import edu.gmu.css.entities.ClaimFact;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.State;
import edu.gmu.css.service.ClaimFactServiceImpl;
import edu.gmu.css.service.ThreatNetworkServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;
import sim.util.distribution.Poisson;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class ProbabilisticCausality implements Steppable, Stoppable {

    double globalWarLikelihood;
    MersenneTwisterFast random;
    static Poisson poisson;
    WorldOrder worldOrder;
    Stoppable stopper;


    public ProbabilisticCausality(SimState simState) {
        worldOrder = (WorldOrder) simState;
        globalWarLikelihood = worldOrder.getGlobalWarLikelihood();
        random = worldOrder.random;
        poisson = new Poisson(globalWarLikelihood, random);
    }

    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        this.updateDistribution(worldOrder);
        int freq = poisson.nextInt();
        if (freq > 0) {
            Map<String, State> theStates = worldOrder.getAllTheStates();
            List<String> cowCodes = new ArrayList<>();
            for (String s : theStates.keySet()) {
                cowCodes.add(s);
            }
            for (int f=0; f<freq; f++) {
                int numStates = worldOrder.getAllTheStates().size();
                if (numStates <= 0) break;
                String instigator = cowCodes.get(worldOrder.random.nextInt(numStates));
                State p = worldOrder.getAllTheStates().get(instigator);
//                List<String> potentialTargets = new ThreatNetworkServiceImpl().getRiskyNeighbors(p.getId(), worldOrder.getFromYear());
                List<String> potentialTargets = new ThreatNetworkServiceImpl()
                        .getAnyNeighbor(p.getId(), worldOrder.getFromYear());
                State t = this.pickRandomState(worldOrder, p, potentialTargets);
                if (p != t) {
                    int d = random.nextInt(870);
                    Long stepNo = worldOrder.getWeekNumber();
                    Issue i = new Issue.IssueBuilder().claimant(p).duration(d).target(t)
                            .issueType(pickIssueType(p,t)).from(stepNo).build();
                    i.setStopper(worldOrder.schedule.scheduleRepeating(i));
                    ClaimFact cf = new ClaimFact.FactBuilder().claimant(p).target(t).issue(i)
                            .from(stepNo).until(stepNo + d).dataset(worldOrder.getModelRun()).build();
                    i.setFact(cf);
                    if (WorldOrder.RECORDING) {
                        new ClaimFactServiceImpl().createOrUpdate(cf);
                    }
                }
            }
        }
    }

    private State pickRandomState(WorldOrder wo, State a, List<String> p) {
        WorldOrder worldOrder = wo;
        State claimant = a;
        State target;
        List<String> potentialTargets = p;
        int numPotentials = potentialTargets.size();
        int e = 0;
        if (numPotentials > 0) {
            target = worldOrder.getAllTheStates().get(potentialTargets.get(random.nextInt(numPotentials)));
            if (Objects.isNull(target) || claimant.equals(target)) {
                target = pickRandomState(worldOrder, claimant, potentialTargets);
                e++;
                if (e > 4) return claimant;
            }
        } else {
            target = claimant;
        }
        return target;
    }

    // Improved algorithm for conflict issues begat by this Causality agent
    private IssueType pickIssueType(Polity p, Polity t) {
        /*   structure       condition  issueType               ProcessResult       initialStrategy
         *   p,t Allies         T       "Alliance Endurance"    keep alliance       leadership keeps alliance
         *                      F       <next>
         *   p,t SharePeace     T       "Peace Stability"       keep peace          leadership keeps peace
         *                      F       <next>
         *   p,t ShareBorder    T       P("Territorial Claim")  WarProcess          Strike, SOF, SD
         *                              P("Policy Difference")      "               Strike, SOF
         *                              P("Regime/Governance")      "               Strike, SD
         *                      F       <next>
         *   p,t BorderWater    T       P("Territorial Claim")  WarProcess          Strike, SOF, SD
         *                              P("Policy Difference")      "               Strike, SOF
         *                              P("Regime/Governance")      "               Strike, SD
         *   p'sAllyBorders t   T       P("Policy Difference")      "               Strike, SOF
         *                              P("Regime/Governance")      "               Strike, SOF, SD
         *                      F       P("Policy Difference")      "               Strike
         *                              P("Regime/Governance")      "               Strike, SD
         *
         *   initialStrategies, initialTroopDeployments and escalation
         *   No goal      |       correct     |   overcome           |      destroy
         *
         *                 / 1 Strike  (10^2) \
         *   0 preIssue (0)         |          3 Swiftly Defeat (10^4)
         *                 \        v          /          |
         *                  \ 2 Show of Force /           |
         *                      (10^3)        \           v
         *                                     4 Win Decisively (10^5) --> 5 Total War (10^6)
         *
         *          /---------\ /--------\     At each level of conflict, the opponent may match strategy or
         *   0 --> 1 --> 2 --> 3 --> 4 --> 5   escalate by 1 or 2 levels of conflict: go from 0 to 1 or 0 to 2;
         *     \--------/ \---------/          from 1 to 2 or 1 to 3; from 2 to 3 or 2 to 4; from 3 to 4 or 3 to 5.
         *
         */
        double chance = random.nextDouble();
        if (chance > 0.63) {
            return IssueType.TERRITORY_ANTI;
        } else if (chance < 0.24) {
            return IssueType.POLICY_ANTI;
        } else {
            return IssueType.REGIME;
        }
    }



    public void updateDistribution(WorldOrder wo) {
        if (wo.getGlobalWarLikelihood() != this.globalWarLikelihood) {
            this.globalWarLikelihood = wo.getGlobalWarLikelihood();
            this.random = wo.random;
            poisson = new Poisson(globalWarLikelihood,random);
        }
    }


    public void stop() {
    }

    public void setStopper(Stoppable stoppable) {
        stopper = stoppable;
    }
}
