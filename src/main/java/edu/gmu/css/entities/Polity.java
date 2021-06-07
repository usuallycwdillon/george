package edu.gmu.css.entities;

import edu.gmu.css.agents.Issue;
import edu.gmu.css.agents.Leadership;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.*;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.relations.ProcessDisposition;
import edu.gmu.css.service.DiscretePolityFactServiceImpl;
import edu.gmu.css.service.FactServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.awt.*;
import java.util.List;
import java.util.*;


@NodeEntity
public class Polity extends Entity implements Steppable {

    @Id @GeneratedValue
    private Long id;
    @Property
    protected int color;
    @Property
    protected String name;
    @Transient
    protected Territory territory;
    @Transient
    protected List<Fact> factList = new ArrayList<>();
//     Resources, Strategies and Policies
    @Transient  // The actual resources available to this polity
    protected Resources resources = new Resources.ResourceBuilder().build();
    @Transient
    protected SecurityStrategy securityStrategy;
    @Transient
    protected SecurityPolicy securityPolicy = new SecurityPolicy(0.9, 1.0);
    @Transient
    protected EconomicPolicy economicPolicy = new EconomicPolicy(0.4, 0.6, 0.0004);
    @Transient
    protected DiscretePolityFact polityFact;
    @Transient
    protected Color polColor = new Color(color);
    @Transient
    protected Map<String, Double> warParams;
    @Transient
    protected Year year;

    @Relationship (type = "OCCUPIED")
    protected Set<OccupiedRelation> allTerritories = new HashSet<>();
    @Relationship (type="LEADERSHIP_OF", direction = Relationship.INCOMING)
    protected Leadership leadership;
    @Relationship(type = "SHARES_BORDER")
    protected Set<BorderFact> bordersWith = new HashSet<>();
    @Relationship(type = "REPRESENTED")
    protected Set<DipExFact> representedAt = new HashSet<>();
    @Relationship(type = "ALLIANCE_PARTICIPATION")
    protected Set<AllianceParticipationFact> alliances = new HashSet<>();
    @Relationship(type = "PARTICIPATED")
    protected Set<WarParticipationFact> warList = new HashSet<>();
    @Relationship(type = "DISPUTED")
    protected Set<DisputeParticipationFact> disputeList = new HashSet<>();
    @Relationship(type = "AGREED")
    protected Set<PeaceFact> peaceList = new HashSet<>();
    @Relationship(type = "MEMBERSHIP")
    protected Set<IgoMembershipFact> organizations = new HashSet<>();
    @Relationship(type="PRODUCED")
    protected Set<GdpFact> gdpHistory = new HashSet<>();
    @Relationship(type = "POPULATION")
    protected Set<PopulationFact> populationHistory = new HashSet<>();
    @Transient
    protected Map<Polity, Double> threatNet = new HashMap<>();
    @Transient
    protected List<ProcessDisposition> processList = new ArrayList<>();


    public Polity () {

    }


    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
//        updateEconomicPolicy(this.leadership, worldOrder);
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Color getPolColor() {
        polColor = new Color(color);
        return polColor;
    }

    public void setPolColor(Color polColor) {
        this.polColor = polColor;
    }

    public Resources getResources() {
        return resources;
    }

    public void setResources(Resources r) {
        this.resources = r;
    }

    public Territory getTerritory() {
        return territory;
    }

    public void setTerritory(Territory territory) {
        this.territory = territory;
    }

    public Set<OccupiedRelation> getAllTerritories() {
        return this.allTerritories;
    }

    public Set<OccupiedRelation> setAllTerritories(Set<OccupiedRelation> newTerritories) {
        return this.allTerritories = newTerritories;
    }

    public void addTerritory(Territory newTerritory, Long step) {
        OccupiedRelation occupation = new OccupiedRelation(this, newTerritory, step);
        this.allTerritories.add(occupation);
    }

    public Leadership getLeadership() {
        return leadership;
    }

    public void setLeadership(Leadership leadership) {
        this.leadership = leadership;
    }

    public List<Fact> getFactList() {
        return factList;
    }

    public void setFactList(List<Fact> facts) {
        this.factList = facts;
    }

    public void addFact(Fact f) {
        factList.add(f);
    }

    public List<ProcessDisposition> getProcessList() {
        return processList;
    }

