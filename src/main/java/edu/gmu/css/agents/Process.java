package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

public abstract class Process implements Steppable, Stoppable {
    /** Binary version of Cioffi-Revilla `Canonical Process` Engine, dialectically
     *  The Omega digit reflects whether the outcome has been calculated
     *  The [SPC] digit reflects the external state
     *  The [UNK] digit reflects the internal state
     *
     *  [Omega] [SPC] [UNK]  status  Fiat Sum
     *      [0] [000] [001]  [0,0,1]   -   1    Both States are aware of the other, preliminary to the process; OBE
     *      [0] [001] [001]  [0,1,1]   -   2    A change/challenge occurs between participating States; initial condition for any process
     *      [0] [001] [011]  [0,1,3]   -   4    need to take action is recognized
     *      [0] [011] [011]  [0,3.3]   -   6    no action undertaken; change/challenge persists
     *      [0] [001] [111]  [0,1,7]   -   8    States prepare to act
     *      [0] [011] [111]  [0,3,7]   -   10   change/challenge persists
     *      [0] [111] [111]  [0,7,7]   -   14   Institution will be realized
     *      [1] [000] [001]  [1,0,1]   e   2    Stagnate relationship between 2 or more Polities, preliminary to the process; also OBE
     *      [1] [001] [001]  [1,1,1]   x   3    ...but need to respond does not exist
     *      [1] [001] [011]  [1,1,3]   E   5    need to take action is recognized
     *      [1] [011] [011]  [1,3.3]   X   7    no action undertaken; change/challenge persists
     *      [1] [001] [111]  [1,1,7]   W   9    action undertaken, change/challenge does not persist
     *      [1] [011] [111]  [1,3,7]   Z   11   action taken, change/challenge persists, no success
     *      [1] [111] [111]  [1,7,7]   A   15   action is successful; change/challenge resolves into new institution
     */

    protected Long id;
    protected boolean newNow; // The process fiat is newly set (has not been visited at this fiat already
    protected boolean S = false;
    protected boolean P = false;
    protected boolean C = true;
    protected boolean U = false;
    protected boolean N = false;
    protected boolean K = true;
    protected boolean equivalence = true; // has this process been evaluated for but not yet reached the next fiat?
    protected boolean outcome = false; // is there only one logical path remaining?
    protected char fiat = 'x';
    protected int age = 0;
    protected double effect;
    protected Long began;
    protected Long ended;
    protected Resources cost = new Resources.ResourceBuilder().build();
    protected Resources involvement = new Resources.ResourceBuilder().build();
    protected int[] status = new int[] {0, 0, 0};
    protected Domain domain;
    protected Stoppable stopper = null;
    protected Issue issue;
    protected String name;
    boolean stopped;
//    protected Institution institution;
    protected List<ProcessDisposition> processParticipantLinks = new LinkedList<>();

    public Process() {
    }

    public Process(SimState simState) {

    }

    public Long getId() {
        return id;
    }
    public boolean atC() {
        return C;
    }
    public boolean atN() {
        return N;
    }
    public boolean atU() {
        return U;
    }
    public boolean atP() {
        return P;
    }
    public boolean atS() {
        return S;
    }
    public boolean atE() {
        return equivalence;
    }
    public boolean isOutcome() {
        return outcome;
    }
    public char getFiat() {
        return fiat;
    }
    public boolean isNewNow() {
        return newNow;
    }
    public int[] getStatus() {
        return status;
    }
    public Resources getCost() {
        return cost;
    }
    public Resources getInvolvement() {
        return involvement;
    }
    public long getBegan() {
        return began;
    }
    public long getEnded() {
        return ended;
    }
    public Issue getIssue() {
        return issue;
    }
    public String getName() {
        return name;
    }
    public List<ProcessDisposition> getProcessDispositionList() {
        return processParticipantLinks;
    }
    public boolean addProcessParticipant(ProcessDisposition pd) {
        processParticipantLinks.add(pd);
        return true;
    }
    public Domain getDomain() {
        return domain;
    }
    public void setC(boolean challenge) {
        this.C = challenge;
    }
    public void setN(boolean needsSolution) {
        this.N = needsSolution;
    }
    public void setU(boolean undertakeAction) {
        this.U = undertakeAction;
    }
    public void setP(boolean persists) {
        this.P = persists;
    }
    public void setS(boolean success) {
        this.S = success;
    }
    public void setE(boolean equivalence) {
        this.equivalence = equivalence;
    }
    public void setOutcome(boolean outcome) {
        this.outcome = outcome;
    }
    public void setEquivalence(boolean eq) {
        this.equivalence = true;
    }
    public void setNewNow(boolean newNow) {
        this.newNow = newNow;
    }
    public void setCost(Resources cost) {
        this.cost = cost;
    }
    public void setIssue(Issue issue) {
        this.issue = issue;
    }
    public void setStopper(Stoppable stopper)   {this.stopper = stopper;}


