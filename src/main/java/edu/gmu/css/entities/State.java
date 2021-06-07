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
import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;

@NodeEntity
public class State extends Polity implements Steppable {
    /**
     *
     */
    @Id
    @GeneratedValue
    private Long id;
    @Property
    private String cowcode;
    @Property
    private String abb;
    @Transient
    private double liability;
    @Transient
    private double urbanPortion;
    @Transient
    private double treasury;
    @Transient
    protected Set<Polity> suzereinSet;
//    @Transient
//    protected DataTrend forcesHistory = new DataTrend(105);
//    @Transient
//    protected DataTrend economicHistory = new DataTrend(14);
//    @Transient
//    protected DataTrend urbanization = new DataTrend(105);
    @Transient
    protected double gdpLastYear = 0.0;


    public State() {

    }


    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        // Document history
//        forcesHistory.add(resources.getPax());
        // Collect Taxes from Tiles and update the econ policy
        collectTax();
        // Implement security strategy, including deterrence mission and recruiting for any shortfalls;
        implementSecurityStrategy(worldOrder);
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
        int weeks = worldOrder.dataYear.getWeeksThisYear();

        implementForeignStrategy();
        implementDeterrenceMission(weeks);

        double some = 0.25; // Amount of force that can be mobilized during any week/step
        Deque<ImmutablePair<Object, Resources>> next = new LinkedList<>();
        Deque<ImmutablePair<Object, Resources>> supp = securityStrategy.getSupplementals();
        Resources totalRequest = securityStrategy.getSupplementalsSum();
        Resources available = resources.multipliedBy(some);
        double[] ratio = available.calculateRatios(totalRequest);

        while (supp.iterator().hasNext()) {
            ImmutablePair<Object, Resources> p = supp.pop();
            Resources needed = p.getRight();
            Resources allowable;
            Resources unmet = null;

            if (available.applyRatios(ratio).isSufficientFor(needed)) {
                allowable = needed;
            } else {
                allowable = available.applyRatios(ratio).evaluativeAvailableDifference(needed);
                unmet = needed.evaluativeAvailableDifference(allowable);
            }
            available.reduceBy(allowable);
            resources.reduceBy(allowable);

            if (p.getLeft().getClass()==ProcessDisposition.class) {
                ProcessDisposition caller = (ProcessDisposition) p.getLeft();
                caller.commitMore(allowable);
                if (unmet!=null) next.add(new ImmutablePair<>(caller, unmet));
            } else if (p.getLeft().getClass() == WarParticipationFact.class) {
                WarParticipationFact caller = (WarParticipationFact) p.getLeft();
                caller.commitMore(allowable);
                if (unmet!=null) next.add(new ImmutablePair<>(caller, unmet));
            } else if (p.getLeft().getClass() == DisputeParticipationFact.class) {
                DisputeParticipationFact caller = (DisputeParticipationFact) p.getLeft();
                caller.commitMore(allowable);
                if (unmet!=null) next.add(new ImmutablePair<>(caller, unmet));
            }
            // TODO: Add else for fopo, borders, etc.
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
        // required new recruits are demand minus available resources
        Double requirement = securityStrategy.getTotalDemand().getPax() - resources.getPax();
        if (requirement > 0.0) {
            deficit = recruit(requirement / 4.33);
        } else if (requirement < 0.0) {
            demobilize(requirement / 4.33);
        } else {
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
            Double forceRatio = demand / territory.getPopulation();
            recruits += popdTileLinks.stream().mapToDouble(t -> t.supplySoldiers(forceRatio)).sum();
            attempts++;
        }
        resources.incrementPax(recruits);
        deficit = forceRequest - recruits;
        return deficit;
    }

    private void demobilize(double f) {
        double force = -f;
        resources.decrementPax(force);
        for (Tile t : territory.getPopulatedTileLinks()) {
            double pop = t.getPopulationTrans();
            double ratio = pop / territory.getPopulation();
            double vets = ratio * force;
            double uPop = t.getUrbanPopTrans();
            t.setPopulationTrans(pop + vets);
            if (uPop > 0.0) { // veteran soldiers return to cities
                t.setUrbanPopTrans(uPop + vets);
            }
        }
    }

