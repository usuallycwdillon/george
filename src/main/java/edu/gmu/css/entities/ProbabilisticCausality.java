package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;
import sim.util.distribution.Poisson;

import java.util.List;

public class ProbabilisticCausality implements Steppable, Stoppable {

    long initializationPeriod;
    double globalWarLikelihood;
    MersenneTwisterFast random;
    public static Poisson poisson;
    Stoppable stopper;


    public ProbabilisticCausality(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        initializationPeriod = WorldOrder.getInitializationPeriod();
        globalWarLikelihood = worldOrder.getGlobalWarLikelihood();
        random = worldOrder.random;
        poisson = new Poisson(globalWarLikelihood, random);
    }

    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        int freq = poisson.nextInt();
        if (freq > 0) {
            for (int f=0; f<freq; f++) {
                /*
                 * Pick instigator (p) and target (t)
                 * new ProcessDisposition for p at status 2
                 * new Issue(t), i
                 * Do leadership and population of p agree on need N for military action to address issue?
                 * No: skip; p hold onto issue until it dies
                 * Yes: this PD now at step 4
                 *      new WarProcess.participation.add(p).issue(i).build()
                 *      target becomes aware of issue and threat of military action
                 *      new ProcessDisposition for t at status 2
                 *      no time for referendum, does the Leadership of t recognize need to defend itself?
                 *      No: This WarProcess moves to status 3-
                 *      Yes: This WarProcess moves to status 4
                 */
                int numStates = WorldOrder.getAllTheStates().size();
                int instigator = random.nextInt(numStates);
                Polity p = WorldOrder.getAllTheStates().get(instigator);
                List<Polity> potentialTargets = p.getNeighborhoodWithoutAllies();
                int numPotentials = potentialTargets.size();
                if (numPotentials < 1 || p.getNeighborhoodWithoutAllies() == null) {
                    break;
                }
                int target = random.nextInt(numPotentials);
                Polity t = potentialTargets.get(target);
                int d = random.nextInt(523);
                if (p != t) {
                    Issue i = new Issue.IssueBuilder().duration(d).target(t).build();
                    i.setStopper(worldOrder.schedule.scheduleRepeating(i));
                    // TODO: Do leadership and population of p agree on need N for military action to address issue?
                    if (p.warResponse(i, t)) {
                        WarProcess proc = p.getLeadership().initiateWarProcess(t);
                        proc.setIssue(i);
                        worldOrder.addProc(proc);
                        Stoppable stoppable = worldOrder.schedule.scheduleRepeating(proc);
                        proc.setStopper(stoppable);
                    }
                }
            }
        }
    }

    public void stop() {

    }

    public void setStopper(Stoppable stoppable) {
        stopper = stoppable;
    }
}
