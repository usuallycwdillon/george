package edu.gmu.css.agents;

import edu.gmu.css.data.*;
import edu.gmu.css.entities.*;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Stoppable;


public class WarProcess extends Process {
    private Domain domain = Domain.WAR;
    private War institution;

    public WarProcess() {
    }

    public WarProcess(Polity owner, Polity target, Resources force, SecurityObjective objective, Long step) {
        domain = Domain.WAR;
        name = "Conflict Process";
        began = step;
        // owning state links to the process and sets a strategy; that strategy establishes initial process parameters
        ProcessDisposition pdo = new ProcessDisposition(owner, this, began);
        pdo.setSide(0);
        pdo.setObjective(objective);
        owner.addProcess(pdo);
        processParticipantLinks.add(pdo);
        // target state links to the process but has no strategy, yet. That's part of the process.
        ProcessDisposition pdt = new ProcessDisposition(target, this, began);
        pdt.setSide(1);
//        pdt.learnPolityWarNeed();
        target.addProcess(pdt);
        processParticipantLinks.add(pdt);
        involvement.increaseBy(force);
        this.updateStatus();
    }

    public WarProcess(Issue i, Long s) {
        domain = Domain.WAR;
        name = "Conflict Process";
        began = s;
        issue = i;
        this.updateStatus();
    }


    @Override
    public void step(SimState simState) {
        /** Switch on the current status
         *  A process unfolds from the perspective of targets, not the instigator (or the environment). A successful
         *  process averts the war while being prepared (N+U+P) to defend the state/polity.
         *
         */
        WorldOrder worldOrder = (WorldOrder) simState;
        long step = worldOrder.getStepNumber();
        int count = 0;
        int statusSum = sumStatus();

        consumeResources(worldOrder);

        if (stopped) {
            worldOrder.getAllTheProcs().remove(this);
            processParticipantLinks = null;
            return;
        }
        switch (statusSum) {
            case 1:
                this.updateStatus();
                break;
            case 2:  // May evaluate to 3 or 4
                // Test for N. If all participants at N, set N true; otherwise, set outcome to true.
                this.setEquivalence(false);
                for (ProcessDisposition p : processParticipantLinks) {
                    if (p.atN()) {
                        count += 1;
                    } else {
                          if (p.getOwner().evaluateWarNeed(p, worldOrder)) count += 1;
                    }
                }
                if (count == processParticipantLinks.size() ) {     // Evaluates to 4
                    this.setN(true);
                    this.setEquivalence(true);
                } else {                                            // There is only one possible outcome
                    this.setOutcome(true);                          // Evaluate for 'x' next step
                }
                this.updateStatus();                                // Could move to 3- or 4
                break;
            case 3:  // Always evaluates to 'x'
                // If outcome, conclude; otherwise set outcome to true.
                // All (any) resources committed get returned. If A's strategy was Strike or SOF, end; otherwise,
                // toss a coin to see if B loses territory, resources, or an institution.
                if (outcome) {
                    this.conclude(worldOrder);
                    for (ProcessDisposition pd : processParticipantLinks) {
                        pd.getOwner().getResources().increaseBy(pd.getCommitment());
                    }
                    boolean defeat = (processParticipantLinks.get(0).getObjective().value > 3);
//                    if (worldOrder.random.nextBoolean() && defeat) { // neither a defeat objective nor random true
//
//                    }
                }
                break;
            case 4:  // May evaluate to 4-equivalence, 5-equivalence, 5 or 8
                // Test first for equivalence (NOT at this case before). If no equivalence, test for P; otherwise, ask
                // each polity to commit resources/willingness to undertake action (if they haven't already). A may
                // choose an asymmetric strategy if B is too powerful. If they commit their disposition is at U. If they
                // both (all) commit, the process progresses to 8; otherwise, to C & ~U (5 without outcome)
                if (!equivalence) {
                    if (issue.getDuration() > 0 && !issue.isStopped() ) {   // Evaluates to 6
                        this.setEquivalence(true);
                        this.setP(true);
                    } else {                                                // Evaluates to 5-
                        this.setOutcome(true);
                        this.setEquivalence(false);
                    }
                } else {
                    for (ProcessDisposition pd : processParticipantLinks) {
                        if (pd.atU()) {
                            count += 1;
                        } else {
                            if (pd.getOwner().evaluateWarWillingness(pd, worldOrder)) {
                                count += 1;
                            }
                        }
                    }
                    if (count == processParticipantLinks.size()) {          // Evaluates to 8
                        this.U = true;
                        this.setEquivalence(true);
                    } else {
                        this.setEquivalence(false);                         // Evaluates to 4-
                    }
                }
                this.updateStatus();
                break;
            case 5:  // Evaluates to 5+equivalence or E
                if (equivalence) {
                    returnStatesResources(worldOrder, true);
                    // log this as a dispute
                    ended = worldOrder.getStepNumber();
                    Dispute d = new Dispute(this);
                    worldOrder.getModelRun().addFacts(d);
                    this.saveNearEntity(d, worldOrder);
                    this.conclude(worldOrder);
                } else {
                    this.setEquivalence(true);
                }
                break;
            case 6:  // Always evaluates to 7 because ~U & P
                // Set outcome to true and return resources
                this.setOutcome(true);
                this.updateStatus();
                break;
            case 7: // This is X, conclude.
                // Target always loses depending on A's strategy
                boolean sd = (processParticipantLinks.get(0).getObjective().value > 2);
                boolean wd = (processParticipantLinks.get(0).getObjective().value > 3);
                if (sd) {
                    // target gives up something, depending on issue type
                } else if (wd){
                    // target polity dies, target territory joined to instigator's.
                }
                this.returnStatesResources(worldOrder, false);
                this.conclude(worldOrder);
                break;
            case 8:  // Evaluates to 9- or 10
                // Test for P. If P, move to 10; otherwise set equivalence to true
                if (issue.getDuration() > 0 && !issue.isStopped() ) {   // Evaluates to 10
                    this.setEquivalence(true);
                    this.setP(true);
                } else {                                                // Evaluates to 9-
                    this.setOutcome(true);
                    this.setEquivalence(false);
                }
                this.updateStatus();
                break;
            case 9:  // Always evaluates to W
                this.returnStatesResources(worldOrder, true);
                this.conclude(worldOrder);
                break;
            case 10: // Evaluates to 11 or 14
                // This case evaluates differently within the processDispositions of the instigator and the target:
                // success means war for the instigator and deterrence for the target.
//                for (ProcessDisposition pd : processParticipantLinks) {
//                    // Count polities on each that still need and want war after reconsidering the probability of
//                    // success. If it's the same as the size of those sides, this resolves to 14; otherwise, it
//                    // resolves to 11.
//                } // ...or we pretend and toss a coin..
                if (0.0 < worldOrder.random.nextGaussian()) {   // evaluates to 14
                    this.setS(true);
                    this.setOutcome(false);
                    this.setEquivalence(true);
                } else {                                        // evaluates to 11
                    this.setEquivalence(false);
                    this.setOutcome(true);
                }
                this.updateStatus();
                break;
            case 11:  // Evaluates to Z, record this process as a "dispute"
                this.setOutcome(true);
                this.ended = worldOrder.getStepNumber();
                saveNearEntity(new Dispute(this), worldOrder);
                this.returnStatesResources(worldOrder, true);
                this.conclude(worldOrder);
                break;
            case 14:  // Evaluates to 15
                this.setOutcome(true);
                this.updateStatus();
                break;
            case 15:  // Evaluates to A, a new war begins
                War w = createWar(worldOrder);  // Creates war, transfers commitments,
                worldOrder.getAllTheInstitutions().add(w);
                conclude(worldOrder);
                break;
        }
        return;
    }

