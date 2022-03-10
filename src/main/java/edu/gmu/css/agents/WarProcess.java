package edu.gmu.css.agents;

import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.*;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;

import java.util.Objects;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;
import static edu.gmu.css.worldOrder.WorldOrder.RECORDING;


public class WarProcess extends Process {
    private Domain domain = Domain.WAR;
    private War institution;
    private Dispute dispute; // not quite a war. ...at least not yet
    private boolean deadline = false;
    private ProcessDisposition firstPunch;
    private boolean nowFighting = false;

    public WarProcess() {
    }

    public WarProcess(Issue i, Long s) {
        domain = Domain.WAR;
        name = "Conflict Process";
        began = s;
        issue = i;
        Polity claimant = issue.getClaimant();
        Polity target = issue.getTarget();
        // link this state to the process and prepare security strategy
        ProcessDisposition pdc = new ProcessDisposition.Builder().from(this.began).owner(claimant)
                .process(this).side(0).need(true).build();
        processParticipantLinks.add( pdc );
        claimant.addProcess( pdc );
        // link the target to the process
        ProcessDisposition pdt = new ProcessDisposition.Builder().from(this.began).owner(target)
                .process(this).side(1).build();
        processParticipantLinks.add( pdt );
        target.addProcess( pdt );
        this.updateStatus();
    }


