package edu.gmu.css.entities;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.agents.Process;
import edu.gmu.css.data.AllianceType;
import edu.gmu.css.relations.AllianceParticipation;
import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;

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
    @Transient
    Set<AllianceParticipation> participations = new HashSet<>();



    public Alliance() {
        if (allianceType==null) {
            allianceType = AllianceType.name(ssType);
        }
        name = "Alliance";
    }

    public Alliance(Process process) {
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

    public Set<AllianceParticipation> getParticipations() {
        return this.participations;
    }

    public void addParticipations(AllianceParticipation ap) {
        participations.add(ap);
    }

    public void removeParticipations(AllianceParticipation ap) {
        participations.remove(ap);
    }

    public Set<Polity> findPartners() {
        Set<Polity> partners = new HashSet<>();
        for (AllianceParticipation ap : participations) {
            partners.add(ap.getParticipant());
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
