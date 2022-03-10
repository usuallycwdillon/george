package edu.gmu.css.entities;


import edu.gmu.css.agents.*;
import edu.gmu.css.data.*;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.*;
import edu.gmu.css.util.Lanchester;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;

import static edu.gmu.css.data.SecurityObjective.ABIDE;
import static edu.gmu.css.data.SecurityObjective.ACCEPT;
import static edu.gmu.css.worldOrder.WorldOrder.*;

@NodeEntity
public class State extends Polity implements Steppable {
    /**
     *
     */
    @Id
    @GeneratedValue private Long id;
    @Property private String cowcode;
    @Property private String abb;
    @Transient private double liability;
    @Transient private double urbanPortion;
    @Transient private double treasury;
    @Transient protected Set<Polity> suzereinSet;
    @Transient protected double gdpLastYear = 0.0;
    @Transient private Double initialPopulation;
    @Transient private Map<Polity, NetworkFact> networkFactMap = new HashMap<>();
    @Transient private final Map<String, Object> varMap = new HashMap<>();

    @Relationship(type = "RELATION")
    List<NetworkFact> myForeignRelations = new ArrayList<>();
    @Relationship(type = "RELATION_TO")
    List<NetworkFact> relationsWithMe = new ArrayList<>();


    public State() {

    }


    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        // Document history
//        forcesHistory.add(resources.getPax());
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is already negative or NaN");
        }
        // Collect Taxes from Tiles and update the econ policy
        if (resources.getTreasury() < securityStrategy.getTotalDemand().getTreasury()) {
            collectTax();
        }
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative or NaN after collecting taxes");
        }
        // Implement security strategy, including deterrence mission and recruiting for any shortfalls;
        implementSecurityStrategy(worldOrder);
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative or NaN after implementing the security strategy");
        }
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getCowcode() {
        return cowcode;
    }

    public double getLiability() {
        return liability;
    }

    public double getUrbanPortion() {
        return urbanPortion;
    }

    public Set<Polity> getSuzereinSet() {
        return suzereinSet;
    }

    public void setSuzereinSet(Set<Polity> suzereinSet) {
        this.suzereinSet = suzereinSet;
    }

    public void addSuzerein(Polity suzerein) {
        suzereinSet.add(suzerein);
    }

    protected void implementSecurityStrategy(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        this.implementForeignStrategy();
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative after implementing the foreign policy mission");
        }

        for (WarParticipationFact f : warList) {
            ProcessDisposition pd = f.getDisposition();
            Resources force = f.getCommitment();
            Resources plan = pd.getCommitment();
            if (!pd.getMobilized().isEmpty()) {
                force.increaseBy(pd.getMobilized());
                pd.getMobilized().zeroize();
            }
//            if (!f.getCommitment().isSufficientFor(plan)) {
//                Resources gap = plan.evaluativeDifference(force);
//                securityStrategy.addSupplemental(f, gap);
//            }
        }

        for (DisputeParticipationFact f : disputeList) {
            ProcessDisposition pd = f.getDisposition();
            Resources force = f.getCommitment();
            Resources plan = pd.getCommitment();
            if (!pd.getMobilized().isEmpty()) {
                force.increaseBy(pd.getMobilized());
                pd.getMobilized().zeroize();
            }
//            if (!f.getCommitment().isSufficientFor(plan)) {
//                Resources gap = plan.evaluativeDifference(force);
//                securityStrategy.addSupplemental(f, gap);
//            }
        }

        this.implementDeterrenceMission();
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative after implementing the deterrence mission");
        }

        if (!securityStrategy.getSupplementalsSum().isEmpty()) this.processSupplementalForcesRequests();
    }

    public void processSupplementalForcesRequests() {
        Double some = 0.25; // Amount of force that can be mobilized during any week/step
        Deque<ImmutablePair<Object, Resources>> next = new LinkedList<>();
        Deque<ImmutablePair<Object, Resources>> supp = securityStrategy.getSupplementals();
        Resources totalRequest = securityStrategy.getSupplementalsSum(); // how much is wanted
        Resources available = resources.multipliedBy(some);              // how much could be used now
        Resources assignable = totalRequest.minimumBetween(available);   // minimum to be spent now

        if (supp.size() > 15) {
            System.out.println("This is a lot of new forces requests. ");
        }

        while (supp.size() > 0) {
            // find each request's proportion to the total requested and provide the same proportion of the assignable
            ImmutablePair<Object, Resources> p = supp.poll();
            Resources needed = p.getRight();
            if (p.getLeft().getClass()==ProcessDisposition.class) {
                ProcessDisposition proc = (ProcessDisposition) p.getLeft();
                if (!processList.contains(proc)) {
                    System.out.println("Removed an old process from the supplemental requests list");
                    continue;
                }
            }
            if (p.getLeft().getClass()==DisputeParticipationFact.class) {
                DisputeParticipationFact dispute = (DisputeParticipationFact) p.getLeft();
                if (!disputeList.contains(dispute)) {
                    System.out.println("Removed an old process from the supplemental requests list");
                    continue;
                }
            }
            if (p.getLeft().getClass()==WarParticipationFact.class) {
                WarParticipationFact war = (WarParticipationFact) p.getLeft();
                if (oldWars.contains(war)) {
                    System.out.println("Removed an old process from the supplemental requests list");
                    continue;
                }
            }

            Double[] ratio = needed.calculateRatios(totalRequest);       // ratios of this request to total of all requests
            // collect any returning/unused resources
            if (needed.getTreasury() < 0.0) {
                resources.incrementTreasury(Math.abs(needed.getTreasury()));
                needed.setTreasury(0.0);
            }
            if (needed.getPax() < 0.0) {
                resources.incrementPax(Math.abs(needed.getPax()));
                needed.setPax(0.0);
            }
            // skip this request if it's empty
            if (!needed.isEmpty()) {
                Resources allowable;

                if (assignable.applyRatios(ratio).isSufficientFor(needed) ) {
                    allowable = needed;
                } else {
                    allowable = available.applyRatios(ratio);
                }
                available.reduceBy(allowable);

                if (p.getLeft().getClass()==ProcessDisposition.class) {
                    ProcessDisposition caller = (ProcessDisposition) p.getLeft();
                    // the method for process dispositions also reduces state resources by allowable
                    caller.mobilizeCommitment(allowable);
                    if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                            resources.getTreasury().isNaN()) && DEBUG) {
                        System.out.println("Treasury is negative after committing forces to an evolving war process.");
                    }
                } else if (p.getLeft().getClass() == WarParticipationFact.class && !needed.isEmpty()) {
                    WarParticipationFact caller = (WarParticipationFact) p.getLeft();
                    // state resources are reduced here because active conflicts do not require forces to build-up during the conflict development process
                    this.resources.reduceBy(allowable);
                    caller.commitMore(allowable);
                    if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                            resources.getTreasury().isNaN()) && DEBUG) {
                        System.out.println("Treasury is negative after committing forces to a war.");
                    }
                } else if (p.getLeft().getClass() == DisputeParticipationFact.class && !needed.isEmpty()) {
                    DisputeParticipationFact caller = (DisputeParticipationFact) p.getLeft();
                    // state resources are reduced here because active conflicts do not require forces to build-up during the conflict development process
                    this.resources.reduceBy(allowable);
                    caller.commitMore(allowable);
                    if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                            resources.getTreasury().isNaN()) && DEBUG) {
                        System.out.println("Treasury is negative after committing forces to a dispute");
                    }
                }
                // TODO: Add else for fopo, borders, etc.
            }
        }

        // It's possible to recruit up to 1/8th of baseline security strategy on any week
        Double deficit = recruit();
        // finally, add any unmet requirements back into the queue of supplemental demands
        if (deficit > 0.0) {
            securityStrategy.renewSupplementals(next);
        }
    }

    @Override
    protected double recruit() {
        double deficit = 0.0;
        double current;
        // required new recruits are demand minus available resources
        Double requirement = securityStrategy.getTotalDemand().getPax() - resources.getPax();
        if (requirement > 0.0) {
            current = requirement / 4.0;
            double remaining = recruit(current);
            double drafted = current - remaining;
            deficit = requirement - drafted;
        } else if (requirement < -4.0) {
            double demob = Math.abs(requirement);
            current = demob / 4.0;
            demobilize(current);
            deficit = 0.0;
        } else {
            // don't add new requirements for the number of soldiers that need to demobilize. It's a really difficult bug to trace down.
            deficit = 0.0;
        }
        return deficit;
    }

    @Override
    protected double recruit(double f) {
        Double forceRequest = f;
        Double recruits = 0.0;
        Double deficit = 0.0;
        int attempts = 0;
        Set<Tile> popdTileLinks = territory.getPopulatedTileLinks();
        while (recruits < forceRequest && attempts < 3) {
            Double demand = forceRequest - recruits;
            Double forceRatio = demand / territory.getPopulationTrans();
            recruits += popdTileLinks.stream().mapToDouble(t -> t.supplySoldiers(forceRatio)).sum();
            attempts++;
        }
        resources.incrementPax(recruits);
        deficit = forceRequest - recruits;
        return deficit;
    }

    private void demobilize(double f) {
        Double force = f;
        resources.decrementPax(force);
        double terPop = territory.getCurrentPopulation();
        for (Tile t : territory.getPopulatedTileLinks()) {
            double pop = t.getPopulationTrans();
            double ratio = pop / terPop;
            double vets = ratio * force;
            double uPop = t.getUrbanPopTrans();
            t.setPopulationTrans(pop + vets);
//            t.getVarMap().put("incomingVets", vets);
            if (uPop > 0.0) { // most veteran soldiers return to urban areas, if there are any in that tile
                t.setUrbanPopTrans(uPop + (vets * 0.8));
//                t.getVarMap().put("incomingUrbanVets", (vets * 0.80));
            }
        }
    }

    private void implementDeterrenceMission() {
        // Do deterrence
        resources.decrementTreasury(securityStrategy.getWeeklyDeterrenceCost());
    }

    // TODO: Rewire this to consider current resources + (future income - future expenses)
    @Override
    public void updateEconomicPolicy(Leadership l, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        int weeks = wo.getWeeksThisYear();
        double oneWeekRatio = (weeks * 1.0) / (weeks - 1.0); // eg. 52/51, as in baseline over baseline after 1 week costs
        Double gap = 0.0;
        Double excess = 0.0;
        Double requirement = 0.0;
        Double rate = 0.0;
        Double baseline = securityStrategy.getBaseline().getTreasury();
        Double onHand = resources.getTreasury();
        Double supplementalDemand = securityStrategy.getSupplementalsSum().getTreasury();
        Double totalTreasuryDemand = baseline + supplementalDemand;
        if (this.leadership.equals(l)) {
            if (supplementalDemand > 0.0) {
                if (onHand * oneWeekRatio < totalTreasuryDemand) {
                    gap = (supplementalDemand / 4.0) + (baseline - onHand);
                    requirement = gap + baseline;
                    rate = requirement / this.getPublicSDP();
                } else {
                    if (onHand > (baseline * oneWeekRatio) + supplementalDemand) {
                        excess = onHand - ((baseline * oneWeekRatio) + supplementalDemand);
                        if (REINVEST) {
                            reinvest(excess);
                            rate = totalTreasuryDemand / this.getPublicSDP();
                        } else {
                            requirement = Math.max((totalTreasuryDemand - excess), 0.0);
                            rate = requirement / this.getPublicSDP();
                        }
                    } else {
                        rate = totalTreasuryDemand / this.getPublicSDP();
                    }
                }
            } else {
                if (onHand * oneWeekRatio < baseline) {
                    gap = baseline - (onHand * oneWeekRatio);
                    requirement = gap + baseline;
                    rate = requirement / this.getPublicSDP();
                } else {
                    if (onHand > baseline * oneWeekRatio) {
                        excess = onHand - (baseline * oneWeekRatio);
                        if (REINVEST) {
                            rate = (baseline * oneWeekRatio) / this.getPublicSDP();
                            reinvest(excess);
                        } else {
                            requirement = Math.max(onHand - excess, 0.0);
                            rate = requirement / this.getPublicSDP();
                        }
                    } else {
                        rate = baseline / this.getPublicSDP();
                    }
                }
            }
            economicPolicy.setTaxRate(rate);
        }
    }

    private void reinvest(Double d) {
        Double invest = d;
        resources.decrementTreasury(invest);
        double pci = invest / territory.getPopulationTrans();

        if (territory.getPopulatedTileLinks().size() > 250) {
            territory.getPopulatedTileLinks().stream().forEach(t -> t.takeInvestment(pci));
        } else {
            for (Tile t : territory.getPopulatedTileLinks()) {
                t.takeInvestment(pci);
            }
        }

        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative, null or NaN after investing excess treasury to the tiles");
        }
    }

    public void recordSimulationHistory(WorldOrder wo) {
        territory.updateTotals();
//        if (territory.getGdp() * 10 < territory.getGdpTrans() ) {
//            System.out.println(this.name + "'s GDP has grown very large");
//        }

        if (RECORDING) {
            WorldOrder worldOrder = wo;
            Dataset run = worldOrder.getModelRun();
            Year dataYear = worldOrder.getDataYear();
            PopulationFact pf = new PopulationFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(territory.getCurrentPopulation())
                    .during(dataYear)
                    .build();
//            run.addFacts(pf);
            new FactServiceImpl().createOrUpdate(pf);

            UrbanPopulationFact uf = new UrbanPopulationFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(territory.getCurrentUrbanPopulation())
                    .during(dataYear)
                    .build();
            new FactServiceImpl().createOrUpdate(uf);

            this.gdpLastYear = territory.getGrossDomesticProductLastYear();
            GdpFact gf = new GdpFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(this.gdpLastYear)
                    .during(dataYear)
                    .build();
            gdpHistory.add(gf);
            new FactServiceImpl().createOrUpdate(gf);

            MilExFact mxf = new MilExFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(milExPer.getTreasury())
                    .during(dataYear)
                    .build();
            new FactServiceImpl().createOrUpdate(mxf);

            MilPerFact mpf = new MilPerFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(milExPer.getPax())
                    .during(dataYear)
                    .build();
            new FactServiceImpl().createOrUpdate(mpf);
            this.resetMilExPer();

            SatisfactionFact satisfactionFact = new SatisfactionFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(this.getTerritory().getSatisfaction())
                    .during(dataYear)
                    .build();
            new FactServiceImpl().createOrUpdate(satisfactionFact);

            // diplomatic exchange
            for (DipExFact dxf : this.getRepresentation() ) {
                NetworkFact f;
                Polity p = dxf.getPolity();
                if (networkFactMap.containsKey(p)) {
                    f = networkFactMap.get(p);
                    f.setMyDiplomaticStrength(dxf.getInstitution().getStrength());
                    f.setRelativeDiplomaticStrength(this.getAverageDiplomaticStrength());
                    networkFactMap.put(p, f);
                } else {
                    Year yr = worldOrder.getDataYear();
                    f = new NetworkFact.FactBuilder()
                            .me(this)
                            .them(p)
                            .dataset(run)
                            .subject(this.getName())
                            .object(p.getName())
                            .from(yr.getBegan())
                            .thisYear(yr.getIntYear())
                            .until(yr.getEnded())
                            .mySDP(territory.getCurrentSDP())
                            .relativeSDP(this.getOurRelativeSDP(p))
                            .myDiplomaticStrength(dxf.getInstitution().getStrength())
                            .relativeDiplomaticStrength(this.getAverageDiplomaticStrength())
                            .build();
                    networkFactMap.put(p, f);
                }
            }

            // alliances
            for (Polity p : this.getAlliancePartners()) {
                NetworkFact f;
                Double allianceStrength = this.getAverageAllianceStrengthWith(p);
                if (networkFactMap.containsKey(p)) {
                    f = networkFactMap.get(p);
                    f.setMyAllianceStrength(allianceStrength);
                    f.setRelativeAllianceStrength(allianceStrength / this.getAverageAllianceStrengths());
                    networkFactMap.put(p, f);
                } else {
                    Year yr = worldOrder.getDataYear();
                    f = new NetworkFact.FactBuilder()
                            .me(this)
                            .them(p)
                            .dataset(run)
                            .subject(this.getName())
                            .object(p.getName())
                            .from(yr.getBegan())
                            .thisYear(yr.getIntYear())
                            .until(yr.getEnded())
                            .mySDP(territory.getCurrentSDP())
                            .relativeSDP(this.getOurRelativeSDP(p))
                            .myAllianceStrength(allianceStrength)
                            .relativeAllianceStrength(allianceStrength / this.getAverageAllianceStrengths())
                            .build();
                    networkFactMap.put(p, f);
                }
            }

            for (Map.Entry<Polity, NetworkFact> e : networkFactMap.entrySet()) {
                if (DEBUG) new FactServiceImpl().createOrUpdate(e.getValue());
            }
            networkFactMap = new HashMap<>();
        }
    }

    public Double getAverageDiplomaticStrength() {
        double total = 0.0;
        int count = 0;
        for (DipExFact f : this.getRepresentation()) {
            total += f.getInstitution().getStrength();
            count += 1;
        }
        return total / count;
    }

    public Double getAverageAllianceStrengths() {
        double total = 0.0;
        int count = 0;
        for (AllianceParticipationFact f : alliances) {
            count+=1;
            total+= f.getAlliance().getStrength();
        }
        return total / count;
    }

    public Double getAverageAllianceStrengthWith(Polity p) {
        double total = 0.0;
        int count = 0;
        for (AllianceParticipationFact f : alliances) {
            Alliance a = f.getAlliance();
            for (AllianceParticipationFact apf : a.getAllianceParticipations()) {
                if (apf.getPolity().equals(p)) {
                    total += a.getStrength();
                    count += 1;
                }
            }
        }
        return total / count;
    }

    private List<Polity> getAlliancePartners() {
        List<Polity> partners = new ArrayList<>();
        for (AllianceParticipationFact f : alliances) {
            Alliance alliance = f.getAlliance();
            for (AllianceParticipationFact pf : alliance.getAllianceParticipations()) {
                Polity p = pf.getPolity();
                if (!p.equals(this) && !partners.contains(p) && alliance.getStrength() > 0.0) {
                    partners.add(p);
                }
            }
        }
        return partners;
    }

    @Override
    public boolean resolveIssue(WorldOrder wo, Issue i) {
    /**
     * If claimant has dipex with target, random chance determines whether dipex is strong enough to resolve issue or to
     * start a new dipexProc. If the dipex is strong enough, test if there is an existing alliance.
     *
     */
        WorldOrder worldOrder = wo;
        Issue issue = i;
        if(WorldOrder.DIPEX) {
            if(existsDipEx(i.getTarget())) {
                DiplomaticExchange de = hasDipEx(i.getTarget());
                if(WorldOrder.ALLIANCES) {
                    if(existsAlliance(i.getTarget())) {
                        Alliance a = hasAlliance(i.getTarget());
                        if(resolvedThroughAlliance(worldOrder, issue, a)) {
                            // set issue.proc to allianceProc, ++alliance.strength (done inside T resolvedThruAlliance method),
                            // ++dipex.strength, saveOut facts, stop issue, return true.
                            de.setStrength(1.0 - ( (1.0 - de.getStrength()) * worldOrder.getInstitutionStagnationRate() ) );
                            i.conclude(worldOrder);
                            return true;
                        }
                    }
                }
                if(resolvedThroughDiplomacy(worldOrder, issue, de)) {
                    // set issue.proc to dipex, ++dipex.strength, saveOut facts, stop issue, return true;
                }
            } else {
                if(evaluateBeginDipEx(worldOrder, issue)) {
                    //set issue.proc to dipex, return true;
                }
            }
        }

        if(evaluateWarNeed(worldOrder, issue)) {
            // if true, the war proc is linked to the issue; method for claimant
            WarProcess wp = this.initiateWarProcess(worldOrder, issue);
            ProcessDisposition pd = wp.getProcessDispositionList().get(0);
            pd.setN(true);
            pd.setObjective( leadership.chooseSecurityObjective(issue, worldOrder) );
            worldOrder.allTheProcs.add(wp);
            return true;
        }
        // returns false if State apparatus resolves nothing, so the issue continues to irritate the claimant
        return false;
    }

    @Override
    public boolean evaluateWarNeed(WorldOrder wo, Issue i) {
        /**
         * The claimant polity has a new Issue (Change occurs) and must decide whether they perceive a need to take action.
         * Conceptually, the ProbabilisticCausality agent creates the issue and the ProcessDisposition directly, and the
         * ProcessDisposition contains the logic about whether the polity perceives a need to take military action over the
         * new Issue, after some initial analysis of the threat.
         *
         * The fundamental question is whether resolving the Issue
         * is worth the violence and cost of military action.
         * @param WorldOrder simState object
         * @param Issue that may be resolved by violence
         * @return boolean
         */
        WorldOrder worldOrder = wo;
        Issue issue = i;
        if (WorldOrder.RANDOM) {
            return worldOrder.random.nextBoolean();
        } else {
            if (!territory.getCommonWeal().getEntityPositionMap().containsKey(issue)) {
                this.territory.getCommonWeal().addIssue(issue, worldOrder);
            }
            return (this.leadership.evaluateWarNeed(issue, worldOrder) >  warParams.get("WAR_NEED_MIN"));
        }
    }

    @Override
    public boolean evaluateWarNeed(ProcessDisposition pd, WorldOrder wo) {
        /**
         * Process participants that already have a process disposition use an alternate method signature.
         *
         * The target polity has a new Challenge (Change occurs) and must decide whether they perceive a need to take action.
         * Conceptually, the challenge comes from a claimant polity that has an Issue with this target.
         *
         * The fundamental question is whether there is a need to defend against the possible violence from the claimant
         * polity.
         *
         * @param pd (created by the process) that links this polity to the process
         * @param wo simState object
         * @return boolean if N condition at the PD is now true.
         */
        //
        // TODO: make the decision based on possible consequences
        WorldOrder worldOrder = wo;
        ProcessDisposition proc = pd;
        Issue issue = proc.getProcess().getIssue();
        if (WorldOrder.RANDOM) {
            if (worldOrder.random.nextBoolean()) {
                proc.setN(true);
                proc.setObjective( leadership.chooseSecurityObjective(issue, worldOrder) );
                return true;
            } else {
                return false; // Canonical x, Wright's ~A (failure to resist)
            }
        } else {
            double threshold = warParams.get("WAR_NEED_MIN");
            if (((WarProcess) pd.getProcess()).getInstitution() != null) {
                threshold = threshold * (1.0 + wo.random.nextDouble() );
            }
            if (this.leadership.evaluateWarNeed(issue, wo) > threshold) {
                if (Objects.equals(this.cowcode, "225")) {
                    if (proc.getEnemyDisposition().getObjective().value > 3) mobilizeTheReserves(issue);
                }
                proc.setN(true);
                proc.setObjective( leadership.chooseSecurityObjective(issue, worldOrder) );
                return true;
            }
            return false;  // Canonical x, Wright's ~A (failure to resist)
        }
    }

    /**
     * An alliance partner has prompted a process to determine whether this polity will join a war or war process
     *
     * The fundamental question is whether there is a need to support the alliance partner in their struggle
     *
     * @param p the WarProcess that prompted this question
     * @param wo simState object
     * @param s the side to join if the answer is yes.
     * @return boolean if N condition at the PD is now true.
     */
    public boolean evaluateWarNeed(WarProcess p, WorldOrder wo, int s, Alliance a) {
        WorldOrder worldOrder = wo;
        WarProcess process = p;
        Issue issue = process.getIssue();
        Alliance alliance = a;
        Long step = worldOrder.getWeekNumber();
        int whichSide = s;
        boolean yes = false;
        if (WorldOrder.RANDOM) {
            if (worldOrder.random.nextBoolean());
        } else {
            this.territory.getCommonWeal().addIssue(issue, worldOrder);
            boolean strong = worldOrder.random.nextBoolean( alliance.getStrength() );
            boolean need = this.leadership.evaluateWarNeed(issue, worldOrder) >  warParams.get("WAR_NEED_MIN");
            if (strong && need) {
                yes = true;
                alliance.setStrength(1.0 - ( (1.0 - alliance.getStrength()) * worldOrder.getInstitutionStagnationRate() ) );
            } else {
                yes = false;
                alliance.setStrength(1.0 - ( (1.0 - alliance.getStrength()) / worldOrder.getInstitutionStagnationRate() ) );
            }
        }
        if (yes) {
            SecurityObjective o = leadership.chooseSecurityObjective(issue, worldOrder);
            ProcessDisposition pda = new ProcessDisposition.Builder()
                    .process(process)
                    .from(step)
                    .until(step + 1L)
                    .side(whichSide)
                    .owner(this)
                    .objective(o)
                    .need(true)
                    .build();
            process.addProcessParticipant(pda);
            return true;
        } else {
            return false;
        }
    }


    @Override
    public boolean evaluateWarWillingness(ProcessDisposition pd, WorldOrder wo) {
        /**
         * Is the Polity willing to undertake action (commit resources) for this conflict?
         * 1. Is the leadership willing (tax, recruit, etc) ?
         * 2. Is the commonWeal willing (pay tax, get drafted, ect) ?
         * @param pd ProcessDisposition linking to the war process
         * @param wo WorldOrder simState object
         */
        Issue i = pd.getProcess().getIssue();
        Polity enemy;

        if (pd.getSide() == 0) {
            enemy = pd.getProcess().getIssue().getTarget();
        } else {
            enemy = pd.getProcess().getIssue().getClaimant();
        }
        SecurityObjective response = pd.getObjective();

        double threshold = warParams.get("WAR_WILLING_MIN");
        if ( ((WarProcess) pd.getProcess()).getInstitution() != null) {
            threshold = threshold - wo.random.nextDouble();
            this.seekAlliedAssistance(pd, wo);
            response = SecurityObjective.name(Math.min(5,pd.getEnemyDisposition().getObjective().value + 1));
        }

        if (response == null || (pd.getEnemyDisposition().atN() && pd.getEnemyDisposition().getObjective().value > response.value) ) {
            response = leadership.chooseSecurityObjective(i, wo);
        }
        boolean defending = (response.value == 3 || response.value == 5);

        if (leadership.evaluateWarWillingness(i, wo) > threshold && response.value >= 0 && !pd.atU()) {
            Resources strategy = developWarStrategy(enemy, response, wo);
            if  (!resources.isSufficientFor(strategy)) {
                mobilizeTheReserves(pd);
            }
            pd.commit(strategy);
            if (!strategy.isEmpty()) {
                if (response.value > 3) {
                    this.securityStrategy.addSupplemental(pd,strategy);
                    this.processSupplementalForcesRequests();
                } else {
                    pd.mobilizeCommitment();
                }
            }

            int hops = 1;
            int weeks = 1;
            int pace = wo.getMarchingPace();
            if (!defending ) {
                Territory enemyTerritory = enemy.getTerritory();
                Map<String, Object> attackPath = new AttackPathImpl().findAttackPath(territory, enemyTerritory, wo);
                pd.setAttackPath(attackPath);
                if (DEBUG) System.out.println("attacking from " + territory.getMapKey() + " to " + enemyTerritory.getMapKey());
                hops = ((Number) attackPath.get("hops")).intValue();
                weeks = Math.max( (hops + pace - 1) / pace, 1);
                pd.setUt( weeks );
            } else {
                Map<String, Object> defensePath = new HashMap<>();
                if (Objects.nonNull(pd.getEnemyDisposition().getAttackPath(wo))) {
                    defensePath.put( "finish", pd.getEnemyDisposition().getAttackPath(wo).get("finish") );
                }
                hops = (int) (Math.sqrt(territory.getRadius()));
                defensePath.put("hops", hops);
                pd.setAttackPath(defensePath);
                weeks = Math.max( (hops + pace - 1) / pace, 1);
                pd.setUt(weeks);
            }
        } else {
            if (pd.getSide()==0) {
                pd.setObjective(ABIDE);
            } else {
                pd.setObjective(ACCEPT);
            }
            pd.setU(false);
        }
        return pd.atU();
    }



    private WarProcess initiateWarProcess(WorldOrder wo, Issue i) {
        /**
         * Create a new war process if the claimant decides they need to resolve the Issue with military action (may not
         * actually be a war; it could be strike or a show of force), but that objective needs to be declared so that the
         * target knows what they're facing.
         * @param wo WorldOrder
         * @param i Issue
         * @return boolean whether a new war process has been created and both polities have a disposition toward it.
         */
        WorldOrder worldOrder = wo;
        Issue issue = i;
        long step = worldOrder.getWeekNumber();
        WarProcess proc = new WarProcess(issue, step);
        issue.setProcess(proc);
        worldOrder.addProc(proc);
        proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));
        return proc;
    }


    @Override
    public boolean resolvedThroughAlliance(WorldOrder wo, Issue i, Alliance a) {
        Alliance alliance = a;
        WorldOrder worldOrder = wo;
        Issue issue = i;
        double r = worldOrder.random.nextDouble();
        if (alliance.getAllianceType()==AllianceType.ENTENTE) {
            r = Math.max(r / 0.98, 0.80);
        } else if (alliance.getAllianceType()==AllianceType.NONAGGRESSION) {
            r = Math.max(r / 0.90, 0.90);
        } else if (alliance.getAllianceType()==AllianceType.DEFENSE) {
            r = Math.max(r / 0.80, 0.99);
        }
        if (alliance.getStrength() >= r) {
            alliance.setStrength(1.0 - ( (1.0 - alliance.getStrength()) * worldOrder.getInstitutionStagnationRate() ) );
            return true;
        } else {
            alliance.setStrength(1.0 - ( (1.0 - alliance.getStrength()) / worldOrder.getInstitutionStagnationRate() ) );
            return false;
        }
    }

    public boolean seekAlliedAssistance(ProcessDisposition pd, WorldOrder wo) {
        ProcessDisposition disposition = pd;
        Polity p = disposition.getEnemy();
        WorldOrder worldOrder = wo;
        Map<Double, Alliance> alliances = this.findAlliancesAgainst(p);
        boolean help = false;

        if (alliances.size() > 0) {
            for (Alliance a : alliances.values()) {
                if (a.getAllianceType()==AllianceType.DEFENSE) {
                    for (AllianceParticipationFact ally : a.getAllianceParticipations() ) {
                        State friend = (State) ally.getPolity();
                        if (!Objects.equals(this, friend) && !Objects.equals(p, friend) ) {
                            WarProcess wp = (WarProcess) disposition.getProcess();
                            help = friend.evaluateWarNeed(wp, worldOrder, disposition.getSide(), a);
                        }
                    }
                }
            }
        }
        return help;
    }

    @Override
    public boolean resolvedThroughDiplomacy(WorldOrder wo, Issue i, DiplomaticExchange d) {
        DiplomaticExchange de = d;
        WorldOrder worldOrder = wo;
        double r = worldOrder.random.nextDouble();
        if (de.getStrength() <= r ) {
            de.setStrength(1.0 - ( (1.0 - de.getStrength()) * worldOrder.getInstitutionStagnationRate() ) );
            return true;
        } else {
            de.setStrength(1.0 - ( (1.0 - de.getStrength()) / worldOrder.getInstitutionStagnationRate() ) );
            return false;
        }
    }

    @Override
    public boolean evaluateBeginDipEx(WorldOrder wo, Issue i) {
        return false;
    }

    @Override
    public boolean defenseNeed(ProcessDisposition pd, WorldOrder wo) {
        return false;
    }

    @Override
    public boolean evaluateNeedForPeace(WorldOrder wo, Issue i) {
        WorldOrder worldOrder = wo;
        Issue issue = i;
        War war = (War) issue.getCause();
        if (WorldOrder.RANDOM) {
            return worldOrder.random.nextBoolean();
        } else {
            if (!territory.getCommonWeal().getEntityPositionMap().containsKey(war)) {
                this.territory.getCommonWeal().addWar(war, worldOrder);
            }
            territory.getCommonWeal().socialize(war, worldOrder);
            return (this.leadership.evaluatePeaceNeed(war, worldOrder) < 0.25);
        }
//        for (WarParticipationFact wpf : warList) {
//            if (wpf.getWar().equals(war)) {
//                double lo = leadership.considerPeace(wpf, worldOrder);
//                double po = territory.commonWeal.evaluateNeedForPeace(wpf);
//                double threshold = worldOrder.random.nextDouble();
//                double meanOpinion = evaluatePolityResolve(lo, po);
//                if (meanOpinion > threshold) {
//                    PeaceProcess proc = new PeaceProcess(this, issue, wo.getWeekNumber() );
//                    issue.setProcess(proc);
//                    worldOrder.addProc(proc);
//                    proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));
//                    for (WarParticipationFact f : war.getParticipations()) {
//                        ProcessDisposition pd = new ProcessDisposition.Builder().owner(f.getPolity()).process(proc).build();
//                    }
//                    return true;
//                } else {
//                    return false;
//                }
//            }
//        }
//        return false;
    }

    public boolean evaluateNeedForPeace(ProcessDisposition pd) {
        return true;
    }



    @Override
    public boolean evaluateAttackSuccess(ProcessDisposition pd) {
        WarProcess wp = (WarProcess) pd.getProcess();
        double commitment = pd.getCommitment().getPax();
        double magnitude = wp.getInvolvement().getPax();
        int extent = wp.getProcessDispositionList().size();
        return magnitude / extent < commitment;
    }


    public boolean evaluateDefensePactImplementationNeed(Polity p, Issue i) {
        return false;
    }

    @Override
    public boolean willRelent(ProcessDisposition mine, ProcessDisposition theirs, WorldOrder wo) {
        // if my force is less than half the size of the ene
        int objective = mine.getObjective() == null ? -3 : mine.getObjective().value;
        if (objective < 0) return true;
        double forceConcentration;
        if (mine.getSide() % 2 == 1) { // I'm defending
            forceConcentration = new Lanchester( // defenders get 2x advantage
                    mine.getCommitment().multipliedBy(2), theirs.getCommitment()).calculateAttackForceConcentration();
        } else { // I'm attacking
            forceConcentration = new Lanchester( // defenders get 2x advantage
                    mine.getCommitment(), theirs.getCommitment().multipliedBy(2)).calculateAttackForceConcentration();
        }
        if (forceConcentration == -9) return false;
        if (forceConcentration == -1) return true;
        boolean chances = forceConcentration > 1.0;
        return chances;
    }

    @Override
    public void collectTax() {
        Set<Tile> popTiles = territory.getPopulatedTileLinks();
        Map<String, Double> paramMap = new HashMap<>();
        Double revenue = 0.0;
        double rate = economicPolicy.getTaxRate();
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative or NaN before collecting the tax");
        }
        if (popTiles.size() < 250) {
            for (Tile i : popTiles) {
                String a = i.getAddress();
                paramMap.put("wokgWGDP_" + a, i.getWeeklyGTP());
                paramMap.put("currentWGDP_" + a, i.getWeeklyGTPTrans());
                paramMap.put("currentPop_" + a, i.getPopulationTrans());
                paramMap.put("currentUrbanPop_" + a, i.getUrbanPopTrans());
                paramMap.put("currentWealth_" + a, i.getWealthTrans());
                Double payment = i.payTaxes(rate);
                paramMap.put("currentTaxPayment_" + a, payment);
                revenue += payment;
            }
            paramMap.put("totalRevenue", revenue);
        } else {
            revenue = popTiles.stream().mapToDouble(t -> t.payTaxes(rate)).sum();
            if (DEBUG && (revenue.isNaN() || revenue < 0.0 ) ) {
                System.out.println(name + " collected " + revenue + " from its tiles.");
            }
        }
        if ((Objects.isNull(resources.getTreasury()) || resources.getTreasury() < 0.0 ||
                resources.getTreasury().isNaN()) && DEBUG) {
            System.out.println("Treasury is negative or NaN after collecting the tax");
        }