    private void implementDeterrenceMission(int w) {
        int weeks = w;
        // Do deterrence
        double weeklyDeterrenceCost = securityStrategy.getMilitaryStrategy().getTreasury() / (weeks * 1.0);
        resources.decrementTreasury(weeklyDeterrenceCost);
    }

    // TODO: Rewire this to consider current resources + (future income - future expenses)
    @Override
    public void updateEconomicPolicy(Leadership l, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        if (this.leadership.equals(l)) {
            Double totalTreasuryDemand = securityStrategy.getTotalDemand().getTreasury();
            if (totalTreasuryDemand > resources.getTreasury()) {
                economicPolicy.setTaxRate(economicPolicy.getTaxRate() * 1.02);
            } else {
                economicPolicy.setTaxRate(economicPolicy.getTaxRate() * 0.99);
            }
//            if ((totalTreasuryDemand * 1.1) < resources.getTreasury()) {
//                double invest = resources.getTreasury() - totalTreasuryDemand;
//                double pci = invest / territory.getPopulation();
//                territory.getPopulatedTileLinks().stream().forEach(t -> t.takeInvestment(pci));
//                resources.decrementTreasury(invest);
//            }
        }
    }

    public void recordSimulationHistory(WorldOrder wo) {
        territory.updateTotals();
//        if (wo.RECORDING) {
            WorldOrder worldOrder = wo;
            Dataset run = wo.getModelRun();
            PopulationFact pf = new PopulationFact.FactBuilder()
                    .dataset(run)
                    .polity(this)
                    .value(territory.getCurrentPopulation())
                    .during(wo.getDataYear())
                    .build();
            run.addFacts(pf);
            new FactServiceImpl().createOrUpdate(pf);

            UrbanPopulationFact uf = new UrbanPopulationFact.FactBuilder().dataset(run).polity(this)
                    .value(territory.getCurrentUrbanPopulation()).during(wo.getDataYear()).build();
            run.addFacts(uf);
            new FactServiceImpl().createOrUpdate(uf);

            this.gdpLastYear = territory.getGrossDomesticProductLastYear();
            GdpFact gf = new GdpFact.FactBuilder().dataset(run).polity(this).value(this.gdpLastYear)
                    .during(wo.getDataYear()).build();
            run.addFacts(gf);
            gdpHistory.add(gf);
            new FactServiceImpl().createOrUpdate(gf);
//        }
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
//        // Neutral Switzerland, you're too complicated to play.
//        if (this.cowcode == "225") return false;
        WorldOrder worldOrder = wo;
        Issue issue = i;
        if (WorldOrder.RANDOM) {
            return worldOrder.random.nextBoolean();
        } else {
            this.territory.getCommonWeal().addIssue(issue, worldOrder);
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
        Issue issue = pd.getProcess().getIssue();
        if (WorldOrder.RANDOM) {
            if (worldOrder.random.nextBoolean()) {
                pd.setN(true);
                pd.setObjective( leadership.chooseSecurityObjective(issue, worldOrder) );
                return true;
            } else {
                return false; // Canonical x, Wright's ~A (failure to resist)
            }
        } else {
            if (this.leadership.evaluateWarNeed(issue, wo) > warParams.get("WAR_NEED_MIN")) {
                if (Objects.equals(this.cowcode, "225")) {
                    if (pd.getEnemyDisposition().getObjective().value > 3) mobilizeTheReserves(issue);
                }
                pd.setN(true);
                pd.setObjective( leadership.chooseSecurityObjective(issue, worldOrder) );
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
        SecurityObjective response = pd.getObjective() == null ? leadership.chooseSecurityObjective(i, wo) : pd.getObjective();
        boolean defending = (response.value == 3 || response.value == 5);

        if (leadership.evaluateWarWillingness(i, wo) > warParams.get("WAR_WILLING_MIN")) {
            Resources strategy = developWarStrategy(enemy, response);
            pd.commit(strategy);
            pd.setU(true);
            if (response.value > 3) securityStrategy.addSupplemental(pd,strategy);
            int hops = 1;
            int weeks = 1;
            int pace = wo.getMarchingPace();
            if (!defending ) {
                Territory enemyTerritory = enemy.getTerritory();
                Map<String, Object> attackPath = new AttackPathImpl().findAttackPath(territory, enemyTerritory);
                pd.setAttackPath(attackPath);
                System.out.println("attacking from " + territory.getMapKey() + " to " + enemyTerritory.getMapKey());
                hops = ((Number) attackPath.get("hops")).intValue();
                weeks = Math.max( (hops + pace - 1) / pace, 1);
                pd.setUt( weeks );
            } else {
                Map<String, Object> defensePath = new HashMap<>();
                if (Objects.nonNull(pd.getEnemyDisposition().getAttackPath())) {
                    defensePath.put( "finish", pd.getEnemyDisposition().getAttackPath().get("finish") );
                }
                hops = (int) (Math.sqrt(territory.getRadius()));
                defensePath.put("hops", hops);
                pd.setAttackPath(defensePath);
                weeks = Math.max( (hops + pace - 1) / pace, 1);
                pd.setUt(weeks);
            }
//            securityStrategy.addSupplemental(pd,strategy);
            return true;
        } else {
            if (pd.getSide()==0) {
                pd.setObjective(ABIDE);
            } else {
                pd.setObjective(ACCEPT);
            }
            return false;
        }
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

    private boolean undertakeMilitaryAction(WorldOrder wo, ProcessDisposition pd) {
        WorldOrder worldOrder = wo;
        ProcessDisposition disposition = pd;
        Issue issue = disposition.getProcess().getIssue();
        Polity t = issue.getTarget();
        long step = worldOrder.getWeekNumber();
        WarProcess proc = new WarProcess(issue, step);                                  //
        issue.setProcess(proc);                                                         //
        worldOrder.addProc(proc);                                                       //
        proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));                   //
        SecurityObjective so = leadership.chooseSecurityObjective(issue, worldOrder);   //
        Resources warStrategy = developWarStrategy(t, so);
        // link this state to the process and prepare security strategy
        ProcessDisposition pdo = new ProcessDisposition.Builder().from(step).owner(this).process(proc)
                .objective(so).side(0).need(true).commitment(warStrategy).build();     //
        // link the target to the process
        ProcessDisposition pdt = new ProcessDisposition.Builder().owner(t).process(proc).from(step)
                .side(1).build();
        if(so.value > 3) securityStrategy.addSupplemental(pdo,warStrategy);
        return true;
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
        WarParticipationFact wpf = warList.stream().filter(p -> p.getWar().equals(war)).findAny().orElse(null);
        if (wpf==null) return false;
        double lo = leadership.considerPeace(wpf, worldOrder);
        double po = territory.commonWeal.evaluateNeedForPeace(wpf);
        double threshold = worldOrder.random.nextDouble();
        double meanOpinion = evaluatePolityResolve(lo, po);
        if (meanOpinion > threshold) {
            PeaceProcess proc = new PeaceProcess(this, issue, wo.getWeekNumber() );
            issue.setProcess(proc);
            worldOrder.addProc(proc);
            proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));
            for (WarParticipationFact f : war.getParticipations()) {
                ProcessDisposition pd = new ProcessDisposition.Builder().owner(f.getPolity()).process(proc).build();
            }
            return true;
        } else {
            return false;
        }
    }