    @Override
    public void step(SimState simState) {
        /** Switch on the current status
         *  A process unfolds from the perspective of the system. A successful process resolves the issue.
         */
        WorldOrder worldOrder = (WorldOrder) simState;
        int count = 0;

         if (stopped) {
            worldOrder.getAllTheProcs().remove(this);
            processParticipantLinks = null;
            return;
        } else {
            consumeResources(worldOrder);
            if (issue == null || issue.getDuration() == 0) conclude(worldOrder);
        }

        for (ProcessDisposition p : processParticipantLinks) {
            if (p.atU() && p.getUt() == 0) {
                deadline = true;
                P = true;
            }
        }

        int statusSum = sumStatus();
        switch (statusSum) {
            case 1:
                this.updateStatus();
                break;
            case 2:  // May evaluate to 3 or 4
                /**
                 * State A has declared a need for military action against State B, which represents a change in the
                 * system. That need is not (yet) mutual--the system does not recognize a need for military action.
                 * State A's disposition (or that of some ally that joined the process) can continue to develop (from
                 * N to U, P, S) without State B or the system ever recognizing a need to manage the change A has caused.
                 *
                 * The when this process steps it may stay in the same condition (nothing changes), it may end because
                 * the issue has become mute, or it may end because A has taken military action. ...the result of which
                 * depends entirely on A's strategic objective.
                 */
                if (deadline || issue.isStopped() || issue.getDuration() == 0) {
                    // evaluate to 3 with consequences
                    outcome = true;
                } else {
                    count = 0;
                    for (ProcessDisposition p : processParticipantLinks) {
                        int thisStatus = p.developDisposition(this, worldOrder);
                        if (thisStatus >= 4) {
                            count++;
                        }
                    }
                    if (count == this.processParticipantLinks.size()) {
                        setN(true);
                        setOutcome(false);
                    }
                }
                this.updateStatus();                                // Could move to 3- or 4
                break;
            case 3:  // Always evaluates to 'x'
                /**
                 * This process will end this step or the next. If a state has already undertaken action and the D-day
                 * has arrived, there will be consequences. Otherwise, the process just ends here.
                 */
                if ((!Objects.isNull(this.institution) && this.institution.isStopped()) ||
                        (!Objects.isNull(this.dispute) && this.dispute.isStopped()) ) this.conclude(worldOrder);
                this.returnStatesResources(worldOrder, false);
                break;
            case 4:  // May evaluate to 4-equivalence, 5-equivalence, 5 or 8
                // Test first for equivalence (NOT at this case before). If no equivalence, test for P; otherwise, ask
                // each polity to commit resources/willingness to undertake action (if they haven't already). A may
                // choose an asymmetric strategy if B is too powerful. If they commit their disposition is at U. If they
                // both (all) commit, the process progresses to 8; otherwise, to C & ~U (5 without outcome)
                if (issue.isStopped() || issue.getDuration() == 0) {
                    if (!nowFighting) this.setOutcome(true);
                } else {
                    count = 0;
                    for (ProcessDisposition p : processParticipantLinks) {
                        int oldStatus = p.sumStatus();
                        int thisStatus = p.developDisposition(this, worldOrder);
                        if (thisStatus >= 8) {
                            count++;
                        }
                        if (oldStatus < thisStatus) {
                            if (Objects.isNull(dispute)) {
                                p.mobilizeCommitment();
                            }
                        }
                    }
                    if (count == this.processParticipantLinks.size()) {
                        this.U = true;
                        setOutcome(false);
                    }
                }
                this.updateStatus();                                // Could move to 3- or 4
                break;
            case 5:  // Evaluates to 5+equivalence or E
                for (ProcessDisposition p : processParticipantLinks) {
                    int thisStatus = p.developDisposition(this, worldOrder);
                    if (thisStatus == 10) {
                        this.setP(true);
                        this.setOutcome(false);
                        break;
                    }
                }
                if ((!Objects.isNull(this.institution) && this.institution.isStopped()) ||
                        (!Objects.isNull(this.dispute) && this.dispute.isStopped()) ) {
                    this.updateStatus();
                    this.returnStatesResources(worldOrder, false);
                    this.conclude(worldOrder);
                }
                break;
            case 6:  // Always evaluates to 7 because ~U & P
                // Set outcome to true and return resources
                this.setOutcome(true);
                this.updateStatus();
                break;
            case 7: // This is X, conclude.
                /**
                 * This process is inevitable
                 */
                if ((!Objects.isNull(this.institution) && this.institution.isStopped()) ||
                        (!Objects.isNull(this.dispute) && this.dispute.isStopped()) ) {
                    this.updateStatus();
                    this.returnStatesResources(worldOrder, false);
                    this.conclude(worldOrder);
                }
                break;
            case 8:  // Evaluates to 9- or 10
                // Test for P. If P, moves to 10;
                if (issue.getDuration() == 0 || issue.isStopped() ) {   // Evaluates to 9
                    setOutcome(true);
                } else {
                    for (ProcessDisposition p : processParticipantLinks) {
                        int thisStatus = p.developDisposition(this, worldOrder);
                        if (thisStatus == 10) {
                            setOutcome(false);
                            setP(true);             // Will evaluate to 10
                        }
                    }
                }
                this.updateStatus();
                break;
            case 9:  // Always evaluates to W
                this.returnStatesResources(worldOrder, false);
                this.conclude(worldOrder);
                break;
            case 10: // Evaluates to 11 or 14
                if (nowFighting) break;
                if (issue.isResolved()) {   // evaluates to 14
                    this.setS(true);
                }
                this.updateStatus();
                break;
            case 11:  // Evaluates to Z
                this.conclude(worldOrder);
                break;
            case 14:  // Evaluates to 15
                this.setOutcome(true);
                this.updateStatus();
                break;
            case 15:  // Evaluates to A, a new war begins
                conclude(worldOrder);
                break;
        }
        this.setFiat();
        return;
    }

    public Polity getEnemy(ProcessDisposition me) {
        for (ProcessDisposition p : processParticipantLinks) {
            if (p != me && p.getSide() != me.getSide()) {
                return p.getOwner();
            }
        }
        return null;
    }

    public ProcessDisposition getFirstPunch() {
        return firstPunch;
    }

    public void setFirstPunch(ProcessDisposition firstPunch) {
        this.firstPunch = firstPunch;
    }

    public boolean isNowFighting() {
        return nowFighting;
    }

    public void setNowFighting(boolean nowFighting) {
        this.nowFighting = nowFighting;
    }