    public void updateStatus() {
        // Canonical Process engine
        int internal = 0;
        int external = 0;
        // Assume _00
        if (this.outcome) {
            this.status[0] = 1;
        } else {
            this.status[0] = 0;
        }
        if (this.C) {
            external += 1;
        }
        if (this.P) {
            external += 2;
        }
        if (this.S) {
            external += 4;
        }
        if (this.K) {
            internal += 1;
        }
        if (this.N) {
            internal += 2;
        }
        if (this.U) {
            internal += 4;
        }

        this.status[1] = external;
        this.status[2] = internal;
        setFiat();
    }

    public int sumStatus() {
        int statusSum = 0;
        statusSum = Arrays.stream(status).sum();
        return statusSum;
    }

    public void setFiat() {
        // This process is designed to "rachet", meaning that the process will advance to the next potential fiat, even
        // if the conditions for equivalence and the outcome have not been met; only that the limitations of theee
        // previous fiat have been surpassed. For example: K, C, N, ~U will be classified as fiat E even before P/~P has been
        // evaluated.
        int [] assessableStatus = this.getStatus();

        if (assessableStatus[1] == 1) {
            if (assessableStatus[2] == 1) {         // 011 = 2, 111 = 3
                this.fiat = 'x';
            } else if (assessableStatus[2] == 3) {  // 013 = 4, 113 = 5
                this.fiat = 'E';
            } else if (assessableStatus[2] == 7) {  // 017 = 8, 117 = 9
                this.fiat = 'W';
            } else {
                this.fiat = '?';
            }
        }
        else if (assessableStatus[1] == 3) {        // 03_
            if (assessableStatus[2] == 3) {         // 033 = 6, 133 = 7
                this.fiat = 'X';
            }
            else if (assessableStatus[2] == 7) {    // 037 = 10, 137 = 11
                this.fiat = 'Z';
            } else {
                this.fiat = '?';
            }
        }
        else if (assessableStatus[1] == 7) {        // 07_
            if (assessableStatus[2] == 7) {         // 077 = 14, 177 = 15
                this.fiat = 'A';
            }
            else {
                this.fiat = '?';
            }
        }
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
//        long stepNum = worldOrder.schedule.getSteps();
        // TODO: stability is based on the sum of system-linked relationships with institutions
        // TODO: reduce the overall probability of war by their combined effect
        this.setFiat();
    }

    public void stop(){stopper.stop();}

    public void saveNearEntity(Entity o, WorldOrder wo) {
        /**
         *  Saves this Process to the database following the same pattern as data imports.
         *
         */
        WorldOrder worldOrder = wo;
        Dataset d = worldOrder.getModelRun();
        conclude(worldOrder);
    }

    protected void conclude(WorldOrder wo) {
        stopper.stop();
        stopped = true;
        wo.getAllTheProcs().remove(this);
        for (ProcessDisposition pd : processParticipantLinks) {
            pd.getOwner().removeProcess(pd);
        }
    }

}