    public boolean evaluateNeedForPeace(ProcessDisposition pd) {
        return true;
    }

    public boolean evaluatePeaceWillingness(ProcessDisposition pd) {
        Issue issue = pd.getProcess().getIssue();
        War war = (War) issue.getCause();
        WarParticipationFact wpf = warList.stream().filter(p -> p.getWar().equals(war)).findAny().orElse(null);
        DataTrend history = wpf.getBattleHistory();
        double lo = history.average() / wpf.getCommitment().getPax();
        double po = history.countBelowThreshold(0.0, false) / history.size();
        double meanOpinion = evaluatePolityResolve(lo, po);
        if (meanOpinion > 0.0) {
            pd.setU(false);
            return false;
        } else {
            pd.setU(true);
            return true;
        }
    }

    @Override
    public boolean evaluateAttackSuccess(ProcessDisposition pd) {
        WarProcess wp = (WarProcess) pd.getProcess();
        double commitment = pd.getCommitment().getPax();
        double magnitude = wp.getInvolvement().getPax();
        int extent = wp.getProcessDispositionList().size();
        return magnitude / extent < commitment;
    }

    private double evaluatePolityResolve(double lo, double po) {
        double leadershipOpinion = lo;
        double popularOpinion = po;
        int autocracyFactor = polityFact.getAutocracyRating() + 1;
        int democracyFactor = polityFact.getDemocracyRating() + 1;
        int allopinions = autocracyFactor + democracyFactor;
        double [] opinions = new double[allopinions];
        for (int j=0;j<autocracyFactor;j++) {
            opinions[j] = leadershipOpinion;
        }
        for (int j=autocracyFactor;j<allopinions;j++) {
            opinions[j] = popularOpinion;
        }
        return Arrays.stream(opinions).average().getAsDouble();
    }

