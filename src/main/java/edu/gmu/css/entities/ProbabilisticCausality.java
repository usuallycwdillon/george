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
                if (p != t) {
                    WarProcess proc = p.getLeadership().initiateWarProcess(t);
                    WorldOrder.getAllTheProcs().add(proc);
                    Stoppable stoppable = worldOrder.schedule.scheduleRepeating(proc);
                    proc.setStopper(stoppable);
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
