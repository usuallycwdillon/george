package edu.gmu.css.entities;

import edu.gmu.css.data.Resources;
import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Relationship;
import org.neo4j.ogm.annotation.Transient;

import java.util.ArrayList;

public class PeaceFact extends Fact {

    @Id @GeneratedValue
    Long id;
    @Transient
    private Resources commitment = new Resources.ResourceBuilder().build();
    @Transient
    private Resources cost = new Resources.ResourceBuilder().build();

    @Relationship (type="AGREED", direction = Relationship.INCOMING)
    private Polity polity;
    @Relationship (type="AGREED_TO")
    private Peace peace;
    @Relationship (type="RESOLVED")
    private War war;
    @Relationship (type="RESOLVED_WITH")    // Because this could be an alliance, organization, border, jne
    private ArrayList<Institution> institutions;


    public PeaceFact() {

    }

    public PeaceFact(FactBuilder builder) {
        this.from = builder.from;
        this.polity = builder.polity;
        this.peace = builder.peace;
        this.war = builder.war;
        this.subject = polity.getName();
        this.predicate = "AGREED";
        this.object = peace.getName();
        this.name = builder.name;
        this.source = builder.source;
        this.institutions = builder.institutions;
        this.commitment = builder.commitment;
        this.cost = builder.cost;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Peace Fact";
        private String subject = "none";
        private String predicate = "NONE";
        private String object = "none";
        private String source = "GEORGE_e";
        private Resources commitment;
        private Resources cost;
        private Polity polity;
        private Peace peace;
        private War war;
        private final ArrayList<Institution> institutions = new ArrayList<>();


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

        public FactBuilder source(String source) {
            this.source = source;
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            return this;
        }

        public FactBuilder peace(Peace p) {
            this.peace = p;
            return this;
        }

        public FactBuilder cost(Resources c) {
            this.cost = c;
            return this;
        }

        public FactBuilder commitment(Resources c) {
            this.commitment = c;
            return this;
        }

        public FactBuilder war(War w) {
            this.war = w;
            return this;
        }

        public FactBuilder institutions(Institution i) {
            this.institutions.add(i);
            return this;
        }

        public PeaceFact build() {
            return new PeaceFact(this);
        }
    }


    @Override
    public Long getId() {
        return this.id;
    }

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }

    public Resources getCost() {
        return cost;
    }

    public void setCost(Resources cost) {
        this.cost = cost;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Peace getPeace() {
        return peace;
    }

    public void setPeace(Peace peace) {
        this.peace = peace;
    }

    public War getWar() {
        return war;
    }

    public void setWar(War war) {
        this.war = war;
    }

    public ArrayList<Institution> getInstitutions() {
        return institutions;
    }

    public void setInstitutions(ArrayList<Institution> institutions) {
        this.institutions = institutions;
    }

    public void addInstitution(Institution i) {
        this.institutions.add(i);
    }

    public void removeInstitution(Institution i) {
        this.institutions.remove(i);
    }

    public Year getYear() {
        if (this.year==null) {
            this.year = new FactServiceImpl().getRelatedYear(this);
        }
        return this.year;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PeaceFact)) return false;
        if (!super.equals(o)) return false;

        PeaceFact fact = (PeaceFact) o;

        if (!getId().equals(fact.getId())) return false;
        if (!getName().equals(fact.getName())) return false;
        if (getSubject() != null ? !getSubject().equals(fact.getSubject()) : fact.getSubject() != null) return false;
        if (getPredicate() != null ? !getPredicate().equals(fact.getPredicate()) : fact.getPredicate() != null)
            return false;
        return getObject() != null ? getObject().equals(fact.getObject()) : fact.getObject() == null;
    }

    @Override
    public int hashCode() {
        int result = 31 * getName().hashCode();
        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }

}