    public boolean evaluateDefensePactImplementationNeed(Polity p, Issue i) {
        return false;
    }

    @Override
    public boolean willRelent(ProcessDisposition p, WorldOrder wo) {
        int objective = p.getObjective() == null ? -3 : p.getObjective().value;
        if (objective < 0) return true;
        double forceConcentration = new Lanchester(
                p.getCommitment().multipliedBy(2), p.getEnemyDisposition()
                .getCommitment()).calculateMyForceConcentration();
        boolean chances;
        if (p.getSide() == 1) {
            chances = forceConcentration > 1.0;
        } else {
            chances = forceConcentration > 1.5;
        }
        return (chances);
    }

    @Override
    public void collectTax() {
        Set<Tile> popTiles = territory.getPopulatedTileLinks();
        Double revenue = 0.0;
        if (popTiles.size() < 250) {
            for (Tile i : popTiles) {
                revenue += i.payTaxes(economicPolicy.getTaxRate());
            }
        } else {
            revenue = popTiles.stream().mapToDouble(t -> t.payTaxes(economicPolicy.getTaxRate())).sum();
        }

        if (DEBUG && revenue.isNaN()) {
            System.out.println(name + " collected " + revenue + " from its tiles.");
        }
//        System.out.println(name + " revenue this week is " + revenue + ", but expenses were " + securityStrategy.getBaseline().getTreasury()/52.0);
        this.resources.incrementTreasury(revenue);
    }

