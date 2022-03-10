package edu.gmu.css.entities;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import org.neo4j.ogm.annotation.*;

@NodeEntity
public class NetworkFact extends Fact {

    @Id @GeneratedValue private Long id;
    @Property private double mySDP;
    @Property private double relativeSDP;
    @Property private double myThreat;
    @Property private double relativeThreat;
    @Property private double myBorderStrength;
    @Property private double relativeBorderStrength;
    @Property private double myAllianceStrength;
    @Property private double relativeAllianceStrength;
    @Property private double myDiplomaticStrength;
    @Property private double relativeDiplomaticStrength;
    @Property private int thisYear;

    @Relationship(type = "RELATION", direction = Relationship.INCOMING)
    Polity me;
    @Relationship(type = "RELATION_TO")
    Polity them;

    public NetworkFact() {

    }

    private NetworkFact (FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.during = builder.during;
        this.thisYear = builder.thisYear;
        this.name = builder.name;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.mySDP = builder.mySDP;
        this.relativeSDP = builder.relativeSDP;
        this.myThreat = builder.myThreat;
        this.relativeThreat = builder.relativeThreat;
        this.myBorderStrength = builder.myBorderStrength;
        this.relativeBorderStrength = builder.relativeBorderStrength;
        this.myAllianceStrength = builder.myAllianceStrength;
        this.relativeAllianceStrength = builder.relativeAllianceStrength;
        this.myDiplomaticStrength = builder.myDiplomaticStrength;
        this.relativeDiplomaticStrength = builder.relativeDiplomaticStrength;
        this.me = builder.me;
        this.them = builder.them;
        this.dataset = builder.dataset;
        this.simulationRun = builder.simulationRun;
    }

    public static class FactBuilder {
        private Long from;
        private Long until;
        private Long during;
        private int thisYear;
        private final String name = "Network Metrics";
        private String subject = "Not Collected";
        private final String predicate = "RELATION";
        private String object = "Not Collected";
        private String simulationRun;
        private double mySDP;
        private double relativeSDP;
        private double myThreat;
        private double relativeThreat;
        private double myBorderStrength;
        private double relativeBorderStrength;
        private double myAllianceStrength;
        private double relativeAllianceStrength;
        private double myDiplomaticStrength;
        private double relativeDiplomaticStrength;
        private Dataset dataset;
        private Polity me;
        private Polity them;

        public FactBuilder from(Long l) {
            this.from = l;
            this.until = l + 52L;
            return this;
        }

        public FactBuilder until(Long l) {
            this.until = l;
            return this;
        }

        public FactBuilder during(Long l) {
            this.during = l;
            return this;
        }

        public FactBuilder thisYear(int i) {
            this.thisYear = i;
            return this;
        }

        public FactBuilder subject(String s) {
            this.subject = s;
            return this;
        }

        public FactBuilder object(String s) {
            this.object = s;
            return this;
        }

        public FactBuilder mySDP(double d) {
            this.mySDP = d;
            return this;
        }

        public FactBuilder relativeSDP(double d) {
            this.relativeSDP = d;
            return this;
        }

        public FactBuilder myThreat(double d) {
            this.myThreat = d;
            return this;
        }

        public FactBuilder relativeThreat(double d) {
            this.relativeThreat = d;
            return this;
        }

        public FactBuilder myBorderStrength(double d) {
            this.myBorderStrength = d;
            return this;
        }

        public FactBuilder relativeBorderStrength(double d) {
            this.relativeBorderStrength = d;
            return this;
        }

        public FactBuilder myDiplomaticStrength(double d) {
            this.myDiplomaticStrength = d;
            return this;
        }

        public FactBuilder relativeDiplomaticStrength(double d) {
            this.relativeDiplomaticStrength = d;
            return this;
        }

        public FactBuilder myAllianceStrength(double d) {
            this.myAllianceStrength = d;
            return this;
        }

        public FactBuilder relativeAllianceStrength(double d) {
            this.relativeAllianceStrength = d;
            return this;
        }

        public FactBuilder me(Polity p) {
            this.me = p;
            return this;
        }

        public FactBuilder them(Polity p) {
            this.them = p;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            this.simulationRun = d.getName();
            return this;
        }

        public NetworkFact build() {
            return new NetworkFact(this);
        }

    }


    @Override
    public Long getId() {
        return this.id;
    }

    public double getMySDP() {
        return mySDP;
    }

    public void setMySDP(double mySDP) {
        this.mySDP = mySDP;
    }

    public double getRelativeSDP() {
        return relativeSDP;
    }

    public void setRelativeSDP(double relativeSDP) {
        this.relativeSDP = relativeSDP;
    }

    public double getMyThreat() {
        return myThreat;
    }

    public void setMyThreat(double myThreat) {
        this.myThreat = myThreat;
    }

    public double getRelativeThreat() {
        return relativeThreat;
    }

    public void setRelativeThreat(double relativeThreat) {
        this.relativeThreat = relativeThreat;
    }

    public double getMyBorderStrength() {
        return myBorderStrength;
    }

    public void setMyBorderStrength(double myBorderStrength) {
        this.myBorderStrength = myBorderStrength;
    }

    public double getRelativeBorderStrength() {
        return relativeBorderStrength;
    }

    public void setRelativeBorderStrength(double relativeBorderStrength) {
        this.relativeBorderStrength = relativeBorderStrength;
    }

    public double getMyAllianceStrength() {
        return myAllianceStrength;
    }

    public void setMyAllianceStrength(double myAllianceStrength) {
        this.myAllianceStrength = myAllianceStrength;
    }

    public double getRelativeAllianceStrength() {
        return relativeAllianceStrength;
    }

    public void setRelativeAllianceStrength(double relativeAllianceStrength) {
        this.relativeAllianceStrength = relativeAllianceStrength;
    }

    public double getMyDiplomaticStrength() {
        return myDiplomaticStrength;
    }

    public void setMyDiplomaticStrength(double myDiplomaticStrength) {
        this.myDiplomaticStrength = myDiplomaticStrength;
    }

    public double getRelativeDiplomaticStrength() {
        return relativeDiplomaticStrength;
    }

    public void setRelativeDiplomaticStrength(double relativeDiplomaticStrength) {
        this.relativeDiplomaticStrength = relativeDiplomaticStrength;
    }

    public String getSubject() {
        return this.subject;
    }

    public void setSubject(String s) {
        this.subject = s;
    }

    public String getPredicate() {
        return this.predicate;
    }

    public String getObject() {
        return this.object;
    }

    public void setObject(String s) {
        this.object = s;
    }

    public Long getDuring() {
        return this.during;
    }

    public Polity getMe() {
        return me;
    }

    public Polity getThem() {
        return them;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String s) {
        this.name = s;
    }

    public int getThisYear() {
        return thisYear;
    }

    public void setThisYear(int thisYear) {
        this.thisYear = thisYear;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (super.equals(o)) return false;
        NetworkFact that = (NetworkFact) o;
        if (getId() != null ? !getId().equals(that.getId()) : that.getId() != null) return false;
        if (!getSubject().equals(that.getSubject())) return false;
        if (getThisYear()!=that.getThisYear()) return false;
        return getObject() != null ? getObject().equals(that.getObject()) : that.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getThisYear();
        result = 31 * result + getSubject().hashCode();
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }


}