    public War createWar(ProcessDisposition instigator, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Long weekNo = worldOrder.getWeekNumber();
        Dataset ds = worldOrder.getModelRun();
        StringBuilder labels = new StringBuilder(processParticipantLinks.get(0).getOwner().getName() + "-");
        labels.append(processParticipantLinks.get(1).getOwner().getName() + "_warOf_" + weekNo);

        this.institution = new War(this, weekNo);
        this.institution.setReferenceName(labels.toString());
        this.institution.setStopper(worldOrder.schedule.scheduleRepeating(institution));
        worldOrder.allTheInstitutions.add( this.institution);
        worldOrder.updateGlobalWarLikelihood(processParticipantLinks.size() * worldOrder.getInstitutionInfluence());

        WarFact warFact = new WarFact.FactBuilder()
                .from(weekNo)
                .until(weekNo + 1L)
                .subject(issue.getIssueType().value)
                .object(labels.toString())
                .name("Simulated War from " + worldOrder.getModelRun().getName())
                .magnitude(this.cost.getPax())
                .war(institution)
                .dataset(ds)
                .finalCost(this.cost.getTreasury())
                .build();
        this.institution.setWarFact(warFact);
        this.setNowFighting(true);
        if (dispute != null) dispute.getDisputeFact().setWar(warFact);
        if(RECORDING) new WarFactServiceImpl().createOrUpdate(warFact);
        // Create a Participation Fact out of each Process Disposition link (which creates its own relations)
        for (ProcessDisposition pd : processParticipantLinks) {
            Resources deployment = new Resources.ResourceBuilder().build();
            deployment.increaseBy(pd.getMobilized());
            WarParticipationFact f = new WarParticipationFact.FactBuilder()
                    .from(weekNo)
                    .until(weekNo + 1L)
                    .disposition(pd)
                    .polity(pd.getOwner())
                    .object(labels.toString())
                    .commitment(deployment)
                    .side(pd.getSide())
                    .war(institution)
                    .dataset(ds)
                    .initiated(instigator.equals(pd))
                    .build();
            this.institution.addParticipation(f);
            pd.getOwner().addWarParticipationFact(f);
            pd.getMobilized().zeroize();
            ds.addFacts(f);
            if(RECORDING) new WarParticipationFactServiceImpl().createOrUpdate(f);
        }
        if (DEBUG) System.out.println("New war: " + labels);
        return this.institution;
    }

    public Dispute createDispute(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Dataset ds = worldOrder.getModelRun();
        Long weekNo = worldOrder.getWeekNumber();
        StringBuilder labels = new StringBuilder(processParticipantLinks.get(0).getOwner().getName() + "-");
        labels.append(processParticipantLinks.get(1).getOwner().getName() + "_disputeOf_" + weekNo);

        this.dispute = new Dispute(this, weekNo);
        this.dispute.setStopper(worldOrder.schedule.scheduleRepeating( this.dispute));
        this.dispute.setReferenceName(labels.toString());
        worldOrder.updateGlobalWarLikelihood(processParticipantLinks.size() * worldOrder.getInstitutionInfluence());
        worldOrder.allTheInstitutions.add(this.dispute);
        this.dispute.setPlannedDuration(2 + worldOrder.random.nextInt(181));

        DisputeFact df = new DisputeFact.FactBuilder()
                .from(weekNo)
                .until(weekNo + 1L)
                .name("Simulated Dispute from " + worldOrder.getModelRun().getName())
                .subject(issue.getIssueType().value)
                .object(labels.toString())
                .dataset(ds)
                .dispute(this.dispute)
                .fiat(this.getFiat())
                .build();
        this.dispute.setDisputeFact(df);
        this.setNowFighting(true);
        if(RECORDING) new DisputeFactServiceImpl().createOrUpdate(df);

        Resources involvement = new Resources.ResourceBuilder().build();
        for (ProcessDisposition pd : processParticipantLinks) {
            Resources deployment = new Resources.ResourceBuilder().build();
            deployment.increaseBy(pd.getMobilized());
            DisputeParticipationFact f = new DisputeParticipationFact.FactBuilder()
                    .from(weekNo)
                    .until(weekNo + 1L)
                    .disposition(pd)
                    .subject(pd.getOwner().getName())
                    .object(labels.toString())
                    .dataset(ds)
                    .sideA(pd.getSide()==0)
                    .originatedDispute(pd.equals(firstPunch))
                    .commitment(deployment)
                    .polity(pd.getOwner())
                    .dispute(dispute)
                    .build();
            involvement.increaseBy(deployment);
            this.dispute.addParticipant(f);
            pd.getOwner().addDisputeParticipationFact(f);
            pd.getMobilized().zeroize();
            ds.addFacts(f);
            if(RECORDING) new DisputeParticipationFactServiceImpl().createOrUpdate(f);
        }
        dispute.setInvolvement(involvement);
        if (DEBUG) System.out.println("New dispute: " + labels);
        return this.dispute;
    }