//        if (revenue * 0.8 > securityStrategy.getBaselineWeeklyCostSum()) {
//            System.out.println(this.name + " had way too much revenue this week.");
//            System.out.println(paramMap);
//        }
        this.resources.incrementTreasury(revenue);
        this.milExPer.incrementTreasury(revenue);

    }

    public void evaluateThreatNetwork(WorldOrder wo) {
        List<String> result = new ThreatNetworkServiceImpl().getAnyNeighbor(this.id, wo.getFromYear());
        List<State> unfriendlies = new ArrayList<>();
        Map<String, State> allTheStates = wo.getAllTheStates();
        for (String c : result) {
            State u = allTheStates.get(c);
            if (u != null) unfriendlies.add(u);
        }
        double networkTotalSDP = territory.getCurrentSDP();
        double networkTotalPop = territory.getCurrentPopulation();
        double networkTotalMilEx = 0.0;
        double networkTotalMilPer = 0.0;
        double networkAvgMilEx2SDP;
        double networkAvgMilPer2Pop;
        double myThreatPosture;

        for (State s : unfriendlies) {
            Resources milStrategy = s.getSecurityStrategy().getMilitaryStrategy();
            networkTotalSDP += s.getPublicSDP();
            networkTotalPop += s.getPopulation();
            networkTotalMilPer += milStrategy.getPax();
            networkTotalMilEx += milStrategy.getTreasury();
        }
        networkAvgMilEx2SDP = networkTotalMilEx / networkTotalSDP;
        networkAvgMilPer2Pop = networkTotalMilPer / networkTotalPop;
        myThreatPosture = (getMyMilEx2SDP() / networkAvgMilEx2SDP) * (getMyMilPer2Pop() / networkAvgMilPer2Pop);

        for (State s : unfriendlies) {
            if (s.getCowcode().equals("225")) {
                this.threatNet.put(s, 0.0);
            } else {
                double per = s.getPublicMilPer2Pop() / networkAvgMilPer2Pop;
                double exp = s.getPublicMilEx2SDP() / networkAvgMilEx2SDP;
                double threat = per * exp;
                double relativeThreat = threat / myThreatPosture;
                this.threatNet.put(s, relativeThreat);

                NetworkFact fact;
                if (this.networkFactMap.containsKey(s)) {
                    // update
                    fact = this.networkFactMap.get(s);
                    fact.setMyThreat(myThreatPosture);
                    fact.setRelativeThreat(relativeThreat);
                    this.networkFactMap.put(s, fact);
                } else {
                    // create
                    Year yr = wo.getDataYear();
                    double sdp = territory.getCurrentSDP();
                    fact = new NetworkFact.FactBuilder()
                            .me(this)
                            .them(s)
                            .dataset(wo.getModelRun())
                            .subject(this.getName())
                            .object(s.getName())
                            .from(yr.getBegan())
                            .thisYear(yr.getIntYear())
                            .until(yr.getEnded())
                            .mySDP(sdp)
                            .relativeSDP(this.getOurRelativeSDP(s))
                            .myThreat(myThreatPosture)
                            .relativeThreat(relativeThreat)
                            .build();
                    this.networkFactMap.put(s, fact);
                }
            }
        }
    }

    public double getPublicMilPer2Pop() {
        return this.securityStrategy.getMilitaryStrategy().getPax() / territory.getPopulationTrans();
    }

    public double getPublicMilEx2SDP() {
        return this.securityStrategy.getMilitaryStrategy().getTreasury() / getPublicSDP();
    }

    private double getMyMilPer2Pop() {
        return this.securityStrategy.getMilitaryStrategy().getTreasury() / territory.getCurrentSDP();
    }

    private double getMyMilEx2SDP() {
        return this.securityStrategy.getMilitaryStrategy().getPax() / territory.getPopulationTrans();
    }

    public void addNetworkEntry(NetworkFact f) {
        this.relationsWithMe.add(f);
    }

    private double getMyRelativeSDP(WorldOrder wo) {
        double globalSDP = 0.0;
        for (State s : wo.getAllTheStates().values() ) {
            globalSDP += s.getPublicSDP();
        }
        double mySDP = territory.getCurrentSDP();
        return mySDP / globalSDP;
    }

    private double getOurRelativeSDP(Polity p) {
        double mySDP = territory.getCurrentSDP();
        double theirSDP = p.getPublicSDP();
        return theirSDP / mySDP;
    }

    private double getTargetSDP(WorldOrder wo, Polity p) {
        double globalSDP = 0.0;
        for (State s : wo.getAllTheStates().values() ) {
            globalSDP += s.getPublicSDP();
        }
        double targetSDP = p.getPublicSDP();
        return targetSDP / globalSDP;
    }

    private boolean mobilizeTheReserves(Issue i) {
        Polity instigator = i.getClaimant();
        Resources opfor = instigator.getResources();
        double threat = opfor.getPax();
        double reserve = territory.getPopulationTrans() * 0.225;
        double needed = Math.min(reserve, threat * 1.5);
        recruit(needed);
        double cpp = !Objects.isNull(securityStrategy.getCostPerPax()) ? securityStrategy.getCostPerPax() : 50.0;
        double cost = cpp * needed;
        double plan = securityStrategy.getBaseline().getTreasury() + cost;
        double rate = plan / this.territory.getCurrentSDP();
        this.economicPolicy.setTaxRate(rate);
        return (reserve >= needed);
    }

    private void mobilizeTheReserves(ProcessDisposition p) {
        ProcessDisposition pd = p;
        Resources mob = new Resources.ResourceBuilder().build();
        double need = pd.getCommitment().getPax();
        double unmet = recruit(need);
        double available = need - unmet;
        mob.incrementPax(available);
        mob.incrementTreasury(available  * securityStrategy.getCostPerPax());
        pd.mobilizeCommitment(mob);
    }

    private Resources developWarStrategy(Polity op, SecurityObjective ob, WorldOrder wo) {
        /*
          These figures are just estimates for required forces to accomplish the mission, not the mobilized force.
         */
        int goal;
        SecurityObjective objective = ob;
        Polity opponent = op;
        WorldOrder worldOrder = wo;
        double defending = 2.0;  // attackers (default) spend 2x deterrence rate on deployed operations
        double weeks = worldOrder.weeksThisYear * 1.0;

        if (objective.value % 2 == 0) {
            goal = objective.value / 2;
        } else {
            goal = ((objective.value - 1) / 2);
            defending = 1.5;    // defenders are already paying for deterrence, so their operations rate increases less
        }
        double red;
        double blue;
        double threat;
        double risk;
        double forceEstimate = 100.0;
        double costEstimate = 10000.0;
        double costPerPax = this.securityStrategy.getCostPerPax() != 1.0 ? this.securityStrategy.getCostPerPax() : estimateCostPerPax();
        Resources strategy = new Resources.ResourceBuilder().pax(100.0).treasury(10000.0).build(); // Creates a Resources with small values
        Double overwhelmingForce = opponent.getForces() * (2.5 + worldOrder.random.nextDouble(true, true));
        Double ballpark;

        switch (goal) {
            case 0: // Strike (punish or retaliate)
                forceEstimate = Math.pow(10, warParams.get("THREAT_PUNISH") + worldOrder.random.nextDouble(true, true));
                costEstimate = forceEstimate * costPerPax * defending * 4 / weeks; // 4 weeks
                strategy = new Resources.ResourceBuilder().pax(forceEstimate).treasury(costEstimate).build();
                break;
            case 1: // Show of Force/SOF (coerce/resist)
                forceEstimate = Math.pow(10, warParams.get("THREAT_COERCE") + worldOrder.random.nextDouble(true, true));
                costEstimate = forceEstimate * costPerPax * defending * 9 / weeks; // assume 2 months, at least
                strategy = new Resources.ResourceBuilder().pax(forceEstimate).treasury(costEstimate).build();
                break;
            case 2: // Swiftly Defeat (defeat or defend)
                ballpark = Math.pow(10, warParams.get("THREAT_DEFEAT") + worldOrder.random.nextDouble(true, true));
                forceEstimate = Math.min(ballpark, overwhelmingForce);
                costEstimate = forceEstimate * costPerPax * defending * 17 / weeks; // assume 4 months
                strategy = new Resources.ResourceBuilder().pax(forceEstimate).treasury(costEstimate).build();
                break;
            case 3: // Win Decisively (conquer)
                ballpark = Math.pow(10, warParams.get("THREAT_CONQUER") + worldOrder.random.nextDouble(true, true));
                forceEstimate = Math.min(ballpark, overwhelmingForce);
                costEstimate = forceEstimate * costPerPax * defending * 17 / weeks; // assume 4 months
                strategy = new Resources.ResourceBuilder().pax(forceEstimate).treasury(costEstimate).build();
                break;
        }

        if (Double.isNaN(strategy.getTreasury()) || Double.isNaN(strategy.getPax())) {
            System.out.println("The strategy picker picked values that are not numbers.");
        }
        // default warStrategy is 0 forces/resources
        if (DEBUG && (strategy.getTreasury() < 0.0 || strategy.getPax() < 0.0) ){
            System.out.println("Why is this negative>");
        }
        return strategy;
    }

    public Double estimateCostPerPax() {
        // from MilExPerPax.R 48-51
//        (Intercept)  dat.df$pcgdp
//              394.9         340.7
        Double estimate = 394.9 + 340.7 * (territory.getGdpTrans() / territory.getPopulationTrans());
        return estimate;

    }


    @Override
    public void surrender(ProcessDisposition p, WorldOrder wo) {
        p.getEnemyDisposition().setS(true);
        p.getProcess().getIssue().setResolved(true);
        p.getProcess().setOutcome(true);
        p.setP(true);
        p.setOutcome(true);
    }

    @Override
    public void acquiesce(ProcessDisposition p, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        WarProcess proc = (WarProcess) p.getProcess();
        ProcessDisposition disposition = p;
        ProcessDisposition e = disposition.getEnemyDisposition();
        int enemyObjective = e.getObjective()!=null ? e.getObjective().value : -9;
        if (enemyObjective > 5) {
            // suzerainty
        } else if (enemyObjective >= 0) {
            // resolve issue and give up something in the issue domain
        } else {
           // just end the process
        }
        e.setS(true);
        proc.getIssue().setResolved(true);
        p.getProcess().setOutcome(true);
        p.setP(true);
        p.setOutcome(true);
    }

    public void establishForeignStrategyCost(int i) {
        Resources portion = securityStrategy.getForeignStrategy().multipliedBy(1.0 / (52.0 * i));
        for (BorderFact f : bordersWith) {
            f.setMaintenanceCost(portion);
        }
        for (DipExFact f : representedAt) {
            f.setMaintenanceCost(portion);
        }
        for (AllianceParticipationFact f : alliances) {
            f.setMaintenanceCost(portion);
        }
//        for (IgoMembershipFact f : organizations) {
//            f.setMaintenanceCost(portion);
//        }

    }

    private void implementForeignStrategy() {
        Integer steadyStateInstitutions = bordersWith.size() + alliances.size() + representedAt.size() + peaceList.size();
        Double foreignPolicyCost = securityStrategy.getWeeklyForeignPolicyCost() / steadyStateInstitutions;

        for (BorderFact f : bordersWith) {
            double borderCost = f.getMaintenance().getTreasury();
            if (resources.getTreasury() > borderCost) {
                resources.decrementTreasury(borderCost);
                foPoEx.incrementTreasury(borderCost);
                f.getBorder().setStrength(f.getBorder().getStrength() / institutionStagnationRate);
            } else {
                f.getBorder().setStrength(f.getBorder().getStrength() * institutionStagnationRate);
            }
        }
        for (DipExFact f : representedAt) {
            double dipCost = f.getMaintenance().getTreasury();
            if (resources.getTreasury() > dipCost) {
                resources.decrementTreasury(dipCost);
                foPoEx.incrementTreasury(dipCost);
                f.getInstitution().setStrength(f.getInstitution().getStrength() / institutionStagnationRate);
            } else {
                f.getInstitution().setStrength(f.getInstitution().getStrength() * institutionStagnationRate);
            }
        }
        for (AllianceParticipationFact f : alliances) {
            double coopCost = f.getMaintenance().getTreasury();
            if (resources.getTreasury() > coopCost) {
                resources.decrementTreasury(coopCost);
                foPoEx.incrementTreasury(coopCost);
                f.getAlliance().setStrength(f.getAlliance().getStrength() / institutionStagnationRate);
            } else {
                f.getAlliance().setStrength(f.getAlliance().getStrength() * institutionStagnationRate);
            }
        }
//        for (IgoMembershipFact f : organizations) {
//            double igoCost = f.getMaintenance().getTreasury();
//            resources.decrementTreasury(igoCost);
//            foPoEx.incrementTreasury(igoCost);
//        }
    }

    public void loadData(WorldOrder wo) {
        String y = territory.getYear() + "";
        double p = ((MilPerFact)(new FactServiceImpl().getMilPerFact(y, this))).getValue();
        double t = ((MilExFact)(new FactServiceImpl().getMilExFact(y, this))).getValue();
        double r = ((TaxRateFact) (new FactServiceImpl().getInitialTaxRate(this, territory.getYear()))).getValue();
        Resources baseline = new Resources.ResourceBuilder()
                .pax(p)
                .treasury(t)
                .sufficient(true)
                .build();
        this.resources = new Resources.ResourceBuilder().build();
        this.resources.increaseBy(baseline);
        this.setSecurityStrategy(baseline);
        if (this.securityStrategy.getCostPerPax()==1.0) {
            this.securityStrategy.setCostPerPax(new FactServiceImpl()
                    .getNeighborAverageCostPerPax(this, territory.getYear()));
        }
        this.setEconomicPolicy(new EconomicPolicy(0.6, 0.4, r));
        this.loadInstitutionData(wo);
    }

    public void establishEconomicPolicy(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        int w = worldOrder.weeksThisYear;
        Double sdp = 0.0;
        // evaluate tax rate based on initial summed STPs
        if (territory.getTileLinks(wo).size() > 250) {
            sdp = territory.getTileLinks(wo).stream().mapToDouble(Tile::getWeeklySDP).sum();
        } else {
            for (Tile t : territory.getTileLinks(wo)) {
                Double stp = t.getWeeklySDP();
                sdp += stp;
            }
        }
        Double rate = securityStrategy.getBaseline().getTreasury() / (sdp * w);
        if (rate > 1.1 * economicPolicy.getTaxRate()) {
            System.out.println("A significantly larger tax rate has been establish for " + this.name);
        }
        this.economicPolicy.setTaxRate(rate);
    }

    @Override
    public boolean findPolityData(int year) {
        DiscretePolityFact dpf = new DiscretePolityFactServiceImpl().getPolityData(this, year);
        if (dpf != null) {
            polityFact = dpf;
            return true;
        } else {
            setNeutralPolityFact();
            return false;
        }
    }

    @Override
    public void loadInstitutionData(WorldOrder wo) {
        int y = wo.getFromYear();
        new PolityFactServiceImpl().loadStateInstitutions(this, wo);
        this.polityFact = new DiscretePolityFactServiceImpl().getPolityData(this,y);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (((State) o).getId().equals(this.getId())) return true;
        if (!(o instanceof State)) return false;

        State state = (State) o;

        if (getId() != null ? !getId().equals(state.getId()) : state.getId() != null) return false;
        if (!cowcode.equals(state.cowcode)) return false;
        return getCowcode() != null ? getCowcode().equals(state.getCowcode()) : state.getCowcode() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + (getCowcode() != null ? getCowcode().hashCode() : 0);
        return result;
    }

}

