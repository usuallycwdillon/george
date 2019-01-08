package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.ProcessDisposition;
import edu.gmu.css.worldOrder.Institution;
import edu.gmu.css.worldOrder.Resources;
import edu.gmu.css.worldOrder.War;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.Relationship;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.IntStream;

public class WarProcess extends Process {

    private Domain domain = Domain.WAR;
    private Resources involvement;

    public WarProcess() {
    }


    public WarProcess(Polity owner, Polity target, Resources force) {
        began = worldOrder.getStepNumber();
        // owning state links to the process and sets a strategy; that strategy establishes initial process parameters
        ProcessDisposition pdo = new ProcessDisposition(owner, this, began);
        pdo.setCommitment(force);
        // We must commit the resources before adding the process disposition to the owner's list of processes
        owner.addProcess(pdo);
        processParticipantLinks.add(pdo);
        // target state links to the process but has no strategy, yet. That's part of the process.
        ProcessDisposition pdt = new ProcessDisposition(target, this, began);
        target.addProcess(pdt);
        processParticipantLinks.add(pdt);
        involvement.increaseBy(force);
    }

//    @Override
//    public void setStatus() {
//
//    }
//
//    @Override
//    public void setFiat() {
//
//    }

    public Resources getInvolvement() {
        return this.involvement;
    }

    @Override
    public void step(SimState simState) {
        /** Switch on the current status
         *
         */
        int count = 0;

        int statusSum = 0;
        for (int i : status) {
            statusSum =+ i;
        }

        switch (statusSum) {
            case 2:
                // initial state: a challenge exists
                // Consider whether unresourced participants have committed resources. If not, does everybody at least
                // feel the need?
                for (ProcessDisposition p : processParticipantLinks) {
                    if (p.getCommitment().getPax() > 0) {
                        count += 1;
                    } else {
                        if (p.getOwner().getLeadership().willEscalate()) {
                            count += 1;
                        }
                    }
                }
                if (count >= processParticipantLinks.size() ) {
                    // This process is no longer equivalent to 'x' because participants all agree N
                    this.N = true;
                    this.equivalence = false;
                } else {
                    this.outcome = true;    // will evaluate to 'x'; consequences for target may or may not destroy it
                }
                this.updateStatus();
                break;
            case 3:
                // TODO: A takes goal action on B; expends resources; regains PAX

                this.updateStatus();
                break;
            case 4:
                // target recognizes need but undertakes no action; owner does not attack
                // Let Polity A take something from Polity B
                count = 0;
                for (ProcessDisposition p : processParticipantLinks) {
                    if (p.getCommitment().getPax() > 0) {
                        count += 1;
                    } else {
                        p.getOwner().getLeadership().respondToThreat(p, involvement);
                        if (p.getCommitment().getPax() > 0) {
                            count += 1;
                        }
                    }
                }
                if (count >= processParticipantLinks.size() ) {
                    // This should produce the X fiat, though we're not necessarily finished
                    this.U = true;
                    this.outcome = true;
                } else {
                    if (processParticipantLinks.get(0).getCommitment().getPax() > 0) {
                        this.P = true;
                        this.equivalence = true;
                    } else {
                        this.P = false;
                        this.equivalence = true;
                    }
                }
                this.updateStatus();
                break;
            case 5:

                break;
            case 6:
                // A takes action without consequences
                this.outcome = true;
                // A's wealth committments get spent, but their personnel get returned. They get concessions from B
                processParticipantLinks.get(0).getCommitment().setTreasury(0.0);
                break;
            case 7:
                break;
            case 8:
                break;
            case 9:
                break;
            case 10:
                break;
            case 11:
                break;
            case 14:
                break;
            case 15:
                break;
        }

        // if the process has an outcome (and is not a war) log it; the main loop will kill logged, outcome procs.
        // TODO: Main loop must kill logged procs with an outcome.
    }




    @Override
    public Institution createInstitution() {
        return new War();
    }



}