    public void collectTax(long s) {
        Double revenue = 0.0;
        for (Tile i : territory.getTileLinks()) {
            Double tileRevenue = i.payTaxes(economicPolicy.getTaxRate());
            if (tileRevenue.isNaN() && DEBUG) {
                System.out.println("wha ?");
            }
            revenue += tileRevenue;
        }
        if (DEBUG) {
            if (revenue.isNaN()) {
                System.out.println(name + " collected " + revenue + " from its tiles.");
            }
        }
        this.resources.incrementTreasury(revenue);
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
            }
        }
    }

    public double getPublicMilPer2Pop() {
        return this.securityStrategy.getMilitaryStrategy().getPax() / territory.getPopulation();
    }

    public double getPublicMilEx2SDP() {
        return this.securityStrategy.getMilitaryStrategy().getTreasury() / getPublicSDP();
    }

    private double getMyMilPer2Pop() {
        return this.securityStrategy.getMilitaryStrategy().getTreasury() / territory.getCurrentSDP();
    }

    private double getMyMilEx2SDP() {
        return this.securityStrategy.getMilitaryStrategy().getPax() / territory.getPopulation();
    }

    private double getMyRelativeSDP(WorldOrder wo) {
        double globalSDP = 0.0;
        for (State s : wo.getAllTheStates().values() ) {
            globalSDP += s.getPublicSDP();
        }
        double mySDP = territory.getCurrentSDP();
        return mySDP / globalSDP;
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
        double reserve = territory.getPopulation() * 0.1;
        double needed = Math.min(reserve, threat * 2);
        recruit(needed);
        return (reserve >= needed);
    }

    private Resources developWarStrategy(Polity op, SecurityObjective ob) {
        int goal;
        SecurityObjective objective = ob;
        Polity opponent = op;
        if (objective.value % 2 == 0) {
            goal = objective.value / 2;
        } else {
            goal = ((objective.value - 1) / 2);
        }
        double red;
        double blue;
        double threat;
        double risk;
        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values

        switch (goal) {
            case 0: // Punish (Strike) / Retaliate (Strike)
                red = opponent.getForces() * warParams.get("RED_PUNISH");
                blue = getForces() * warParams.get("BLUE_PUNISH");
                threat = opponent.getTreasury() * warParams.get("THREAT_PUNISH");
                risk = getTreasury() * warParams.get("RISK_PUNISH");
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 1: // Coerce (Show of Force) / Resist (Reinforce)
                red = opponent.getForces() * warParams.get("RED_COERCE");
                blue = getForces() * warParams.get("BLUE_COERCE");
                threat = opponent.getTreasury() * warParams.get("THREAT_COERCE");
                risk = getTreasury() * warParams.get("RISK_COERCE");
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 2:  // Defeat (Swiftly Defeat) / Defend (Swiftly Defeat)
                red = opponent.getForces() * warParams.get("RED_DEFEAT");
                blue = getForces() * warParams.get("BLUE_DEFEAT");
                threat = opponent.getTreasury() * warParams.get("THREAT_DEFEAT");
                risk = getTreasury() * warParams.get("RISK_DEFEAT");
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 3:  // Conquer (Win Decisively)
                red = opponent.getForces() * warParams.get("RED_CONQUER");
                blue = getForces() * warParams.get("BLUE_CONQUER");
                threat = opponent.getTreasury() * warParams.get("THREAT_CONQUER") ;
                risk = getTreasury() * warParams.get("RISK_CONQUER");
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
        }
        // default warStrategy is 0 forces/resources
        return strategy;
    }

    public Resources developConflictStrategy(Issue i, Polity t, SecurityObjective so) {
        int goal = 0;
        Issue issue = i;
        Polity target = t;
        SecurityObjective objective = so;
        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values

        Resources redStrength = target.getResources();
        Double forceRatio = this.resources.getPax() / redStrength.getPax();
        if (objective.value % 2 == 0) {
            goal = objective.value / 2;
        } else {
            goal = ((objective.value + 1) / 2);
        }

        return strategy;
    }

    @Override
    public void surrender(ProcessDisposition p, WorldOrder wo) {
        p.getEnemyDisposition().setS(true);
        p.getProcess().getIssue().setResolved(true);
    }

    public void acquiesce(ProcessDisposition p, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        ProcessDisposition disposition = p;
        ProcessDisposition enemyDisposition = disposition.getEnemyDisposition();
        int enemyObjective = enemyDisposition.getObjective().value;
        if (enemyObjective > 5) {
            // suzerainty
        } else if (enemyObjective >= 0) {
            // resolve issue and give up something in the issue domain
        } else {
           // just end the process
        }
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
        for (BorderFact f : bordersWith) {
            resources.decrementTreasury(f.getMaintenance().getTreasury());
        }
        for (DipExFact f : representedAt) {
            resources.decrementTreasury(f.getMaintenance().getTreasury());
        }
        for (AllianceParticipationFact f : alliances) {
            resources.decrementTreasury(f.getMaintenance().getTreasury());
        }
//        for (IgoMembershipFact f : organizations) {
//            resources.decrementTreasury(f.getMaintenance().getTreasury());
//        }
    }

    public void loadData(WorldOrder wo) {
        String y = territory.getYear() + "";
        this.resources = new Resources.ResourceBuilder()
                .pax(((MilPerFact)(new FactServiceImpl().getMilPerFact(y, this))).getValue())
                .treasury(((MilExFact)(new FactServiceImpl().getMilExFact(y, this))).getValue())
                .build();
        this.setSecurityStrategy(resources);
        double rate = ((TaxRateFact) (new FactServiceImpl().getInitialTaxRate(this, territory.getYear()))).getValue();
        this.setEconomicPolicy(new EconomicPolicy(0.6, 0.4, rate));
        this.loadInstitutionData(wo);
    }

    public void establishEconomicPolicy(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        int w = worldOrder.weeksThisYear;
        // evaluate tax rate based on initial summed GTPs
        double gdp = territory.getTileLinks().stream().mapToDouble(Tile::getWeeklyGTPTrans).sum();
        this.economicPolicy.setTaxRate(securityStrategy.getBaseline().getTreasury() / (gdp * w) );
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
