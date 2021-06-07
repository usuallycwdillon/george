package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.Issue;
import edu.gmu.css.data.IssueType;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.service.StateServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;
import sim.util.distribution.Poisson;

import java.util.List;

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
            for (int f=0; f<freq; f++) {
                int numStates = worldOrder.getAllTheStates().size();
                int instigator = worldOrder.random.nextInt(numStates);
                State p = worldOrder.getAllTheStates().get(instigator);
                List<State> potentialTargets = new StateServiceImpl().getRiskyNeighbors(p.getId(), worldOrder.getFromYear());
                int numPotentials = potentialTargets.size();
                if (numPotentials > 0) {
                    State t = potentialTargets.get(random.nextInt(numPotentials));
                    if (p != t) {
                        int d = random.nextInt(870);
                        Issue i = new Issue.IssueBuilder().instigator(p).duration(d).target(t).issueType(pickIssueType(p,t)).build();
                        i.setStopper(worldOrder.schedule.scheduleRepeating(i));
                    }
                }
            }
        }
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