    public void addProcess(ProcessDisposition disposition) {
        processList.add(disposition);
        Process process = disposition.getProcess();
        Domain domain = process.getDomain();
        Polity owner = disposition.getOwner();
    }

    public void removeProcess(ProcessDisposition disposition) {
        processList.remove(disposition);
    }

    public SecurityStrategy getSecurityStrategy() {
        return this.securityStrategy;
    }

    public void setSecurityStrategy(Resources newStrategy) {
        this.securityStrategy = new SecurityStrategy(newStrategy);
    }

//    public Resources getEconomicStrategy() {
//        return economicStrategy;
//    }
//
//    public void setEconomicStrategy(Resources economicStrategy) {
//        this.economicStrategy = economicStrategy;
//    }


    public Resources getMilitaryStrategy() {
        return securityStrategy.getMilitaryStrategy();
    }

    public Resources getForeignStrategy() {
        return securityStrategy.getForeignStrategy();
    }

    public EconomicPolicy getEconomicPolicy() {
        return economicPolicy;
    }

    public void setEconomicPolicy(EconomicPolicy economicPolicy) {
        this.economicPolicy = economicPolicy;
    }

    public double getTreasury() {
        return resources.getTreasury();
    }

    public double getPopulation() {
        if (territory.getPopulation()==null | territory.getPopulation()==0.0) {
            return territory.getCurrentPopulation();
        } else {
            return territory.getPopulation();
        }

    }

    public double geUrbanPopulation() {
        return territory.getUrbanPopulation();
    }

    public double getGrossDomesticProduct() {
        return territory.getGDP();
    }

    public double getForces() {
        return resources.getPax();
    }

    public Set<BorderFact> getBordersWith() {
        return bordersWith;
    }

    public void addBorderFact(BorderFact f) {
        bordersWith.add(f);
    }

    public void addBorderFacts(Set<BorderFact> facts) {
        bordersWith.addAll(facts);
    }

    public Set<AllianceParticipationFact> getAlliances() {
        return alliances;
    }

    public void addAllianceParticipationFact(AllianceParticipationFact f) {
        alliances.add(f);
    }

    public void addAllianceParticipationFacts(Set<AllianceParticipationFact> facts) {
        alliances.addAll(facts);
    }

    public Set<WarParticipationFact> getWarList() {
        return this.warList;
    }

    public void addWarParticipationFact(WarParticipationFact f) {
        warList.add(f);
    }

    public void removeWarParticipationFact(WarParticipationFact f) {
        warList.remove(f);
    }

    public void addDisputeParticipationFact(DisputeParticipationFact f) {
        this.disputeList.add(f);
    }

    public void removeDisputeParticipationFact(DisputeParticipationFact f) {
        disputeList.remove(f);
    }

    public Set<DisputeParticipationFact> getDisputeList() {
        return this.disputeList;
    }

    public void addPeaceFact(PeaceFact f) {
        peaceList.add(f);
    }

    public void removePeaceFact(PeaceFact f) {
        peaceList.remove(f);
    }

    public Set<PeaceFact> getPeaceFacts() {
        return peaceList;
    }

    public void addRepresentation(DipExFact f) {
        representedAt.add(f);
    }

    public void removeRepresentation(DipExFact f) {
        representedAt.remove(f);
    }

    public Set<DipExFact> getRepresentation() {
        return representedAt;
    }

    public DiscretePolityFact getPolityFact() {
        return polityFact;
    }

    public Map<String, Double> getWarParams() {
        return warParams;
    }

    public void setWarParams(Map<String, Double> warParams) {
        this.warParams = warParams;
    }

    protected void recruit(int force) {
        Resources draft = new Resources.ResourceBuilder().build();
    }

    protected void addEconomicHistory(GdpFact f) {
        this.gdpHistory.add(f);
    }

    protected double recruit(double force) {
        double deficit = force;
        return deficit;
    }

    protected double recruit() {
        double deficit = 0.0;
        return deficit;
    }

    public void collectTax() {

    }

    public void updateEconomicPolicy(Leadership l, WorldOrder wo) {

    }

    public Year getYear() {
        return year;
    }

    public void setYear(Year y) {
        this.year = y;
    }

