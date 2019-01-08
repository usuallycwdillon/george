package edu.gmu.css.entities;

import edu.gmu.css.agents.Leadership;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.data.Domain;
import edu.gmu.css.worldOrder.Institution;
import edu.gmu.css.agents.Process;
import edu.gmu.css.worldOrder.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.io.Serializable;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


@NodeEntity
public class Polity implements Serializable {

    @Id @GeneratedValue
    private Long id;
    @Relationship (direction = "INCOMING", type = "OCCUPIED")
    private Territory territory;
    @Relationship (direction = "INCOMING")
    private Leadership leadership;
    @Relationship(type = "BORDERS_WITH")                                 // State's neighbors are mediated by territories they occupy
    private Set<Polity> bordersWith = new HashSet<>();
    @Relationship
    private List<ProcessDisposition> processList;
    @Transient
    private Set<Polity> suzereinSet;
    @Transient
    private List<Institution> institutionList;
    @Transient
    private Resources securityStrategy = new Resources.ResourceBuilder().build();
    @Transient
    private EconomicPolicy economicPolicy;
    @Transient
    private Resources resources = new Resources.ResourceBuilder().build();


    public Polity () {
    }

    public Polity (SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;

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

    public Leadership getLeadership() {
        return leadership;
    }

    public void setLeadership(Leadership leadership) {
        this.leadership = leadership;
    }

    public Set<Polity> getSuzereinSet() {
        return suzereinSet;
    }

    public void setSuzereinSet(Set<Polity> suzereinSet) {
        this.suzereinSet = suzereinSet;
    }

    public void addSuzerein(Polity suzereign) {
        suzereinSet.add(suzereign);
    }

    public List<Institution> getInstitutionList() {
        return institutionList;
    }

    public void setInstitutionList(List<Institution> institutionList) {
        this.institutionList = institutionList;
    }

    public void addInstitution(Institution i) {
        institutionList.add(i);
    }

    public List<ProcessDisposition> getProcessList() {
        return processList;
    }

    public void setProcessList(List<ProcessDisposition> processList) {
        this.processList = processList;
    }

    public void addProcess(ProcessDisposition disposition) {
        processList.add(disposition);
//        Process process = disposition.getProcess();
        Domain domain = disposition.getProcess().getDomain();
        Polity owner = disposition.getOwner();
        switch (domain) {
            case WAR:
                if (owner.equals(this)) {

                }
        }

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

    private void recruit() {

    }

    private void collectTax() {

    }

    public void createWarStrategy(Process process, int size) {

    }

    private Resources allocateResources(Resources request) {
        int force = Math.min(request.getPax(), resources.getPax());
        double funds = Math.min(request.getTreasury(), resources.getTreasury());
        resources.subtractPax(force);
        resources.subtractTreasury(funds);
        return new Resources.ResourceBuilder().pax(force).treasury(funds).build();
    }

    private Resources evaluateResources(Resources request) {
        int force = Math.min(request.getPax(), resources.getPax());
        double funds = Math.min(request.getTreasury(), resources.getTreasury());
        return new Resources.ResourceBuilder().pax(force).treasury(funds).build();
    }

    class EconomicPolicy {

    }

    class WarStrategy {
        WarStrategy() {

        }
    }





}
