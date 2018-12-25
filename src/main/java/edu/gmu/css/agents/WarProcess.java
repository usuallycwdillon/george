package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.ProcessDisposition;
import edu.gmu.css.worldOrder.Institution;
import edu.gmu.css.worldOrder.Resources;
import edu.gmu.css.worldOrder.War;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;

public class WarProcess extends Process {

    private Domain domain = Domain.WAR;

    public WarProcess() {
    }

    public WarProcess(Polity owner, Polity target, Resources resources) {
        began = worldOrder.getStepNumber();
        // owning state links to the process and sets a strategy; that strategy establishes initial process parameters
        ProcessDisposition pdo = new ProcessDisposition(owner, this, began);
        owner.addProcess(pdo);

        ProcessDisposition pdt = new ProcessDisposition(target, this, began);

        target.addProcess(pdt);
    }


    @Override
    public void setStatus() {

    }

    @Override
    public void setFiat() {

    }

    @Override
    public void step(SimState simState) {

    }

    @Override
    public Institution createInstitution() {
        return new War(worldOrder.getStepNumber());
    }


}