    private void returnStatesResources(WorldOrder wo, boolean all) {
        // return all committed war resources to state participants
        WorldOrder worldOrder = wo;
        if (all) {
            if (!Objects.isNull(this.institution)) {
                for (WarParticipationFact f : institution.getParticipations()) {
                    f.getPolity().getResources().increaseBy(f.getCommitment());
                }
            }
            if (!Objects.isNull(this.dispute)) {
                for (DisputeParticipationFact f : dispute.getParticipations()) {
                    f.getPolity().getResources().increaseBy(f.getCommitment());
                }
            }
        } else {
            if (!Objects.isNull(this.institution)) {
                for (WarParticipationFact f : institution.getParticipations()) {
                    if (f.getDisposition().atS()) f.getPolity().getResources().increaseBy(f.getCommitment());
                }
            }
            if (!Objects.isNull(this.dispute)) {
                for (DisputeParticipationFact f : dispute.getParticipations()) {
                    if (f.getDisposition().atS()) f.getPolity().getResources().increaseBy(f.getCommitment());
                }
            }
        }
    }

    private void consumeResources(WorldOrder wo) {
        int weeks = wo.dataYear.getWeeksThisYear();
        for (ProcessDisposition pd : processParticipantLinks) {
            Resources c = pd.getCommitment();
            Polity p = pd.getOwner();
            if (c != null && !Objects.isNull(p)) {
                double myCost = (c.getTreasury() / weeks) * 2.0;
                p.getResources().decrementTreasury(myCost);
                cost.incrementTreasury(myCost);
                p.getMilExPer().incrementTreasury(myCost);
//                Resources req = new Resources.ResourceBuilder().treasury(myCost).build();
//                p.getSecurityStrategy().addSupplemental(pd,req);
            }
        }
    }

    public boolean saveInstitution(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Long weekNo = wo.getWeekNumber();
        if (institution != null) {
            worldOrder.updateGlobalWarLikelihood(processParticipantLinks.size() * worldOrder.getInstitutionInfluence());
            Dataset ds = worldOrder.getModelRun();
            StringBuilder labels = new StringBuilder(processParticipantLinks.get(0).getOwner().getName() + "-");
            labels.append(processParticipantLinks.get(1).getOwner().getName() + " warOf " + weekNo);
            WarFact warFact = new WarFact.FactBuilder().from(weekNo).subject(labels.toString())
                    .object("Simulated War from " + worldOrder.getModelRun().getName()).magnitude(this.cost.getPax())
                    .war(institution).dataset(ds).finalCost(this.cost.getTreasury()).build();
            institution.setName(labels.toString());
            institution.setWarFact(warFact);
            if (dispute != null) dispute.getDisputeFact().setWar(warFact);
            if(RECORDING) new FactServiceImpl().createOrUpdate(warFact);
            // Create a Participation Fact out of each Process Disposition link (which creates its own relations)
            for (ProcessDisposition pd : processParticipantLinks) {
                WarParticipationFact f = new WarParticipationFact.FactBuilder().from(weekNo)
                        .subject(pd.getOwner().getName()).object(labels.toString()).dataset(ds).build();
                institution.addParticipation(f);
                ds.addFacts(f);
                if(RECORDING) new FactServiceImpl().createOrUpdate(f);
            }
            return true;
        }
        return false;
    }