    public War createWar(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        ended = worldOrder.getStepNumber();
        Stoppable stoppable;
        // Create a new war out of this process; mirrors WarMakingFact
        institution = new War(this);
        String warName = processParticipantLinks.get(0).getOwner().getName() + "-" +
                processParticipantLinks.get(1).getOwner().getName() + "_warOf_" + ended;
        WarFact warFact = new WarFact.FactBuilder().subject(warName)
                .object("Simulated War from " + worldOrder.getModelRun().getName())
                .war(institution).dataset(worldOrder.getModelRun()).build();
        institution.setWarFact(warFact);
        // Create a Participation Fact out of each Process Disposition link (which creates its own relations)
        for (ProcessDisposition d : processParticipantLinks) {
            WarParticipationFact wp = new WarParticipationFact.FactBuilder()
                    .subject(institution.getName())
                    .from(ended)
                    .polity(d.getOwner())
                    .war(institution)
                    .commitment(d.getCommitment())
                    .side(d.getSide())
                    .goal(d.getObjective())
                    .build();
        }
        stoppable = worldOrder.schedule.scheduleRepeating(institution);
        institution.setStopper(stoppable);
        worldOrder.updateGlobalWarLikelihood(processParticipantLinks.size() * worldOrder.getInstitutionInfluence());
        return institution;
    }

    private void returnStatesResources(WorldOrder wo, boolean all) {
        // return all committed war resources to state participants
        WorldOrder worldOrder = wo;
        if(all) {
            for (ProcessDisposition pd : processParticipantLinks) {
                Resources returnable = pd.getCommitment();
                Polity p = pd.getOwner();
                p.getResources().increaseBy(returnable);
            }
        } else {
            Polity instigator = issue.getInstigator();
            for (ProcessDisposition pd : processParticipantLinks) {
                if (pd.getOwner().equals(instigator)) {
                    instigator.getResources().increaseBy(pd.getCommitment());
                }
            }
        }
    }

    private void consumeResources(WorldOrder wo) {
        int weeks = wo.dataYear.getWeeksThisYear();
        for (ProcessDisposition pd : processParticipantLinks) {
            Resources c = pd.getCommitment();
            Polity p = pd.getOwner();
            if (c != null) {
                double myCost = (c.getTreasury() / weeks) * 2.0;
                c.decrementTreasury(myCost);
                cost.incrementTreasury(myCost);
                Resources req = new Resources.ResourceBuilder().treasury(myCost).build();
                p.getSecurityStrategy().addSupplemental(pd,req);
            }

        }
    }



}


