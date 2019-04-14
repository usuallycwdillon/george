package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.entities.*;
import edu.gmu.css.entities.Fact.FactBuilder;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.*;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


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
    protected boolean equivalence = true; // has this process been evaluated for but not yet reached the next fiat
    @Transient
    protected boolean outcome = false; // is there only one logical path remaining?
    @Property
    protected char fiat = 'x';
    @Property
    protected int age = 0;
    @Transient
    protected double effect = WorldOrder.institutionInfluence;
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
    @Transient
    protected Stoppable stopper = null;
    @Transient
    protected Entity issue; // the war, peace, trade, org, territory, etc.
    @Transient
    protected String name;
    @Transient
    boolean stopped;

    @Transient
    protected Institution institution;
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
    public long getBegan() {
        return began;
    }
    public long getEnded() {
        return ended;
    }
    public String getName() {
        return name;
    }

    public List<ProcessDisposition> getProcessDispositionList() {
        return processParticipantLinks;
    }
    public Domain getDomain() {
        return domain;
    }
    public void setWorldOrder(SimState simState) {
        this.worldOrder = (WorldOrder) simState;
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
    public void setInstitution(Institution i) {
        institution = i;
    }
    public WorldOrder getWorldOrder() {
        return this.worldOrder;
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
        // TODO: stability is based on the sum of system-linked relationships with institutions
        // TODO: reduce the overall probability of war by their combined effect
        this.setFiat();

    }

    public Institution createInstitution(Long step) {
        switch (domain) {
            case WAR:
                // Create a new war out of this process; mirrors WarMakingFact
                institution = new War(this);
                // Create an Institution Participation link out of each Process Disposition link
                for (ProcessDisposition d : processParticipantLinks) {
                    institution.addParticipation(new Participation(d, institution, worldOrder.getStepNumber()));
                }
                worldOrder.setGlobalWarLikelihood(processParticipantLinks.size() * WorldOrder.getInstitutionInfluence());
                return institution;
            case PEACE:
                institution = new Peace(this);
                for (ProcessDisposition d : processParticipantLinks) {
                    institution.addParticipation(new Participation(d, institution, worldOrder.getStepNumber()));
                }
                worldOrder.setGlobalWarLikelihood(processParticipantLinks.size() * WorldOrder.getInstitutionInfluence() * -1);
                return institution;
            case TRADE:
                institution = new Trade(this);
                for (ProcessDisposition d : processParticipantLinks) {
                    institution.addParticipation(new Participation(d, institution, worldOrder.getStepNumber()));
                }
                return institution;
            case DIPLOMACY:
                institution = new DiplomaticExchange(this);
                for (ProcessDisposition d : processParticipantLinks) {
                    institution.addParticipation(new Participation(d, institution, worldOrder.getStepNumber()));
                }
                return institution;
            case ALLIANCE:
                institution = new Alliance(this);
                for (ProcessDisposition d : processParticipantLinks) {
                    institution.addParticipation(new Participation(d, institution, worldOrder.getStepNumber()));
                }
                return institution;
            case STATEHOOD:
                institution = new Statehood(this);
                for (ProcessDisposition d : processParticipantLinks) {
                    institution.addParticipation(new Participation(d, institution, worldOrder.getStepNumber()));
                }
                return institution;
            default:
                return institution = null;
        }
    }

    public void setStopper(Stoppable stopper)   {this.stopper = stopper;}

    public void stop(){stopper.stop();}

    public void saveNearEntity(Object o) {
        /**
         *  Saves this Process to the database following the same pattern as data imports.
         *
         */
        Dataset d = WorldOrder.getModelRun();
        Fact f = new FactBuilder().name(this.name).from(began).until(worldOrder.getStepNumber())
                .subject(d.getFilename()).build();
        d.addFacts(f);
        conclude();
//        Neo4jSessionFactory.getInstance().getNeo4jSession().save(o, 1);
    }

    protected void conclude() {
        stopper.stop();
        stopped = true;
        WorldOrder.getAllTheProcs().remove(this);
    }



}
