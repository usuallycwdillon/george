package edu.gmu.css.entities;


import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.*;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.relations.*;
import edu.gmu.css.service.FactService;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.service.PolityFactService;
import edu.gmu.css.service.TileFactServiceImpl;
import edu.gmu.css.worldOrder.*;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.model.Result;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;

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
//    @Property
//    private String name;
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
    @Transient
    protected DataTrend forcesHistory = new DataTrend(105);
    @Transient
    protected DataTrend economicHistory = new DataTrend(105);
    @Transient
    protected DataTrend urbanization = new DataTrend(270);
    // Inherited from Polity:
//    protected int color;
//    protected String name;
//    protected Set<OccupiedRelation> allTerritories;  @Relationship (type = "OCCUPIED")
//    protected Territory territory;
//    protected Leadership leadership;  @Relationship (direction = Relationship.INCOMING)
//    protected Set<BorderAgreement> bordersWith = new HashSet<>();  @Relationship(type = "SHARES_BORDER")
//    protected List<ProcessDisposition> processList = new ArrayList<>();   @Relationship
//    protected Set<DiplomaticRepresentation> representedAt = new HashSet<>();  @Relationship(type = "REPRESENTATION")
//    protected Set<AllianceParticipation> alliances = new HashSet<>();  @Relationship(type = "ALLIANCE_PARTICIPATION")
//    protected List<InstitutionParticipation> institutionList = new ArrayList<>();
//    protected List<WarParticipationFact> warList = new ArrayList<>(); @Relationship(type = "PARTICIPATED")
//    // Resources, Strategies and Policies
//    protected Resources baseline = new Resources.ResourceBuilder().build();
//    protected Resources resources = new Resources.ResourceBuilder().build();
//    protected Resources securityStrategy = new Resources.ResourceBuilder().build();
//    protected Resources militaryStrategy = new Resources.ResourceBuilder().build();
//    protected Resources foreignStrategy = new Resources.ResourceBuilder().build();
//    protected Resources economicStrategy = new Resources.ResourceBuilder().build();
//    protected EconomicPolicy economicPolicy = new EconomicPolicy(0.50, 0.50, 0.050);
//    protected MersenneTwisterFast random = new MersenneTwisterFast();
//    protected DiscretePolityFact polityFact;
//    protected Color polColor = new Color(color);
//    protected Map<String, Double> warParams;

    public State() {

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


    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        if (worldOrder.getStepNumber() % 4 == 0) {
            territory.updateTotals();                       // keep territorial data up-to-date
        }
        forcesHistory.add(resources.getPax());
        economicHistory.add(resources.getTreasury());
        // Decrement 1/weeks worth of baseline treasury, then for each ProcessDistribution and Participation commitment
        resources.decrementTreasury(resources.getTreasury() / worldOrder.dataYear.getWeeksThisYear());
        // Collect Taxes from Tiles and recruit
        collectTax(worldOrder.getStepNumber());
//        System.out.println(name + " has " + economicHistory.toString());
        recruit(worldOrder.dataYear.getWeeksThisYear());
        // update the economicPolicy
        updateEconomicPolicy(worldOrder);
        implementSecurityStrategy();
    }

    @Override
    public void setSecurityStrategy(Resources r) {
        this.securityStrategy = new SecurityStrategy(r);
        Resources fo = new Resources.ResourceBuilder().build();
    }

    protected void implementSecurityStrategy() {
        Deque<ImmutablePair<Object, Resources>> next = new LinkedList<>();
        Deque<ImmutablePair<Object, Resources>> supp = securityStrategy.getSupplementals();
        Resources totalRequest = securityStrategy.getSupplementalsSum();
        Resources available = resources.multipliedBy(8.66); // two months worth at a time
        double[] ratio = available.calculateRatios(totalRequest);
        while (supp.iterator().hasNext()) {
            ImmutablePair<Object, Resources> p = supp.pop();
            Resources needed = p.getRight();
            Resources allowable;
            Resources unmet = null;

            if (available.applyRatios(ratio).isSufficientFor(needed)) {
                allowable = needed;
                available.reduceBy(allowable);
                resources.reduceBy(allowable);
            } else {
                allowable = available.applyRatios(ratio).evaluativeAvailableDifference(needed);
                unmet = needed.evaluativeAvailableDifference(allowable);
                available.reduceBy(allowable);
                resources.reduceBy(allowable);
            }

            if (p.getLeft().getClass()==ProcessDisposition.class) {
                ProcessDisposition caller = (ProcessDisposition) p.getLeft();
                caller.commitMore(allowable);
                if (unmet!=null) next.add(new ImmutablePair<>(caller, unmet));
            } else if (p.left.getClass() == WarParticipationFact.class) {
                WarParticipationFact caller = (WarParticipationFact) p.getLeft();
                caller.commitMore(allowable);
                if (unmet!=null) next.add(new ImmutablePair<>(caller, unmet));
            }
        }
        securityStrategy.renewSupplementals(next);
    }

    @Override
    protected void recruit() {
        double requirement = resources.getPax() - securityStrategy.getBaseline().getPax();
        if (requirement < 0) {
            Set<Inclusion> popdTileLinks = territory.getPopulatedTileLinks();
            double monthsWorth = (requirement * -1) / 4.0;
            double pop = territory.getPopulation();
            for (Inclusion i : territory.getTileLinks()) {
                Tile t = i.getTile();
                double tilePop = t.getPopulation();
                int recruits = (int) Math.round( (tilePop / (pop * 1.0)) * monthsWorth);
                double ratio = (tilePop - recruits) / tilePop * 1.0;
                // there must be at least half the population from a year ago AND at least 75% of the current pop
                // remaining after recruits are taken.
                if (t.getMemory().pastYearDiff() > 0.50 && ratio > 0.75) {
                    t.setPopulation(tilePop - recruits);
                    resources.incrementPax(recruits);
                    monthsWorth -= recruits;
                }
            }
        }
    }



    // TODO: Rewire this to consider current resources + (future income - future expenses)
    @Override
    protected void updateEconomicPolicy(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        Double avgTreasury = economicHistory.average();
        if (economicStrategy.getTreasury() > avgTreasury) {
            economicPolicy.setTaxRate(economicPolicy.getTaxRate() * 1.01923077);
        } else {
            economicPolicy.setTaxRate(economicPolicy.getTaxRate() * 0.99038462);
        }
        if (urbanization.average() < urbanization.pastYearAverage() && economicPolicy.getLabor() > 0.10) {
            economicPolicy.setCapital(economicPolicy.getCapital() + 0.01);
            economicPolicy.setLabor(economicPolicy.getLabor() - 0.01);
        } else if (urbanization.average() > urbanization.pastYearAverage() && economicPolicy.getLabor() < 0.90) {
            economicPolicy.setCapital(economicPolicy.getCapital() - 0.01);
            economicPolicy.setLabor(economicPolicy.getLabor() + 0.01);
        }
    }

    @Override
    public boolean findPolityData(int year) {
        DiscretePolityFact dpf = StateQueries.getPolityData(this, year);
        if (dpf != null) {
            polityFact = dpf;
            return true;
        } else {
            setNeutralPolityFact();
            return false;
        }
    }

    @Override
    public void loadInstitutionData(int year, WorldOrder wo) {
        PolityFactService service = new PolityFactService();
        service.loadStateInstitutions(this, wo, year);
    }

    @Override
    public boolean considerIssue(Issue i) {
        double p = 0.5;
        for (DipExFact r : representedAt) {
            if (r.getPolity().equals(i.getTarget())) {
                p -= 0.1;
            }
        }
        for (AllianceParticipationFact f : alliances) {
            Alliance a = f.getAlliance();
            if (a.isParticipant(i.getTarget())) {
                p -= 0.1;
            }
        }
        return random.nextDouble() < p;
    }

    @Override
    public boolean evaluateWarNeed(SimState simState, Issue i) {
        // The polity has a new Issue (Change occurs) and must decide whether they perceive a need to take action. Conceptually,
        // the ProbabilisticCausality agent creates the issue and the ProcessDisposition directly, and the ProcessDisposition
        // contains the logic about whether the polity perceives a need to take military action over the new Issue. In
        // practical terms, we would have to create a Process and a ProcessDisposition (because the ProcessDisposition is
        // a Neo4j relationship and it must know both of its endpoints at creation time); and the Issue may not result in
        // a new Process after all. For convenience, the first step of the conflict logic is inside this method.
        WorldOrder worldOrder = (WorldOrder) simState;
        Issue issue = i;
        Polity t = issue.getTarget();
        long step = worldOrder.getStepNumber();

        if (evalRandomStateResolve(issue)) {                                            // 1.3
            WarProcess proc = new WarProcess(issue, step);                              // 2.0
            issue.setProcess(proc);                                                     // 2.1
            worldOrder.addProc(proc);                                                   // 2.2
            proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));               // 2.3
            // link the this state to the process and prepare security strategy
            ProcessDisposition pdo = new ProcessDisposition(this, proc, step);    // 3.0
            SecurityObjective so = leadership.chooseSecurityObjective(issue);           // 3.1
            pdo.setObjective(so);                                                       // 3.2
            Resources warStrategy = developWarStrategy(t,so);                           // 3.3
            pdo.commit(warStrategy);                                                    // 3.4
            pdo.setSide(0);                                                             // 3.5
            pdo.setN(true);                                                             // 3.6
            this.addProcess(pdo);                                                       // 3.7
            proc.addProcessParticipant(pdo);                                            // 3.8
            securityStrategy.addSupplemental(pdo,warStrategy);                          // 3.9
            // link the target to the process
            ProcessDisposition pdt = new ProcessDisposition(t, proc, step);             // 4.0
            pdt.setSide(1);                                                             // 4.1
            t.addProcess(pdt);                                                          // 4.2
            proc.addProcessParticipant(pdt);                                            // 4.3
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean evaluateWarNeed(ProcessDisposition pd, long step) {
        if (evalRandomStateResolve(pd.getProcess().getIssue())) {
            pd.setN(true);
            return true;
        }
        return false;
    }

    private boolean evalRandomStateResolve(Issue i) {
        Issue issue = i;
        double leadershipOpinion = leadership.evaluateWarNeed(issue);
        double popularOpinion = territory.commonWeal.evaluateWarNeed(issue);
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
        double meanOpinion = Arrays.stream(opinions).average().getAsDouble();
        return meanOpinion > 0.50;
    }

    @Override
    public boolean evaluateWarWillingness(ProcessDisposition pd) {
        /*
         *  Is the State willing to undertake action (commit resources) for this conflict?
         *    1. Is the leadership willing (tax, recruit, etc) ?
         *    2. Is the commonWeal willing (pay tax, get drafted, ect) ?
         */
        if(leadership.evaluateWarWillingness(pd) && territory.commonWeal.evaluateWarWillingness(pd)) {
            pd.setU(true);
            return true;
        } else {
            return false;
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

    @Override
    public void collectTax() {
        Double revenue = 0.0;
        for (Inclusion i : territory.getTileLinks()) {
            revenue += i.getTile().payTaxes(economicPolicy.getTaxRate());
        }
        if (WorldOrder.DEBUG) {
            if (revenue.isNaN()) {
                System.out.println(name + " collected " + revenue + " from its tiles.");
            }
        }
        this.resources.incrementTreasury(revenue);
    }

    public void collectTax(long s) {
        Double revenue = 0.0;
        for (Inclusion i : territory.getTileLinks()) {
            Double tileRevenue = i.getTile().payTaxes(economicPolicy.getTaxRate());
            if (tileRevenue.isNaN()) {
                System.out.println("wha ?");
            }
            revenue += tileRevenue;
        }
        if (WorldOrder.DEBUG) {
            if (revenue.isNaN()) {
                System.out.println(name + " collected " + revenue + " from its tiles.");
            }
        }
        this.resources.incrementTreasury(revenue);
    }

    private Resources developWarStrategy(Polity opponent, SecurityObjective objective) {
        int goal;
        if (objective.value % 2 == 0) {
            goal = objective.value / 2;
        } else {
            goal = ((objective.value - 1) / 2);
        }
        int red;
        int blue;
        double threat;
        double risk;
//        Map<String, Double> warParams = getModelRun().getWarParameters();
        Resources strategy = new Resources.ResourceBuilder().build(); // Creates a Resources with 0 values
//        System.out.println(target.getTerritory().getMapKey() + " ...what a problem");
        switch (goal) {
            case 0: // Punish (Strike)
                red = (int) (opponent.getForces() * warParams.get("RED_PUNISH") );
                blue = (int) (getForces() * (random.nextDouble() * warParams.get("BLUE_PUNISH")) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_PUNISH"));
                risk = (getTreasury() * warParams.get("RISK_PUNISH"));
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 1: // Coerce (Show of Force)
                red = (int) (opponent.getForces() * warParams.get("RED_COERCE") );
                blue = (int) (getForces() * (random.nextDouble() * warParams.get("BLUE_COERCE") ) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_COERCE") );
                risk = (getTreasury() * warParams.get("RISK_COERCE") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 2:  // Defeat (Swiftly Defeat)
                red = (int) (opponent.getForces() * warParams.get("RED_DEFEAT") );
                blue = (int) (getForces() * (random.nextDouble() * warParams.get("BLUE_DEFEAT") ) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_DEFEAT") );
                risk = (getTreasury() * warParams.get("RISK_DEFEAT") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
            case 3:  // Conquer (Win Decisively)
                red = (int) (opponent.getForces() * warParams.get("RED_CONQUER") );
                blue = (int) (getForces() * (random.nextDouble() * warParams.get("BLUE_CONQUER") ) );
                threat = (opponent.getTreasury() * warParams.get("THREAT_CONQUER") );
                risk = (getTreasury() * warParams.get("RISK_CONQUER") );
                strategy = new Resources.ResourceBuilder().pax(Math.min(red, blue)).treasury(Math.min(threat, risk)).build();
                return strategy;
        }
        // default warStrategy is 0 forces/resources
        return strategy;
    }

    @Override
    public void surrender(WarParticipationFact p, WorldOrder wo) {
        super.surrender(p, wo);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof State)) return false;
//        if (!super.equals(o)) return false;

        State state = (State) o;

        if (!cowcode.equals(state.cowcode)) return false;
        return getName() != null ? getName().equals(state.getName()) : state.getName() == null;
    }

    @Override
    public int hashCode() {
        int result = cowcode.hashCode();
        result = 31 * result + (getName() != null ? getName().hashCode() : 0);
        return result;
    }
}
