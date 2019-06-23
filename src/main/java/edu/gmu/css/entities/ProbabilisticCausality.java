package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Issue;
import edu.gmu.css.queries.StateQueries;
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
                int numStates = WorldOrder.getAllTheStates().size();
                int instigator = worldOrder.random.nextInt(numStates);
                Polity p = WorldOrder.getAllTheStates().get(instigator);
                List<Polity> potentialTargets = StateQueries.getNeighborhoodWithoutAllies(p);
                int numPotentials = potentialTargets.size();
                if (numPotentials > 0) {
                    Polity t = potentialTargets.get(random.nextInt(numPotentials));
                    if (p != t) {
                        int d = random.nextInt(523);
                        Issue i = new Issue.IssueBuilder().duration(d).target(t).build();
                        p.takeIssue(simState, i);
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
