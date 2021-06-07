package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.entities.State;
import edu.gmu.css.entities.Year;
import edu.gmu.css.util.MTFApache;
import edu.gmu.css.util.MTFWrapper;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.distribution.LogNormalDistribution;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.util.distribution.Gamma;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class World implements Steppable {
    /**
     *
     */
    private long oldstep;
    private long weeksThisYear;
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
        long stepNo = wo.getStepNumber();
        long newstep = System.nanoTime();
        Year thisYear = wo.getDataYear();

        if(WorldOrder.isDEBUG()) {
            System.out.println("--------------------------- STEP " + stepNo + " previous took " + (newstep - oldstep)/1000000 + " -----------------------");
        }
        oldstep = System.nanoTime();
        // Record the global probability of war whether it's prescribed or calculated
        wo.updateGlobalHostility();
        long countdown = thisYear.getEnded() - (stepNo + wo.dateIndex);
        if (countdown == 0) {
            weeksThisYear = thisYear.getWeeksThisYear();
            for (State s : wo.getAllTheStates()) {
                s.recordEconomicHistory(wo);
                s.evaluateThreatNetwork(wo);
            }
            if(thisYear.getNameAsInteger() % 5 == 0) {
                for (State s : wo.getAllTheStates()) {
                    s.takeCensus(wo);
                }
            }
            wo.setDataYear(thisYear.getNextYear());
            urbanizeTiles(wo);
        }
        // End the simulation after (about) 400 years
        if (stepNo == WorldOrder.getOverallDuration()) {
            System.out.println("The Overall Duration condition has been met, so the world stops now.");
            wo.getExternalWarStopper().stop();
            System.exit(0);
        }
        // End the simulation if the global probability of war is stagnate or stable at zero
        if (wo.getGlobalWarLikelihood() <= 0) {
            System.out.println("The Global War Likelihood has gone to zero, so the world stops now.");
            System.exit(0);
        }
        // End the simulation if hostility gets stuck in a local minimum/maximum
        if (wo.getGlobalHostility().average() == wo.getGlobalWarLikelihood() && stepNo > wo.getStabilityDuration()) {
            System.out.println("The average Global Hostility has stabilised, so the world stops now.");
            System.exit(0);
        }
    }

    private void urbanizeTiles(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        List<Tile> qualifyingTiles = (wo.getTiles().values().parallelStream()
                .filter(t -> t.getPopDensity() > 0.64880055 && t.getUrbanPop() == 0.0).collect(Collectors.toList()) );
        int rt = qualifyingTiles.size();
        int at = wo.getTiles().size();
        // Max annual frequency of urbanization in HYDE is 0.007541336
        // from tilePopGrowth.R #
        int newlyUrban = ((Number) Math.round(urbanizationRate.sample() * 0.007541336 * at)).intValue();
        System.out.println("Out of " + rt + " rural Tiles, " + newlyUrban + " should urbanize this year.");
        for (int i=0;i<newlyUrban;i++) {
            Collections.shuffle(qualifyingTiles,wrapper);
            Tile tilePick = qualifyingTiles.remove(wo.random.nextInt(rt - 1));
            double uRate = initialUrbanPop.nextDouble();
            double pop = tilePick.getPopulation();
            double uPop = uRate * pop;
            rt = qualifyingTiles.size();
            tilePick.setUrbanPop(uPop);
            tilePick.setUrbanGrowthRate(tilePick.getInitialPopRate() * 1.015);
            // from tilePopGrowth.R #1410-1429
            double ex = -6.6781690 + (Math.log10(uPop) * 0.9165595);
            double builtArea = (Math.pow(10, ex)) * tilePick.getGrid().getKm2();
            tilePick.setBuiltUpArea(builtArea);

        }
    }

}

