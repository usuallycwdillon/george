package edu.gmu.css.entities;

import edu.gmu.css.agents.Leadership;
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
    private SecurityStrategy securityStrategy;
    @Transient
    private EconomicPolicy economicPolicy;
    @Transient
    private Resources resources;


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
    }

    public SecurityStrategy getSecurityStrategy() {
        return securityStrategy;
    }

    public void setSecurityStrategy(SecurityStrategy securityStrategy) {
        this.securityStrategy = securityStrategy;
    }

    public EconomicPolicy getEconomicPolicy() {
        return economicPolicy;
    }

    public void setEconomicPolicy(EconomicPolicy economicPolicy) {
        this.economicPolicy = economicPolicy;
    }

    private void recruit() {

    }

    private void collectTax() {

    }



    class SecurityStrategy {

    }

    class EconomicPolicy {

    }


}
