package edu.gmu.css.agents;

import com.sun.xml.internal.bind.annotation.OverrideAnnotationOf;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.Dispute;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.entities.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;

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
        // TODO: decide whether 'began' is a year or the step
        domain = Domain.WAR;
        name = "Dispute";
        began = step;
        // owning state links to the process and sets a strategy; that strategy establishes initial process parameters
        ProcessDisposition pdo = new ProcessDisposition(owner, this, began);
        pdo.setObjective(objective);
        pdo.setN(true);
        pdo.setU(true);
        pdo.setCommitment(force);
        pdo.setObjective(objective);
        // We must commit the resources before adding the process disposition to the owner's list of processes
        owner.addProcess(pdo);
        processParticipantLinks.add(pdo);
        // target state links to the process but has no strategy, yet. That's part of the process.
        ProcessDisposition pdt = new ProcessDisposition(target, this, began);
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
        System.out.println("This proc now at " + fiat);

        switch (statusSum) {
            case 1:
                this.updateStatus();
            case 2:
                System.out.println("New War Process at " + fiat);
                // outer if/then tests for equivalence
                // inner loop tests for participants' N; +N = escalate, -N = outcome
                for (ProcessDisposition p : processParticipantLinks) {
                    if (p.atN()) {
                        count += 1;
                    } else {
                        if (p.getOwner().willEscalate()) {
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
                if (worldOrder.random.nextGaussian() < 0.80) {
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
                WorldOrder.modelRun.addFacts(d);
                saveNearEntity(d);
                stop();
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
                    stop();
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
                stop();
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
                stop();
                break;
            case 10:
                // Starting the war is successful or not
                if (0.5 < simState.random.nextGaussian()) {
                    this.S = true;
                } else {
                    this.equivalence = true;
                }
                this.updateStatus();
                break;
            case 11:
                if (outcome) {
                    stop();
                }
                this.outcome = true;
                this.updateStatus();
                break;
            case 14:                // War breaks out.
                this.outcome = true;
                Long step = worldOrder.getStepNumber();
                worldOrder.schedule.scheduleRepeating(createInstitution(step));
                stop();
                break;
            case 15:                // Start at fiat 'A' and lot the process before we attach a War and ignore the process.
                if (outcome) {
                    // Each participant get's their commitment back, minus (arbitrary) 10% of the cost if the war
                    // can be averted.
                    for (ProcessDisposition p : processParticipantLinks) {
                        double t = (p.getCommitment().getTreasury() * 0.9);
                        p.getCommitment().setTreasury(t);
                        p.getOwner().getResources().increaseBy(p.getCommitment());
                    }
                    saveNearEntity(new Dispute(this));
                    stop();
                }
                this.outcome = true;
                this.updateStatus();
                stop();
                break;
        }

        // if the process has an outcome (and is not a war) log it; the main loop will kill logged, outcome procs.
        // TODO: Main loop must kill logged procs with an outcome.
    }



}