//        switch (goal) {
//            case 0: // Punish (Strike) / Retaliate (Strike)
//                red = opponent.getForces() > 0.0 ? opponent.getForces() * warParams.get("RED_PUNISH") : getForces() * warParams.get("RED_PUNISH");
//                blue = getForces() * warParams.get("BLUE_PUNISH");
//                threat = opponent.getTreasury() > 0.0 ? opponent.getTreasury() * warParams.get("THREAT_PUNISH") : getTreasury() * warParams.get("THREAT_PUNISH");
//                risk = getTreasury() * warParams.get("RISK_PUNISH");
//                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
//                break;
//            case 1: // Coerce (Show of Force) / Resist (Reinforce)
//                red = opponent.getForces() > 0.0 ? opponent.getForces() * warParams.get("RED_COERCE") : getForces() * warParams.get("RED_COERCE");
//                blue = getForces() * warParams.get("BLUE_COERCE");
//                threat = opponent.getTreasury() > 0.0 ? opponent.getTreasury() * warParams.get("THREAT_COERCE") : getTreasury() * warParams.get("THREAT_COERCE");
//                risk = getTreasury() * warParams.get("RISK_COERCE");
//                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
//                break;
//            case 2:  // Defeat (Swiftly Defeat) / Defend (Swiftly Defeat)
//                red = opponent.getForces() > 0.0 ? opponent.getForces() * warParams.get("RED_DEFEAT") : getForces() * warParams.get("RED_DEFEAT");
//                blue = getForces() * warParams.get("BLUE_DEFEAT");
//                threat = opponent.getTreasury() > 0.0 ? opponent.getTreasury() * warParams.get("THREAT_DEFEAT") : getTreasury() * warParams.get("THREAT_DEFEAT");
//                risk = getTreasury() * warParams.get("RISK_DEFEAT");
//                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
//                break;
//            case 3:  // Conquer (Win Decisively)
//                red = opponent.getForces() > 0.0 ? opponent.getForces() * warParams.get("RED_CONQUER") : getForces() * warParams.get("RED_CONQUER");
//                blue = getForces() * warParams.get("BLUE_CONQUER");
//                threat = opponent.getTreasury() > 0.0 ? opponent.getTreasury() * warParams.get("THREAT_CONQUER") : getTreasury() * warParams.get("THREAT_CONQUER");
//                risk = getTreasury() * warParams.get("RISK_CONQUER");
//                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
//                break;
//        }


