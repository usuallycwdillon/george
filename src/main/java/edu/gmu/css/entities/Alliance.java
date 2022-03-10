package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.AllianceType;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@NodeEntity
public class Alliance extends Institution {

    @Id @GeneratedValue
    private Long id;
    @Property String ssType;
    @Property String cowcode;
    @Property String version;
    @Transient AllianceType allianceType;

    @Relationship(direction = Relationship.INCOMING, type = "ENTERED_INTO")
    List<AllianceParticipationFact> participations = new ArrayList<>();
    @Relationship(type = "ALLIANCE_TYPE")
    Set<CategoryList> categoryList = new HashSet<>();
    @Relationship(type = "IS_ALLIANCE", direction = Relationship.INCOMING)
    private AllianceFact allianceFact;


    public Alliance() {
        this.domain = Domain.ALLIANCE;
    }

    @PostLoad
    public void findAllianceType() {
        name = "Alliance";
        domain = Domain.ALLIANCE;
        cost = new Resources.ResourceBuilder().build();
        strength = 0.50;
    }


    public Alliance(Process process) {
        name = "Alliance";
        from = process.getEnded();
        cause = process;
        cost = new Resources.ResourceBuilder().build();
        domain = Domain.ALLIANCE;
    }


    @Override
    public void step(SimState simState) {
        WorldOrder wo = (WorldOrder) simState;
        this.strength = strength * wo.getInstitutionStagnationRate(); // decreases by every year but use increases
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getSsType() {
        return ssType;
    }

    public AllianceType getAllianceType() {
        return allianceType;
    }

    public void setAllianceType(AllianceType allianceType) {
        this.allianceType = allianceType;
    }

    @Override
    public Long getFrom() {
        return from;
    }

    public void setFrom(Long from) {
        this.from = from;
    }

    @Override
    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    public AllianceFact getRelatedFact() {
        return this.allianceFact;
    }

    public Set<CategoryList> getCategoryList() {
        return categoryList;
    }

    public void addParticipations(AllianceParticipationFact ap) {
        participations.add(ap);
    }

    public List<AllianceParticipationFact> getAllianceParticipations() {
        return this.participations;
    }

    public boolean isParticipant(Polity p) {
        for (AllianceParticipationFact f : participations) {
            if(f.getPolity().equals(p)) {
                return true;
            }
        }
        return false;
    }

    public void removeParticipations(AllianceParticipationFact ap) {
        participations.remove(ap);
    }

    public Set<Polity> findPartners() {
        Set<Polity> partners = new HashSet<>();
        for (AllianceParticipationFact f : participations) {
            partners.add(f.getPolity());
        }
        return partners;
     }




    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Alliance alliance = (Alliance) o;

        return getId().equals(alliance.getId());
    }

    @Override
    public int hashCode() {
        return getId().hashCode();
    }
}
