package edu.gmu.css.agents;

import edu.gmu.css.data.ProcTypes;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.ProcessDisposition;
import edu.gmu.css.worldOrder.Resources;
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
        updateSecurityStragety();

    }

    void updateSecurityStragety() {
        if (polity != null) {

        }

    }

    void updateEconomicPolicy() {
        if(polity != null) {

        }

    }

    void initiateWarProcess(Polity target) {

        Resources resources = new Resources.ResourceBuilder().wealth().population().build();
        // TODO: If our allies are already at war with this other state, join that process instead of starting a new one.
        Process process = new WarProcess(polity, target, resources);
    }

    void initiatePeaceProcess() {

    }

    void intiateTradeProcess() {

    }

    void initiateOrgProcess() {

    }

    void initiateDiplomaticProcess() {

    }





}
