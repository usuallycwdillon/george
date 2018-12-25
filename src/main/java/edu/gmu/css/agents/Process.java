package edu.gmu.css.agents;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.ProcessDisposition;
import edu.gmu.css.worldOrder.*;
import lombok.Builder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.util.Bag;

import java.io.Serializable;
import java.util.HashSet;
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
    protected boolean C;
    @Transient
    protected boolean N;
    @Transient
    protected boolean U;
    @Transient
    protected boolean P;
    @Transient
    protected boolean S;
    @Transient
    protected boolean equivalence = false;
    @Transient
    protected boolean outcome = false;
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
    protected int[] status = new int[]{0, 1, 1};
    @Property
    protected Domain domain;

    @Relationship(direction = "INCOMING")
    private Set<ProcessDisposition> processParticipantLinks = new HashSet<>();


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


    public void setStatus() {
        // Process's Canonical engine
        int internal= 0;
        int external = 0;
        // Assume 00
        if (this.outcome == true) {
            this.status[0] = 1;
        }
        if (this.C == true) {
            external += 1;
        }
        if (this.N == true) {
            internal += 2;
        }
        if (this.U == true) {
            internal += 4;
        }
        if (this.P == true) {
            external += 2;
        }
        if (this.S == true) {
            external += 4;
        }
        this.status[1] = external;
        this.status[2] = internal;
    }

    public void setFiat() {
        int [] assessableStatus = this.getStatus();
        if (assessableStatus[0] > 0) {
            if (assessableStatus[1] == 1) {
                if (assessableStatus[2] == 1) {
                    this.fiat = 'x';
                } else if (assessableStatus[2] == 3) {
                    this.fiat = 'E';
                } else if (assessableStatus[2] == 7) {
                    this.fiat = 'W';
                } else {
                    this.fiat = '?';
                }
            }
            else if (assessableStatus[1] == 3) {
                if (assessableStatus[2] == 3) {
                    this.fiat = 'X';
                }
                else if (assessableStatus[2] == 7) {
                    this.fiat = 'Z';
                } else {
                    this.fiat = '?';
                }
            }
            else if (assessableStatus[1] == 7) {
                if (assessableStatus[2] == 7) {
                    this.fiat = 'A';
                }
                else {
                    this.fiat = '?';
                }
            }
        } else {
            this.fiat = '!';
        }
    }

    @Override
    public void step(SimState state) {
        WorldOrder worldOrder = (WorldOrder) state;
        long stepNum = worldOrder.schedule.getSteps();

        // TODO: stability is the sum of system-linked relationships with institutions
        // TODO: reduce the overall probability of war by their combined effect
        this.setFiat();

//        switch (this.fiat) {
//            case 'A': {
//                // Processes have institutions collect resources, check for relevance
//                for (Object eachOne : formedInstitutions) {
//                    Institution thisInstitution = (Institution) eachOne;
//                    thisInstitution.collectResources();
//                }
//            }
//            case 'Z': {
//                // Processes h
//                Institution resultingInstitution = new Institution(worldOrder, this);
//                resultingInstitution.collectResources();
//                this.formedInstitutions.add(resultingInstitution);
//            }
//            case 'W': {
//                // Processes create institutions (undertake to make peace)
//                double probabilityOfPeace = Math.pow(0.9, participatingStates.size());
//                if (probabilityOfPeace < 0.5) {
//                    setP(false);
//                }
//            }
//            case 'X': {
//                break;
//            }
//            case 'E': {
//                // If all participating states want peace, undertake negotiations for a settlement
//
//            }
//            case 'x': {
//                int allNeedPeace = 0;
//                // Ask participating states to consider whether they need peace
//                for (Object eachState : participants) {
//                    Polity thisState = (Polity) eachState;
//                    thisState.considerNeed();
//                    if (thisState.isNeedsPeace()) {
//                        allNeedPeace += 1;
//                    }
//                }
//                // If all participating neighbors need peace, set
//                if (allNeedPeace == participatingStates.size()) {
//                    this.setN(true);
//                    this.setStatus();
//                }
//            }
//            case 'e': {
//                break;
//            }
//            default: {
//                break;
//            }
//        }
    }

    public Institution createInstitution() {
        Institution institution;
        switch (domain) {
            case WAR:
                return institution = new War(worldOrder.getStepNumber());
            case PEACE:
                return institution = new Peace();
            case TRADE:
                return institution = new Trade();
            case DIPLOMACY:
                return institution = new Diplomacy();
            default:
                return institution = null;
        }
    }



}
