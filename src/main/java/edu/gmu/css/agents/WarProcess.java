package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Stoppable;

public class WarProcess extends Process {

    private Resources involvement = new Resources.ResourceBuilder().build();

    public WarProcess() {
    }

    public Resources getInvolvement() {
        return this.involvement;
    }
    public Domain getDomain() { return this.domain;}
    public String getName() {return this.name;}

    public WarProcess(Polity owner, Polity target, Resources force, SecurityObjective objective, Long step) {
        domain = Domain.WAR;
        name = "Dispute";
        began = step;
        // owning state links to the process and sets a strategy; that strategy establishes initial process parameters
        ProcessDisposition pdo = new ProcessDisposition(owner, this, began);
        pdo.setSide(0);
        pdo.setObjective(objective);
        pdo.setN(true);
        // TODO: 09JUL19. I commented these out because it isn't necessarily true after adding the CommonWeal.
//        pdo.setU(true);
//        pdo.setCommitment(force);
        // We must commit the resources before adding the process disposition to the owner's list of processes
        owner.addProcess(pdo);
        processParticipantLinks.add(pdo);
        // target state links to the process but has no strategy, yet. That's part of the process.
        ProcessDisposition pdt = new ProcessDisposition(target, this, began);
        pdt.setSide(1);
        pdt.learnPolityWarNeed();
        target.addProcess(pdt);
        processParticipantLinks.add(pdt);
        involvement.increaseBy(force);
        this.updateStatus();
    }

    @Override
    public void step(SimState simState) {
        /** Switch on the current status
         *  A process unfolds from the perspective of targets, not the instigator (or the environment). A successful
         *  process averts the war while being prepared (N+U+P) to defend the state/polity.
         *
         */
        worldOrder = (WorldOrder) simState;
        int count = 0;
        int statusSum = sumStatus();
//        System.out.println("This " + name + " proc now at " + fiat);

        if (stopped) {
            worldOrder.getAllTheProcs().remove(this);
            processParticipantLinks = null;
            return;
        }
        switch (statusSum) {
            case 1:
                this.updateStatus();
            case 2:
                // test for participants' N; +N = escalate, -N = outcome
                for (ProcessDisposition p : processParticipantLinks) {
                    if (p.atN()) {
                        count += 1;
                    } else {
                        if (p.getOwner().evaluateWarWillingness(p)) {
                            p.setN(true);
                            count += 1;
                        }
                    }
                }
                if (count >= processParticipantLinks.size() ) {
                    // This process is no longer equivalent to 'x' because participants all agree N; status = 4
                    this.N = true;
                    this.equivalence = false;
                } else {
                    this.equivalence = true;    // Evaluate for 'x' next step
                }
                this.updateStatus();        // Could move to 3- or 4
                break;
            case 3:                         // evaluates to 'x'
                // toss a coin: do(es) target(s)
                if (worldOrder.random.nextGaussian() < 0.50) {
                    for (ProcessDisposition p : processParticipantLinks.subList(1, processParticipantLinks.size())) {
                        // TODO: target(s) lose something
                    }
                }
                // return the instigator resources
                ProcessDisposition pdo = processParticipantLinks.get(0);
                Polity instigator = pdo.getOwner();
                Resources returned = pdo.getCommitment();
                instigator.getResources().increaseBy(returned);
                // log this as a dispute
                ended = worldOrder.getStepNumber();
                Dispute d = new Dispute(this);
                worldOrder.getModelRun().addFacts(d);
                saveNearEntity(d);
                conclude();
                break;
            case 4:
                // target recognizes need; test for U, then for P
                if (equivalence) { // N and ~U
                    ProcessDisposition pd = processParticipantLinks.get(0);
                    if (pd.getOwner().evaluateAttackSuccess(pd)) {
                        this.P = true;
                        this.outcome = true; // must result in 'X'. sums to 7 + equivalence
                    } else {
                        this.P = false;
                        this.outcome = true; // must result in 'E', sums to 5 + equivalence
                    }
                } else { // test for U
                    count = 0;
                    for (ProcessDisposition p : processParticipantLinks) {
                        if (p.atU()) {
                            count += 1;
                        } else {
                            p.getOwner().getThreatResponse(p, involvement);
                            if (p.atU()){
                                count += 1;
                            }
                        }
                    }
                    if (count >= processParticipantLinks.size() ) {  //  U, sums to 8
                        this.U = true;
                    } else {                                         // ~U, still sums to 4; 4 + equivalence
                        this.equivalence = true;
                    }
                }
                this.updateStatus();
                break;
            case 5:                                                 // catch
                if (equivalence) {
                    outcome = true;
                    stopper.stop();
                    worldOrder.getAllTheProcs().remove(this);
                } else {
                    ProcessDisposition pd = processParticipantLinks.get(0);
                    if (pd.getOwner().evaluateAttackSuccess(pd)) {
                        this.P = true;
                        this.equivalence = true;
                    } else {
                        this.P = false;
                        this.equivalence = true;
                    }
                }
                this.updateStatus();
                break;
            case 6:                                             // catch
                // A takes action without consequences
                this.outcome = true;
                this.updateStatus();
                break;
            case 7:
                //                                              // catch
                ProcessDisposition pd = processParticipantLinks.get(0);
                pd.getCommitment().setTreasury(0.0);
                pd.getOwner().getResources().addPax(pd.getCommitment().getPax());
                this.outcome = true;
                saveNearEntity(new Dispute(this));
                conclude();
                break;
            case 8:
                // Test for P. Evaluates to 9 or 10
                ProcessDisposition pda = processParticipantLinks.get(0);
                if (pda.getOwner().evaluateAttackSuccess(pda)) {  // P,, sums to 10
                    this.P = true;
                    this.equivalence = false;
                } else {                                          // ~P, sums to 9
                    this.P = false;
                    this.equivalence = false;
                    this.outcome = true;
                }
                this.updateStatus();
                this.equivalence = false;
                break;
            case 9:
                if (equivalence) {
                    stop();
                } else {
                    this.equivalence = true;
                }
                // log nothing; just die next step
                this.updateStatus();
                conclude();
                break;
            case 10:
                // Starting the war is successful or not
                if (0.5 < simState.random.nextGaussian()) {
                    this.S = true;
                    this.outcome = false;

                } else {
                    this.equivalence = true;
                    this.outcome = true;
                }
                this.updateStatus();
                break;
            case 11:
                if (outcome) {
                    Long step = worldOrder.getStepNumber();
                    Institution w = createInstitution(step);
                    Stoppable stoppable = worldOrder.schedule.scheduleRepeating(w);
                    w.setStopper(stoppable);
                    WorldOrder.getAllTheInstitutions().add(w);
                    conclude();
                }
                this.outcome = true;
                this.updateStatus();
                break;
            case 14:                // War breaks out.
                this.outcome = true;
                updateStatus();
                break;
            case 15:                // Start at fiat 'A' and log the process before we attach a War and ignore the process.
                if (outcome) {
                    // Each participant get's their commitment back, minus (arbitrary) 10% of the cost if the war
                    // can be averted.
                    for (ProcessDisposition p : processParticipantLinks) {
                        double t = (p.getCommitment().getTreasury() * 0.9);
                        p.getCommitment().setTreasury(t);
                        p.getOwner().getResources().increaseBy(p.getCommitment());
                    }
                    ended = worldOrder.getStepNumber();
                    saveNearEntity(new Dispute(this));
                }
                this.outcome = true;
                this.updateStatus();
                conclude();
                break;
        }

    }


}
