package edu.gmu.css.entities;

import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class AllianceParticipationFact extends Fact {

    @Id @GeneratedValue
    Long id;
    @Property
    boolean priorTo1816;
    @Property
    boolean beyond2012;

    @Relationship(type="ENTERED", direction = Relationship.INCOMING)
    private Polity polity;
    @Relationship (type="ENTERED_INTO")
    private Alliance alliance;
    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
    private Dataset dataset;
    @Relationship(type = "FROM_WEEK")
    private Week fromWeek;
    @Relationship(type = "UNTIL_WEEK")
    private Week untilWeek;


    public AllianceParticipationFact() {

    }

    private AllianceParticipationFact(FactBuilder builder) {
        this.from = builder.from;
        this.polity = builder.polity;
        this.alliance = builder.alliance;
        this.subject = polity.getName();
        this.predicate = "ENTERED";
        this.object = alliance.getName();
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Alliance Participation";
        private String subject = "none";
        private String predicate = "NONE";
        private String object = "none";
        private Dataset dataset;
        private Polity polity;
        private Alliance alliance;


        public FactBuilder() {}


        public FactBuilder from(Long from) {
            this.from = from;
            return this;
        }

        public FactBuilder until(Long until) {
            this.until = until;
            return this;
        }

        public FactBuilder name(String name) {
            this.name = name;
            return this;
        }

        public FactBuilder subject(String subject) {
            this.subject = subject;
            return this;
        }

        public FactBuilder predicate(String predicate) {
            this.predicate = predicate;
            return this;
        }

        public FactBuilder object(String object) {
            this.object = object;
            return this;
        }

        public FactBuilder source(Dataset d) {
            this.dataset = d;
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            return this;
        }

        public FactBuilder alliance(Alliance a) {
            this.alliance = a;
            return this;
        }

        public AllianceParticipationFact build() {
            return new AllianceParticipationFact(this);
        }
    }


    @Override
    public Long getId() {
        return id;
    }

    public Dataset getDataset() {
        return dataset;
    }

    public void setDataset(Dataset s) {
        this.dataset = s;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Alliance getAlliance() {
        if(this.alliance==null) {
            this.alliance = (Alliance) new FactServiceImpl().getRelatedInstitution(this);
        }
        return alliance;
    }

    public void setAlliance(Alliance alliance) {
        this.alliance = alliance;
    }

    public Alliance findAllianceWithPartner(Polity t) {
        Polity target = t;
        for (Polity p : alliance.findPartners()) {
            if (p.equals(target)) return alliance;
        }
        return null;
    }



    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof AllianceParticipationFact)) return false;
        if (!super.equals(o)) return false;

        AllianceParticipationFact fact = (AllianceParticipationFact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = getId().hashCode();
        result = 31 * result + getName().hashCode();
        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }
}