    public void takeCensus(WorldOrder wo) {
        territory.updateTotals();
        if (WorldOrder.RECORDING) {
            WorldOrder worldOrder = wo;
            Dataset run = wo.getModelRun();
            PopulationFact pf = new PopulationFact.FactBuilder().dataset(run).polity(this).value(territory.getCurrentPopulation())
                    .during(wo.getDataYear()).build();
            run.addFacts(pf);
            UrbanPopulationFact uf = new UrbanPopulationFact.FactBuilder().dataset(run).polity(this)
                    .value(territory.getCurrentUrbanPopulation()).during(wo.getDataYear()).build();
            run.addFacts(uf);

            new FactServiceImpl().createOrUpdate(pf);
            new FactServiceImpl().createOrUpdate(uf);
        }
    }

    public boolean willRelent(ProcessDisposition p, WorldOrder wo) {
        return wo.random.nextBoolean();
    }

    public double getPublicSDP() {
        if(territory.getGDP()==null | territory.getGDP()==0.0) {
            return territory.getCurrentSDP();
        } else {
            return territory.getPopulation();
        }
    }

    protected void createWarStrategy(Process process, int size) {

    }

    public boolean resolveIssue(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean considerIssue(Issue i, WorldOrder wo) {
        return wo.random.nextDouble() < 0.5;
    }

    public boolean evaluateWarNeed(WorldOrder wo, Issue i) {
        // The polity has a new Issue (Change occurs) and must decide whether they perceive a need to take action. Conceptually,
        // the ProbabilisticCausality agent creates the issue and the ProcessDisposition directly, and the ProcessDisposition
        // contains the logic about whether the polity perceives a need to take military action over the new Issue. In
        // practical terms, we would have to create a Process and a ProcessDisposition (because the ProcessDisposition is
        // a Neo4j relationship and it must know both of its endpoints at creation time); and the Issue may not result in
        // a new Process after all. For convenience, the first step of the conflict logic is inside this method.
        // But Polities which are not States cannot do much in the simulation at this stage of development.
        return false;
    }

    public boolean defenseNeed(ProcessDisposition pd, WorldOrder wo) {
        return false;
    }

    public boolean evaluateWarNeed(ProcessDisposition pd, WorldOrder wo) {
        return false;
    }

    public boolean evaluateWarWillingness(ProcessDisposition pd, WorldOrder wo) {
        return false;
    }

    public boolean evaluateAttackSuccess(ProcessDisposition pd) {
        return false;
    }

    public void surrender(ProcessDisposition p, WorldOrder wo) {

    }

    public Resources allocateResources(Resources request) {
        double force = Math.min(request.getPax(), resources.getPax());
        double funds = Math.min(request.getTreasury(), resources.getTreasury());
        resources.incrementPax(force);
        resources.incrementTreasury(funds);
        return new Resources.ResourceBuilder().pax(force).treasury(funds).build();
    }

    public Resources evaluateResources(Resources request) {
        double force = Math.min(request.getPax(), resources.getPax());
        double funds = Math.min(request.getTreasury(), resources.getTreasury());
        return new Resources.ResourceBuilder().pax(force).treasury(funds).build();
    }

    public void getThreatResponse(ProcessDisposition disposition, Resources threat) {
        // commit resources in response to threat upto twice the threat
        Resources available = leadership.respondToThreat(disposition, threat);
        disposition.commit(available);
        if (available.getPax() > 0) {
            disposition.setN(true);
        }
    }

    public boolean evaluateBeginDipEx(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean existsDipEx(Polity p) {
        Polity target = p;
        for (DipExFact f : this.getRepresentation()) {
            if(f.getMission()==this && f.getPolity() == target)  return true;
        }
        return false;
    }

    public DiplomaticExchange hasDipEx(Polity p) {
        Polity target = p;
        for (DipExFact f : this.getRepresentation()) {
            if(f.getMission()==this && f.getPolity() == target) {
                return f.getInstitution();
            }
        }
        return null;
    }

    public void addDiplomaticFacts(Set<DipExFact> facts) {
        representedAt.addAll(facts);
    }

    public boolean resolvedThroughDiplomacy(WorldOrder wo, Issue i, DiplomaticExchange d) {
        return false;
    }

    public boolean evaluateForeignPolicyNeed(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean evaluateBorderAgreementNeed(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean evaluateTradeAgreementNeed(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean evaluateNeedForPeace(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean willProbablyWin(Process process) {

        return true;
    }

    public Map<Polity, Double> getThreatNet() {
        return threatNet;
    }

    public void setThreatNet(Map<Polity, Double> t) {
        this.threatNet = t;
    }

    public void addThreat(Polity p, Double d) {
        this.threatNet.put(p, d);
    }

    public void removeThreat(Polity p) {
        this.threatNet.remove(p);
    }

    public boolean hasInsuficentResources(Institution war) {
        return true;
    }

    public boolean evaluateNeedForPeace(WorldOrder wo) {
        return leadership.reconsiderPeace(wo);
    }

    public void makeConcessionForPeace(ProcessDisposition p, WorldOrder wo) {
        if (wo.random.nextDouble() < 0.50) {
            p.setU(true);
        }
    }

//    public void setCurrentTerritory() {
//        Map<String, Object> params = new HashMap<>();
//        params.put("id", this.id);
//        params.put("year", WorldOrder.getFromYear());
//        String territoryQuery = "MATCH (p:Polity)-[:OCCUPIED]-(t:Territory{year:$year})" +
//                "WHERE id(p)=$id RETURN t LIMIT 1";
//        Territory t = Neo4jSessionFactory.getInstance().getNeo4jSession()
//                .queryForObject(Territory.class, territoryQuery, params);
//        territory = t;
//    }



    public boolean evaluateAllianceNeed(WorldOrder wo, Issue i) {
        return false;
    }

    public boolean existsAlliance(Polity p) {
        /**
         * returns true if given polity is my alliance partner
         */
        Polity target = p;
        for (AllianceParticipationFact f : this.getAlliances()) {
            Alliance alliance = f.getAlliance();
            return alliance.findPartners().contains(target);
        }
        return false;
    }

    public Alliance hasAlliance(Polity p) {
        Polity target = p;
        Alliance a = null;
        Double strength = 0.0;
        for (AllianceParticipationFact f : this.getAlliances()) {
            Alliance alliance = f.getAlliance();
            if (alliance.findPartners().contains(target) && alliance.getStrength() > strength) {
                a = alliance;
            }
        }
        return a;
    }

    public Map<Double, Alliance> findAlliancesAgainst(Polity p) {
        Polity target = p;
        Map<Double, Alliance> alliances = new HashMap<>();
        for (AllianceParticipationFact f : this.getAlliances()) {
            Alliance alliance = f.getAlliance();
            if (!alliance.findPartners().contains(target))
                alliances.put(alliance.getStrength(), alliance);
        }
        return alliances;
    }
//
//    public AllianceParticipationFact getStrongestAllianceParticipationFact(Polity t) {
//        Polity target = t;
//        Alliance bestSoFar = null;
//        AllianceParticipationFact apf = null;
//        int index = 0;
//        for (AllianceParticipationFact f : this.getAlliances()) {
//            Alliance a = f.findAllianceWithPartner(target);
//            if(index == 0) {
//                bestSoFar = a;
//                apf = f;
//            }
//            if(a.getStrength() > bestSoFar.getStrength() ) {
//                bestSoFar = a;
//                apf = f;
//            }
//        }
//        return apf;
//    }

    public boolean resolvedThroughAlliance(WorldOrder wo, Issue i, Alliance a) {
        return false;
    }

    public boolean findPolityData(int year) {
        DiscretePolityFact dpf = new DiscretePolityFactServiceImpl().getPolityData(this, year);
        if (dpf != null) {
            polityFact = dpf;
            return true;
        } else {
            return false;
        }
    }

    public void setNeutralPolityFact() {
        DiscretePolityFact f = new DiscretePolityFact();
        f.setAutocracyRating(5);
        f.setDemocracyRating(5);
        f.setPolityScore(0);
        f.setSource("World Order Simulation");
        f.setFrom(0L);
        this.polityFact = f;
    }

    public void loadInstitutionData(WorldOrder wo) {
        int year = wo.getFromYear();
        this.polityFact = new DiscretePolityFactServiceImpl().getPolityData(this,year);

        // Load Polity's Borders

        // Load dipEx missions

        // Load alliances

        // Load trade partners

        // Load IGO memberbership

    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Polity)) return false;

        Polity polity = (Polity) o;

        if (getId() != null ? !getId().equals(polity.getId()) : polity.getId() != null) return false;
        return getName().equals(polity.getName());
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getName().hashCode();
        return result;
    }
}
