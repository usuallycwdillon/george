package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

public class AllianceFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property private String cowcode;
    @Property private String ssType;
    @Property private String version;
    @Transient private Double strength;

    @Relationship(type = "IS_ALLIANCE")
    private Alliance alliance;

    public AllianceFact() {

    }

    @Override
    public Long getId() {
        return id;
    }

    public String getCowcode() {
        return cowcode;
    }

    public void setCowcode(String cowcode) {
        this.cowcode = cowcode;
    }

    public String getSsType() {
        return ssType;
    }

    public void setSsType(String ssType) {
        this.ssType = ssType;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public Double getStrength() {
        return strength;
    }

    public void setStrength(Double strength) {
        this.strength = strength;
    }

    public Alliance getAlliance() {
        return alliance;
    }

    public void setAlliance(Alliance alliance) {
        this.alliance = alliance;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        AllianceFact that = (AllianceFact) o;

        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        if (getCowcode() != null ? !getCowcode().equals(that.getCowcode()) : that.getCowcode() != null) return false;
        return getAlliance().equals(that.getAlliance());
    }

    @Override
    public int hashCode() {
        int result = super.hashCode();
        result = 31 * result + (getId() != null ? getId().hashCode() : 0);
        result = 31 * result + (getCowcode() != null ? getCowcode().hashCode() : 0);
        result = 31 * result + getAlliance().hashCode();
        return result;
    }
}
