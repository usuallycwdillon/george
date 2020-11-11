package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.AllianceType;
import edu.gmu.css.data.Resources;
import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;
import sim.engine.SimState;

import java.util.*;

@NodeEntity
public class Alliance extends Institution {

    @Id @GeneratedValue
    private Long id;
    @Property
    String ssType;
    @Transient
    AllianceType allianceType;
    @Property @Convert(DateConverter.class)
    Long from;
    @Property @Convert(DateConverter.class)
    Long until;

    @Relationship(direction = Relationship.INCOMING, type = "ENTERED_INTO")
    Set<Fact> relatedFacts = new HashSet<>();
    @Relationship(type = "PART_OF")
    Set<CategoryList> categoryList = new HashSet<>();
    @Relationship
    LinkedList<AllianceParticipationFact> participations = new LinkedList<>();


    public Alliance() {
        if (allianceType==null) {
            allianceType = AllianceType.name(ssType);
        }
        name = "Alliance";
    }

    public Alliance(Process process) {
        name = "Alliance";
        from = process.getEnded();
        cause = process;
        cost = new Resources.ResourceBuilder().build();
    }


    @Override
    public void step(SimState simState) {
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

    public Set<Fact> getRelatedFacts() {
        return relatedFacts;
    }

    public Set<CategoryList> getCategoryList() {
        return categoryList;
    }

    public void addParticipations(AllianceParticipationFact ap) {
        participations.add(ap);
    }

    public LinkedList<AllianceParticipationFact> getAllianceParticipations() {
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
