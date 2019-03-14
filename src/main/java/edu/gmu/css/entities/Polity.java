package edu.gmu.css.entities;

import ec.util.MersenneTwisterFast;
import edu.gmu.css.agents.Leadership;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Domain;
import edu.gmu.css.agents.Process;
import edu.gmu.css.relations.*;
import edu.gmu.css.service.Neo4jSessionFactory;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.model.Result;
import sim.engine.SimState;

import java.io.Serializable;
import java.util.*;
import java.util.function.BiPredicate;


@NodeEntity
public class Polity extends Entity implements Serializable {

    @Id @GeneratedValue
    private Long id;
    @Relationship (type = "OCCUPIED")
    protected Set<OccupiedRelation> allTerritories;
    @Transient
    protected Territory territory;
    @Relationship (direction = "INCOMING")
    protected Leadership leadership;
    @Relationship(type = "SHARES_BORDER")
    protected Set<BorderAgreement> bordersWith = new HashSet<>();
    @Relationship
    protected List<ProcessDisposition> processList = new ArrayList<>();
    @Relationship(type = "REPRESENTATION")
    protected Set<DiplomaticRepresentation> representedAt = new HashSet<>();
    @Relationship(type = "ALLIANCE_PARTICIPATION")
    protected Set<AllianceParticipation> alliances = new HashSet<>();
    @Transient
    protected List<InstitutionParticipation> institutionList = new ArrayList<>();
    @Transient
    protected Resources securityStrategy = new Resources.ResourceBuilder().build();
    @Transient
    protected Resources foreignStrategy = new Resources.ResourceBuilder().build();
    @Transient
    protected EconomicPolicy economicPolicy;
    @Transient
    protected Resources resources = new Resources.ResourceBuilder().treasury(10000).pax(10000).build();
    @Transient
    protected MersenneTwisterFast random = new MersenneTwisterFast();


    public Polity () {
    }

    public Polity (int startYear) {
    }


    public Long getId() {
        return id;
    }

    public Resources getResources() {
        return resources;
    }

