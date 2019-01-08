package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Organization;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.ProcessDisposition;
import edu.gmu.css.worldOrder.*;
import lombok.Builder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.util.Bag;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


@NodeEntity
public abstract class Process extends Entity implements Steppable, Serializable {
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

    @Id @GeneratedValue
    protected Long id;
    @Transient
    protected WorldOrder worldOrder;
    @Property
    protected boolean newNow;
    @Transient
    protected boolean S = false;
    @Transient
    protected boolean P = false;
    @Transient
    protected boolean C = true;
    @Transient
    protected boolean U = false;
    @Transient
    protected boolean N = false;
    @Transient
    protected boolean K = true;
    @Transient
    protected boolean equivalence = true; // is this fiat logically equivalent to an outcome? Initially equivalent to 'x'
    @Transient
    protected boolean outcome = false; // does the process die at the next step; run it's course?
    @Property
    protected char fiat = 'x';
    @Property
    protected int age = 0;
    @Transient
    protected double effect = WorldOrder.EFFECT;
    @Property
    protected Long began;
    @Property
    protected Long ended;
    @Transient
    protected double cost;
    @Transient
    protected int[] status = new int[]{0, 0, 0};
    @Property
    protected Domain domain;

    @Relationship(direction = "INCOMING")
    protected List<ProcessDisposition> processParticipantLinks = new ArrayList<>();


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
    public double getCost() {
        return cost;
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
    public void setNewNow(boolean newNow) {
        this.newNow = newNow;
    }
    public void setCost(double cost) {
        this.cost = cost;
    }




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
    }

    public void setFiat() {
        // This process is designed to "rachet", meaning that the process will advance to the next potential fiat, even
        // if the conditions for equivalence and the outcome have not been met; only that the limitations of theee
        // previous fiat have been surpassed. For example, KCN~U will be classified as fiat E even before P/~P has been
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
        worldOrder = (WorldOrder) simState;
        long stepNum = worldOrder.schedule.getSteps();
        // TODO: stability is the sum of system-linked relationships with institutions
        // TODO: reduce the overall probability of war by their combined effect
        this.setFiat();

    }

    public Institution createInstitution() {
        Institution institution;
        switch (domain) {
            case WAR:
                return institution = new War();
            case PEACE:
                return institution = new Peace();
            case TRADE:
                return institution = new Trade();
            case DIPLOMACY:
                return institution = new Diplomacy();
            case ALLIANCE:
                return institution = new Alliance();
            case STATEHOOD:
                return institution = new Statehood();
            default:
                return institution = null;
        }
    }

    public Organization createOrganization(Institution institution) {
        Organization organization = new Organization(institution);
        return organization;
    }



}
