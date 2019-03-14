package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Peace;
import edu.gmu.css.relations.InstitutionParticipation;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;

public class PeaceProcess extends Process {

    private Domain domain = Domain.PEACE;

    public PeaceProcess() {
    }

    public PeaceProcess(Institution i, Long from) {
        began = from;
        institution = i;
        for (InstitutionParticipation ip : i.getParticipation()) {
            ProcessDisposition pd = new ProcessDisposition(ip.getParticipant(), this, began);
        }
    }


    @Override
    public void step(SimState simState) {
        /** Switch on the current status
         *  A process unfolds from the perspective of targets, not the instigator (or the environment). A successful
         *  process averts the war while being prepared (N+U+P) to defend the state/polity.
         *  [Omega] [SPC] [UNK]  status  Fiat Sum
         *      [0] [001] [001]  [0,1,1]   -   2    A change/challenge occurs between participating States; initial condition for any process
         *      [1] [001] [001]  [1,1,1]   x   3    ...but need to respond does not exist
         *      [0] [001] [011]  [0,1,3]   -   4    need to take action will be recognized
         *      [1] [001] [011]  [1,1,3]   E   5    need to take action is recognized
         *      [0] [011] [011]  [0,3.3]   -   6    no action undertaken; change/challenge will persist
         *      [1] [011] [011]  [1,3.3]   X   7    no action undertaken; change/challenge persists
         *      [0] [001] [111]  [0,1,7]   -   8    States prepare to act
         *      [1] [001] [111]  [1,1,7]   W   9    action undertaken, change/challenge does not persist
         *      [0] [011] [111]  [0,3,7]   -   10   change/challenge persists
         *      [1] [011] [111]  [1,3,7]   Z   11   action taken, change/challenge persists, no success
         *      [0] [111] [111]  [0,7,7]   -   14   Institution will be realized
         *      [1] [111] [111]  [1,7,7]   A   15   action is successful; change/challenge resolves into new institution
         */
        worldOrder = (WorldOrder) simState;
        int count = 0;
        int statusSum = sumStatus();
        int numParticipants = processParticipantLinks.size();

        switch (statusSum) {
            case 2:
                // A war or conflict is ongoing, then at least one party initiates a peace overture.
                // Pole the participating polities: do they need peace?
                // If everybody agrees peace is needed, N=true, 4; else outcome=true because it's determinable
                count = 0;
                for (ProcessDisposition p : processParticipantLinks) {
                    if (p.atN()) {
                        count += 1;
                    } else {
                        if (p.getOwner().hasInsufficentResources(this)) {
                            p.setN(true);
                            count += 1;
                        }
                    }
                }

                if (count >= numParticipants) {
                    this.N = true;
                    this.equivalence = false;
                } else {
                    this.equivalence = true;
                }
                this.updateStatus();
                break;
            case 3:
                // Log this attempt to the database; the process just dies; nothing else happens
                stop();
                break;
            case 4:
                // Has the process reached a fiat of equivalence?
                // If not, have the participants even decided on the mutual need for peace?
                if (equivalence) {  // go test for P or ~P
                    ProcessDisposition pd  = processParticipantLinks.get(0);
                    if (pd.getOwner().evaluateNeedForPeace() ) {
                        this.P = true;
                        this.outcome = true;        // result in 'X', sums to 7
                    } else {
                        this.P = false;
                        this.outcome = true;        // result in 'E', sums to 5
                    }
                } else {            // test for U or ~U
                    count = 0;
                    for (ProcessDisposition p : processParticipantLinks) {
                        if (p.atU()) {
                            count += 1;
                        } else {
                            p.getOwner().makeConcessionForPeace();
                            if (p.atU()) {
                                count += 1;
                            }
                        }
                    }
                    if (count >= numParticipants) {
                        this.U = true;
                    } else {
                        this.equivalence = true;
                    }
                }
                break;
            case 5:
                if (equivalence) {
                    // Log this attempt at peace with the War/Conflict and leave it
                    outcome = true;
                    stop();
                } else {
                    ProcessDisposition pd = processParticipantLinks.get(0);
                    if (pd.getOwner().evaluateNeedForPeace() ) {
                        this.P = true;
                        this.equivalence = true;
                    } else {
                        this.P = false;
                        this.equivalence = true;
                    }
                }
                this.updateStatus();
                break;
            case 6:
                this.outcome = true;
                this.updateStatus();
                break;
            case 7:
                // Log this attempt at peace with the War/Conflict and leave it
                stop();
                break;
            case 8:
                // Test for P or ~P; evaluate to 9 or 10; P/10 is basically a cease fire
                this.equivalence = false;
                count = 0;
                for (ProcessDisposition pd : processParticipantLinks) {
                    // ideally, this is a probability threshold where y ~ p(win)*weight + p(tooManyLosses)*weight
                    // where p(win) = A.forces/B.forces :: 1/100..50/50..100/1 follows p=0.01..p=0.50..p=1.0
                    // TODO: calculate p(win)

                    double pWin = 0.0;
                    if (pWin > 0.5) {
                        count += 1;
                    }
                }
                if (count >=  numParticipants) {
                    this.P = true;
                } else {
                    this.outcome = true;
                }
                this.updateStatus();
                break;
            case 9:
                if (equivalence) {
                    // Log this attempt at peace with the War/Conflict and leave it
                    stop();
                } else {
                    this.equivalence = true;
                }
                this.updateStatus();
                break;
            case 10: // C and N and U and P
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
            case 14:
                this.equivalence = true;
                this.outcome = true;
                this.updateStatus();
                break;
            case 15:
                this.outcome = true;
                Long step = worldOrder.getStepNumber();
                createInstitution(step);
                stop();
                break;
        }
    }

    public Institution createInstitution() {
        return new Peace();
    }

}