//    public boolean evaluatePeaceWillingness(ProcessDisposition pd) {
//        Issue issue = pd.getProcess().getIssue();
//        War war = (War) issue.getCause();
//        WarParticipationFact wpf = warList.stream().filter(p -> p.getWar().equals(war)).findAny().orElse(null);
//        DataTrend history = wpf.getBattleHistory();
//        double lo = history.average() / wpf.getCommitment().getPax();
//        double po = history.countBelowThreshold(0.0, false) / history.size();
//        double meanOpinion = evaluatePolityResolve(lo, po);
//        if (meanOpinion > 0.0) {
//            pd.setU(false);
//            return false;
//        } else {
//            pd.setU(true);
//            return true;
//        }
//    }


//    public Resources developConflictStrategy(Issue i, Polity t, SecurityObjective so) {
//        int goal = 0;
//        Issue issue = i;
//        Polity target = t;
//        SecurityObjective objective = so;
//        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values
//
//        Resources redStrength = target.getResources();
//        Double forceRatio = this.resources.getPax() / redStrength.getPax();
//        if (objective.value % 2 == 0) {
//            goal = objective.value / 2;
//        } else {
//            goal = ((objective.value + 1) / 2);
//        }
//
//        return strategy;
//    }


//    private double evaluatePolityResolve(double lo, double po) {
//        double leadershipOpinion = lo;
//        double popularOpinion = po;
//        int autocracyFactor = polityFact.getAutocracyRating() + 1;
//        int democracyFactor = polityFact.getDemocracyRating() + 1;
//        int allopinions = autocracyFactor + democracyFactor;
//        double [] opinions = new double[allopinions];
//        for (int j=0;j<autocracyFactor;j++) {
//            opinions[j] = leadershipOpinion;
//        }
//        for (int j=autocracyFactor;j<allopinions;j++) {
//            opinions[j] = popularOpinion;
//        }
//        return Arrays.stream(opinions).average().getAsDouble();
//    }


//    private boolean undertakeMilitaryAction(WorldOrder wo, ProcessDisposition pd) {
//        WorldOrder worldOrder = wo;
//        ProcessDisposition disposition = pd;
//        Issue issue = disposition.getProcess().getIssue();
//        Polity t = issue.getTarget();
//        long step = worldOrder.getWeekNumber();
//        WarProcess proc = new WarProcess(issue, step);                                  //
//        issue.setProcess(proc);                                                         //
//        worldOrder.addProc(proc);                                                       //
//        proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));                   //
//        SecurityObjective so = leadership.chooseSecurityObjective(issue, worldOrder);   //
//        Resources warStrategy = developWarStrategy(t, so, worldOrder);
//        // link this state to the process and prepare security strategy
//        ProcessDisposition pdo = new ProcessDisposition.Builder().from(step).owner(this).process(proc)
//                .objective(so).side(0).need(true).commitment(warStrategy).build();     //
//        // link the target to the process
//        ProcessDisposition pdt = new ProcessDisposition.Builder().owner(t).process(proc).from(step)
//                .side(1).build();
//        if(so.value > 3 && !warStrategy.isEmpty()) securityStrategy.addSupplemental(pdo,warStrategy);
//        return true;
//    }