package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.*;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.util.MTFWrapper;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.distribution.LogNormalDistribution;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.util.distribution.Gamma;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;

public class World implements Steppable {
    /**
     *
     */
    private long oldstep;
    private long weeksThisYear;
    private double weekExp;
    private long countdown;
    private final MTFApache random;
    private final MTFWrapper wrapper;
    private final LogNormalDistribution urbanizationRate;
    private final Gamma initialUrbanPop;


    public World() {
        MersenneTwisterFast mtf = new MersenneTwisterFast();
        random = new MTFApache(mtf);
        wrapper = new MTFWrapper();
        urbanizationRate = new LogNormalDistribution(random, -6.2749922, 0.6368938);
        initialUrbanPop = new Gamma(1.366969801, 6.432344312, mtf);
    }

    @Override
    public void step(SimState simState) {
        WorldOrder wo = (WorldOrder) simState;
        long weekNumber = wo.getWeekNumber();
        long newstep = System.nanoTime();
        Year thisYear = wo.getDataYear();

        if(DEBUG) {
            System.out.println("--------------------------- STEP " + wo.getStepNumber() + " previous took " + (newstep - oldstep)/1000000 + " -----------------------");
        }
        oldstep = System.nanoTime();
        // Record the global probability of war whether it's prescribed or calculated
        wo.updateGlobalHostility();
        countdown = thisYear.getEnded() - weekNumber;
        int yearNow = thisYear.getIntYear();
        if (countdown == 0) {
            weeksThisYear = thisYear.getWeeksThisYear();
            for (State s : wo.getAllTheStates().values()) {
                s.recordSimulationHistory(wo);
                s.getTerritory().updateTileGrowth(wo);
            }
            wo.setDataYear(thisYear.getNextYear());
            wo.setWeekExp(1.0 / weeksThisYear);
            urbanizeTiles(wo);

        }
        // End the simulation by the end of year 2200
        if (wo.getOverallDuration() == weekNumber) {
            System.out.println("The Overall Duration condition has been met, so the world stops now.");
            Dataset modelRun = wo.getModelRun();
            modelRun.setFinalDuration((int) wo.schedule.getSteps());
            modelRun.setFinalWarLikelihood(wo.getGlobalHostility().average());
            wo.getExternalWarStopper().stop();
            wo.finish();
        }
        // End the simulation if the global probability of war is stagnate or stable at zero
        if (wo.getGlobalWarLikelihood() <= 0) {
            System.out.println("The Global War Likelihood has gone to zero, so the world stops now.");
            Dataset modelRun = wo.getModelRun();
            modelRun.setFinalDuration((int) wo.schedule.getSteps());
            modelRun.setFinalWarLikelihood(wo.getGlobalHostility().average());
            wo.finish();
        }
        // End the simulation if hostility gets stuck in a local minimum/maximum
        if (wo.getGlobalHostility().average() == wo.getGlobalWarLikelihood() && wo.getStepNumber() > wo.getStabilityDuration()) {
            System.out.println("The average Global Hostility has stabilised, so the world stops now.");
            Dataset modelRun = wo.getModelRun();
            modelRun.setFinalDuration((int) wo.schedule.getSteps());
            modelRun.setFinalWarLikelihood(wo.getGlobalHostility().average());
            wo.finish();
        }

        if (DEBUG) {
            int d = 0;
            int w = 0;
            int c = 0;
            System.out.println("These are the conflicts currently underway: ");
            for (Institution i : wo.getAllTheInstitutions()) {
                if (i.getClass() == Dispute.class) {
                    d++;
                    System.out.println("\t" + ((Dispute) i).getDisputeFact().getObject());
                }
                if (i.getClass() == War.class) {
                    w++;
                    System.out.println("\t" + ((War) i).getWarFact().getObject());
                }
                if (i.getDomain() == Domain.WAR) c++;
            }
            System.out.println("There are now " + c + " conflicts: " + d + " disputes, " + w + " wars.");
        }

    }

    private void urbanizeTiles(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        List<Tile> qualifyingTiles = (wo.getTiles().values().parallelStream()
                .filter(t -> t.getPopDensity() > 0.64880055 && t.getUrbanPopTrans() == 0.0).collect(Collectors.toList()) );
        int rt = qualifyingTiles.size();
        int at = wo.getTiles().size();
        // Max annual frequency of urbanization in HYDE is 0.007541336
        // from tilePopGrowth.R #
        int newlyUrban = ((Number) Math.round(urbanizationRate.sample() * 0.007541336 * at)).intValue();
//        System.out.println("Out of " + rt + " rural Tiles, " + newlyUrban + " should urbanize this year.");
        for (int i=0;i<newlyUrban;i++) {
            Collections.shuffle(qualifyingTiles,wrapper);
            Tile tilePick = qualifyingTiles.remove(wo.random.nextInt(rt - 1));
            double uRate = initialUrbanPop.nextDouble();
            double pop = tilePick.getPopulationTrans();
            double uPop = Math.min((uRate * pop), pop);
            rt = qualifyingTiles.size();
            tilePick.setUrbanPopTrans(uPop);
            tilePick.setUrbanGrowthRateTrans( Math.pow(tilePick.getWeeklyPopGrowthRate(), 1.0269135) );
            // from tilePopGrowth.R #1410-1429
            double ex = -6.6781690 + (Math.log10(uPop) * 0.9165595);
            double builtArea = (Math.pow(10, ex)) * tilePick.getGrid().getKm2();
            tilePick.setBuiltUpArea(builtArea);

        }
    }

    public long getCountdown() {
        return this.countdown;
    }

}

// simulation_run_1623182017421