    public boolean saveNearEntity(WorldOrder wo) {
        /**
         *  Saves this Process to the database following the same pattern as data imports.
         *
         */
        WorldOrder worldOrder = wo;

        if (dispute != null) {
            worldOrder.updateGlobalWarLikelihood(processParticipantLinks.size() * worldOrder.getInstitutionInfluence());
            Dataset ds = worldOrder.getModelRun();

            int count = 0;

            StringBuilder labels = new StringBuilder(processParticipantLinks.get(0).getOwner().getName() + "-");
            labels.append(processParticipantLinks.get(1).getOwner().getName() + " disputeOf " + this.ended);

            DisputeFact df = new DisputeFact.FactBuilder().from(ended).subject(issue.getIssueType().value)
                    .object(labels.toString()).dataset(ds).dispute(dispute).fiat(this.getFiat()).build();
            dispute.setName(labels.toString());
            dispute.setDisputeFact(df);
            if(RECORDING) new FactServiceImpl().createOrUpdate(df);

            for (ProcessDisposition pd : processParticipantLinks) {
                DisputeParticipationFact f = new DisputeParticipationFact.FactBuilder().from(ended)
                        .subject(pd.getOwner().getName()).object(labels.toString()).dataset(ds).build();
                if(count == 0) {
                    f.setOriginatedDispute(true);
                    count++;
                }
                if (pd.getSide()==0) f.setSideA(true);
                dispute.addParticipant(f);
                ds.addFacts(f);
                if(RECORDING) new FactServiceImpl().createOrUpdate(f);
            }
            return true;
        }
        return false;
    }

    public War getInstitution() {
        return institution;
    }

    public void setInstitution(War institution) {
        this.institution = institution;
    }

    public Dispute getDispute() {
        return dispute;
    }

    public void setDispute(Dispute dispute) {
        this.dispute = dispute;
    }

    public boolean isDeadline() {
        return deadline;
    }

    public void setDeadline(boolean deadline) {
        this.deadline = deadline;
    }

    protected void updateFacts(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Long week = worldOrder.getWeekNumber();
        if (institution != null) {
            institution.updateForSave(worldOrder);
            institution.getWarFact().setFiat(this.fiat);
            institution.getWarFact().setUntil(week);
            institution.getWarFact().setSubject(issue.getFact().getName());
            if (RECORDING) new WarFactServiceImpl().createOrUpdate(institution.getWarFact());
            for (WarParticipationFact f : institution.getParticipations() ) {
                f.getDisposition().setFiat();
                f.setFiat(f.getDisposition().getFiat());
                f.setSubject(institution.getReferenceName());
                if (RECORDING) new WarParticipationFactServiceImpl().createOrUpdate(f);
                f.getPolity().removeWarParticipationFact(f);
                f.getPolity().addToOldWarsList(f);
            }
        } else if (dispute != null) {
            dispute.updateForSave(worldOrder);
            dispute.getDisputeFact().setFiat(this.fiat);
            if (RECORDING) new DisputeFactServiceImpl().createOrUpdate(dispute.getDisputeFact());
            for (DisputeParticipationFact f : dispute.getParticipations() ) {
                f.getDisposition().setFiat();
                f.setFiat(f.getDisposition().getFiat());
                f.setSubject(issue.getFact().getName());
                if (RECORDING) new DisputeParticipationFactServiceImpl().createOrUpdate(f);
                f.getPolity().removeDisputeParticipationFact(f);
            }
       } else {

       }
    }

    @Override
    public void conclude(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        /**
         *  Figure out what condition the process is in, save it appropriately, then clean up/delete.
         */
        stopper.stop();
        stopped = true;
        this.ended = worldOrder.getWeekNumber();
        this.updateFacts(worldOrder);
        this.returnStatesResources(worldOrder, false);
        wo.getAllTheProcs().remove(this);
        if (institution != null) {
            this.institution.setStopped(true);
            this.institution.stop();
            wo.getAllTheInstitutions().remove(this.institution);
            if (DEBUG) System.out.println(institution.getWarFact().getObject() + " has ended");
        }
        if (dispute != null) {
            this.dispute.setStopped(true);
            this.dispute.stop();
            wo.getAllTheInstitutions().remove(this.dispute);
            if (DEBUG) System.out.println(dispute.getDisputeFact().getObject() + " has ended");
        }
        for (ProcessDisposition pd : processParticipantLinks) {
            pd.getOwner().removeProcess(pd);
        }
//        if (DEBUG) {
//            if (institution != null) {
//                System.out.println();
//            }
//            if (dispute != null) {
//
//            }
//        }
    }



}


