package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

public class IgoMembershipFact extends Fact {

    @Id
    @GeneratedValue
    Long id;
    @Property
    String membership;
    @Property
    Integer membershipCode;


    @Relationship(type = "WITHIN_ORGANIZATION")
    Organization igo;
    @Relationship(type = "MEMBERSHIP", direction = Relationship.INCOMING)
    Polity polity;


    public IgoMembershipFact() {

    }

    public IgoMembershipFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.igo = builder.igo;
        this.polity = builder.polity;
        this.subject = builder.subject;
        this.predicate = "FORMED";
        this.object = builder.object;
        this.name = builder.name;
        this.source = builder.source;
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Simulated IGO Membership";
        private String subject = "Not Collected";
        private String predicate = "MEMBERSHIP";
        private String object = "";
        private String source = "GEORGE_";
        private Dataset dataset;
        private Polity polity;
        private Organization igo;

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

        public FactBuilder source(String s) {
            this.source = s;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            return this;
        }

        public FactBuilder igo(Organization o) {
            this.igo = o;
            this.object = igo.getName();
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            this.subject = polity.getName();
            return this;
        }

        public IgoMembershipFact build() {
            return new IgoMembershipFact(this);
        }
    }



    @Override
    public Long getId() {
        return id;
    }

    public String getMembership() {
        return membership;
    }

    public void setMembership(String membership) {
        this.membership = membership;
    }

    public Integer getMembershipCode() {
        return membershipCode;
    }

    public void setMembershipCode(Integer membershipCode) {
        this.membershipCode = membershipCode;
    }

    public Organization getIgo() {
        return igo;
    }

    public void setIgo(Organization igo) {
        this.igo = igo;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof IgoMembershipFact)) return false;
        if (!super.equals(o)) return false;

        IgoMembershipFact fact = (IgoMembershipFact) o;

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