    public void setResources(Resources resources) {
        this.resources = resources;
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

    public List<InstitutionParticipation> getInstitutionList() {
        return institutionList;
    }

    public void setInstitutionList(List<InstitutionParticipation> institutionList) {
        this.institutionList = institutionList;
    }

    public void addInstitution(InstitutionParticipation i) {
        institutionList.add(i);
    }

    public List<ProcessDisposition> getProcessList() {
        return processList;
    }

    public void addProcess(ProcessDisposition disposition) {
        processList.add(disposition);
        Process process = disposition.getProcess();
        Domain domain = process.getDomain();
        Polity owner = disposition.getOwner();
//        switch (domain) {
//            case WAR:
//        }
    }

    public Resources getSecurityStrategy() {
        return securityStrategy;
    }

    public void setSecurityStrategy(Resources securityStrategy) {
        // Some portion of overall resources that can be used for wars
        if (securityStrategy.getTreasury() < resources.getTreasury()
                && securityStrategy.getPax() < resources.getPax()) {
            this.securityStrategy = securityStrategy;
        } else {
            Integer pax = (int) (resources.getPax() * 0.90);
            Double cost = resources.getTreasury() * 0.90;
            securityStrategy = new Resources.ResourceBuilder()
                    .pax(pax)
                    .treasury(cost)
                    .build();
        }

    }

    private Resources requestNewStratgy(Resources proposed) {
        if (resources.isSufficientFor(securityStrategy.evaluativeSum(proposed))) {
            securityStrategy.increaseBy(proposed);
            return proposed;
        } else {
            Resources available = resources.evaluativeAvailableDifference(proposed);

            return available;
        }
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

    public int getPopulation() {
        return territory.getPopulation();
    }

    public int getForces() {
        return resources.getPax();
    }

    protected void recruit() {

    }

    private void collectTax() {

    }

    public void createWarStrategy(Process process, int size) {

    }

    public boolean evaluateAttackSuccess(ProcessDisposition disposition) {
        WarProcess war = (WarProcess) disposition.getProcess();
        int commitment = disposition.getCommitment().getPax();
        int magnitude = war.getInvolvement().getPax();
        int extent = war.getProcessDispositionList().size();
        return magnitude / extent < commitment;
    }

    public Resources allocateResources(Resources request) {
        int force = Math.min(request.getPax(), resources.getPax());
        double funds = Math.min(request.getTreasury(), resources.getTreasury());
        resources.subtractPax(force);
        resources.subtractTreasury(funds);
        return new Resources.ResourceBuilder().pax(force).treasury(funds).build();
    }

    public Resources evaluateResources(Resources request) {
        int force = Math.min(request.getPax(), resources.getPax());
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

    public boolean willProbablyWin(Process process) {

        return true;
    }

    public boolean willEscalate() {
        return leadership.shouldEscalate();
    }

    class EconomicPolicy {

    }

    public boolean hasInsufficentResources(Process process) {

        return true;
    }

    public boolean evaluateNeedForPeace() {

        return true;
    }

    public void makeConcessionForPeace() {

    }

    public void setCurrentTerritory() {
        Map<String, Object> params = new HashMap<>();
        params.put("id", this.id);
        params.put("year", WorldOrder.getStartYear());
        String territoryQuery = "MATCH (p:Polity)-[:OCCUPIED]-(t:Territory{year:$year})" +
                "WHERE id(p)=$id RETURN t LIMIT 1";
        Territory t = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .queryForObject(Territory.class, territoryQuery, params);
        territory = t;
    }

    public void loadInstitutionData(int year) {
        Map<String, Object> params = new HashMap<>();
        params.put("year", year);
        params.put("name", "" + year);
        params.put("id", this.getId());
        // borders
        String borderQuery = "MATCH (p:Polity)-[sb:SHARES_BORDER]-(b:Border)-[d:DURING]-(y:Year{name:{name}}) " +
                "WHERE id(p) = {id} RETURN p, sb, b";
        Iterable<BorderAgreement> borders = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .query(BorderAgreement.class, borderQuery, params);
        for (BorderAgreement b : borders) {
            bordersWith.add(b);
            institutionList.add(b);
        }
        // dipEx
        String dipQuery = "MATCH (p:Polity)-[r:REPRESENTATION]-(d:DiplomaticExchange)-[:DURING]-(y:Year{name:{name}}) " +
                "WHERE id(p) = {id} RETURN r";
        Iterable<DiplomaticRepresentation> dipEx = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .query(DiplomaticRepresentation.class, dipQuery, params);
        for (DiplomaticRepresentation d : dipEx) {
            representedAt.add(d);
            institutionList.add(d);
        }
        // alliances
        String allianceQuery = "MATCH (p:Polity)-[e:ENTERED]-(af:AllianceParticipationFact)-[:ENTERED_INTO]-(a:Alliance) " +
                "WHERE id(p) = {id} AND e.from.year <= {year} AND e.until.year > {year} RETURN p, af, a";
        Result result = Neo4jSessionFactory.getInstance().getNeo4jSession()
                .query(allianceQuery, params, true);
        Iterator it = result.iterator();
        while (it.hasNext()) {
            Map<String, Object> item = (Map<String, Object>) it.next();
            Polity p = (Polity) item.get("p");
            Alliance a = (Alliance) item.get("a");
            Fact af = (Fact) item.get("af");
            AllianceParticipation ap = new AllianceParticipation(p, a);
            ap.setFrom(af.getFrom());
//            Neo4jSessionFactory.getInstance().getNeo4jSession().save(ap);
            alliances.add(ap);
            institutionList.add(ap);
//            Neo4jSessionFactory.getInstance().getNeo4jSession().save(ap);
        }
        // trade
//        String tradeQuery = "";
        // igos
//        String igoQuery = "";
    }


    class WarStrategy {
        WarStrategy() {

        }
    }





}
