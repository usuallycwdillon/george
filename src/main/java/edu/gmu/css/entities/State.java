package edu.gmu.css.entities;


import edu.gmu.css.agents.PeaceProcess;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.*;
import edu.gmu.css.queries.StateQueries;
import edu.gmu.css.relations.*;
import edu.gmu.css.service.DiscretePolityFactServiceImpl;
import edu.gmu.css.service.PolityFactServiceImpl;
import edu.gmu.css.worldOrder.*;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.neo4j.ogm.annotation.*;
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
    @Transient
    protected double gdpLastYear = 0.0;


    public State() {

    }


    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        int weeks = worldOrder.dataYear.getWeeksThisYear();

        forcesHistory.add(resources.getPax());
        economicHistory.add(resources.getTreasury());
        // Decrement 1/weeks worth of baseline treasury, then for each ProcessDisposition and Participation commitment
        resources.decrementTreasury(securityStrategy.getBaseline().getTreasury() / weeks);
        // Collect Taxes from Tiles and recruit
        collectTax();
        updateEconomicPolicy(worldOrder);
        implementSecurityStrategy(weeks);    // Includes recruiting any shortfalls
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
    public void setSecurityStrategy(Resources r) {
        this.securityStrategy = new SecurityStrategy(r);
    }

    protected void implementSecurityStrategy(int w) {
        double some = 8.66 / (w * 1.0);     // two months worth at a time
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
        Double deficit = recruit();
        // finally, add any unmet requirements back into the queue of supplemental demands
        securityStrategy.renewSupplementals(next);
    }

    @Override
    protected double recruit() {
        double deficit = 0.0;
        // required new recruits are demand minus available resources
        Double requirement = securityStrategy.getBaseline().getPax() - resources.getPax();
        if (requirement > 0) {
            deficit = recruit(requirement / 4.33);
        } else {
            demobilize(requirement / 4.33);
        }
        return deficit;
    }

    @Override
    protected double recruit(double f) {
        Double forceRequest = f;
        Double recruits = 0.0;
        Double deficit = 0.0;
        int attempts = 0;
        Set<Inclusion> popdTileLinks = territory.getPopulatedTileLinks();
        while (recruits < forceRequest && attempts < 3) {
            Double demand = forceRequest - recruits;
            Double forceRatio = demand / territory.getPopulation();
            recruits += popdTileLinks.stream().mapToDouble(t -> t.getTile().supplySoldiers(forceRatio)).sum();
            attempts++;
        }
        resources.incrementPax(recruits);
        deficit = forceRequest - recruits;
        return deficit;
    }

    private void demobilize(double f) {
        double force = f / 4.33;
        resources.decrementPax(force);
        for (Inclusion i : territory.getPopulatedTileLinks()) {
            Tile t = i.getTile();
        }
    }

    public void establishEconomicPolicy(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        int w = worldOrder.weeksThisYear;
        // evaluate tax rate based on initial summed GTPs
        double gdp = territory.getTileLinks().stream().mapToDouble(g -> g.getGrossTileProductivity()).sum();
        this.economicPolicy.setTaxRate(securityStrategy.getBaseline().getTreasury() / (gdp * w) );
    }

    // TODO: Rewire this to consider current resources + (future income - future expenses)
    @Override
    protected void updateEconomicPolicy(WorldOrder wo) {
        WorldOrder worldOrder = wo;
//        int w = worldOrder.weeksThisYear;
//        Double avgTreasury = economicHistory.average();
        Double totalTreasuryDemand = securityStrategy.getTotalDemand().getTreasury();
        if (totalTreasuryDemand > resources.getTreasury()) {
            economicPolicy.setTaxRate(economicPolicy.getTaxRate() * 1.02);
        } else {
            economicPolicy.setTaxRate(economicPolicy.getTaxRate() * 0.99);
        }
        if (urbanization.average() < urbanization.pastYearAverage() && economicPolicy.getLabor() > 0.10) {
            economicPolicy.setCapital(economicPolicy.getCapital() + 0.01);
            economicPolicy.setLabor(economicPolicy.getLabor() - 0.01);
        } else if (urbanization.average() > urbanization.pastYearAverage() && economicPolicy.getLabor() < 0.90) {
            economicPolicy.setCapital(economicPolicy.getCapital() - 0.01);
            economicPolicy.setLabor(economicPolicy.getLabor() + 0.01);
        }

        if ((totalTreasuryDemand * 1.1) < resources.getTreasury()) {
            double invest = resources.getTreasury() - totalTreasuryDemand;
            double pci = invest / territory.getPopulation();
            territory.getPopulatedTileLinks().stream().forEach(t -> t.getTile().takeInvestment(pci));
            resources.decrementTreasury(invest);
        }
    }

    public void recordEconomicHistory(long w) {
        gdpLastYear = territory.getTileLinks().stream().mapToDouble(Inclusion::getGrossTileProductivityLastYear).sum();
        System.out.println(name + " had gdp last year of " + gdpLastYear);
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
    public void loadInstitutionData(int year, WorldOrder wo) {
        PolityFactServiceImpl service = new PolityFactServiceImpl();
        service.loadStateInstitutions(this, wo, year);
    }

    @Override
    public boolean considerIssue(Issue i, WorldOrder wo) {
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
        return wo.random.nextDouble() < p;
    }

    @Override
    public boolean evaluateWarNeed(SimState simState, Issue i) {
        // The polity has a new Issue (Change occurs) and must decide whether they perceive a need to take action. Conceptually,
        // the ProbabilisticCausality agent creates the issue and the ProcessDisposition directly, and the ProcessDisposition
        // contains the logic about whether the polity perceives a need to take military action over the new Issue. In
        // practical terms, we would have to create a Process and a ProcessDisposition (because the ProcessDisposition is
        // a Neo4j relationship and it must know both of its endpoints at creation time); and the Issue may not result in
        // a new Process after all. For convenience, the first step of the conflict logic is inside this method.

        // Neutral Switzerland, you're too complicated to play.
        if (this.cowcode == "225") return false;

        WorldOrder worldOrder = (WorldOrder) simState;
        Issue issue = i;
        Polity t = issue.getTarget();
        long step = worldOrder.getStepNumber();

        if (evaluateWarResolve(issue, worldOrder)) {                                        //
            WarProcess proc = new WarProcess(issue, step);                      //
            issue.setProcess(proc);                                             //
            worldOrder.addProc(proc);                                           //
            proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));       //
            SecurityObjective so = leadership.chooseSecurityObjective(issue, worldOrder);   //
            Resources warStrategy = developWarStrategy(t, so);
            // link this state to the process and prepare security strategy
            ProcessDisposition pdo = new ProcessDisposition.Builder().from(step).owner(this).process(proc)
                    .objective(so).side(0).commitment(warStrategy).build();     //
            // link the target to the process
            ProcessDisposition pdt = new ProcessDisposition.Builder().owner(t).process(proc).from(step)
                    .side(1).build();
            if(so.value > 1) securityStrategy.addSupplemental(pdo,warStrategy);
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean evaluateWarNeed(ProcessDisposition pd, WorldOrder wo) {
        if (evaluateWarResolve(pd.getProcess().getIssue(),wo)) {
            pd.setN(true);
            return true;
        }
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
            PeaceProcess proc = new PeaceProcess(this, issue, wo.getStepNumber());
            issue.setProcess(proc);
            worldOrder.addProc(proc);
            proc.setStopper(worldOrder.schedule.scheduleRepeating(proc));
            ProcessDisposition pdo = new ProcessDisposition.Builder().owner(this).process(proc).build();
            ProcessDisposition pdt = new ProcessDisposition.Builder().owner(this).process(proc).build();
            return true;
        } else {
            return false;
        }
    }

    public boolean evaluateNeedForPeace(ProcessDisposition pd) {
        return true;
    }

    @Override
    public boolean evaluateWarWillingness(ProcessDisposition pd, WorldOrder wo) {
        /*
         *  Is the State willing to undertake action (commit resources) for this conflict?
         *    1. Is the leadership willing (tax, recruit, etc) ?
         *    2. Is the commonWeal willing (pay tax, get drafted, ect) ?
         */
        Issue i = pd.getProcess().getIssue();
        Polity enemy = pd.getProcess().getIssue().getInstigator();
        if(evaluateWarResolve(i, wo)) {
            SecurityObjective response = leadership.chooseSecurityObjective(i, wo);
            Resources defenseStrategy = developWarStrategy(enemy, response);
            pd.commit(defenseStrategy);
            securityStrategy.addSupplemental(pd,defenseStrategy);
            pd.setU(true);
            return true;
        } else {
            return false;
        }
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

    private boolean evaluateWarResolve(Issue i, WorldOrder wo) {
        Issue issue = i;
        Double threshold = 0.50;
        if (this.getForces()==0 && this.cowcode=="225") {
            threshold = 0.90;
        }
        double leadershipOpinion = leadership.evaluateWarNeed(issue, wo);
        double popularOpinion = territory.commonWeal.evaluateWarNeed(issue);
        double meanOpinion = evaluatePolityResolve(leadershipOpinion, popularOpinion);
        boolean resolve = meanOpinion > threshold;
        if (this.cowcode=="225" && resolve) {
            return mobilizeTheReserves(issue);
        }
        return resolve;
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

    @Override
    public void collectTax() {
        Set<Inclusion> popTiles = territory.getPopulatedTileLinks();
        Double revenue = 0.0;
        for (Inclusion i : popTiles) {
            revenue += i.getTile().payTaxes(economicPolicy.getTaxRate());
        }

        if (WorldOrder.DEBUG && revenue.isNaN()) {
            System.out.println(name + " collected " + revenue + " from its tiles.");
        }
        System.out.println(name + " revenue this week is " + revenue + ", but expenses were " + securityStrategy.getBaseline().getTreasury()/52.0);
        this.resources.incrementTreasury(revenue);
    }

    public void collectTax(long s) {
        Double revenue = 0.0;
        for (Inclusion i : territory.getTileLinks()) {
            Double tileRevenue = i.getTile().payTaxes(economicPolicy.getTaxRate());
            if (tileRevenue.isNaN() && WorldOrder.DEBUG) {
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

    private boolean mobilizeTheReserves(Issue i) {
        Polity instigator = i.getInstigator();
        Resources opfor = instigator.getResources();
        double reserve = territory.getPopulation();
        if(reserve * 0.10 > opfor.getPax()) {
            Double needed = opfor.getPax() * 2;
            recruit(needed.intValue());
            return true;
        }
        return false;
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
    public void surrender(WarParticipationFact p, WorldOrder wo) {
        super.surrender(p, wo);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof State)) return false;

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
