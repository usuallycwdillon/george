package edu.gmu.css.entities;

import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.*;

@NodeEntity
public class BorderFact extends Fact {

    @Id
    @GeneratedValue
    private Long id;

    @Relationship(type = "SHARES_BORDER", direction = Relationship.INCOMING)
    private Polity polity;
    @Relationship(type = "BORDERS_WITH")
    private Border border;
//    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
//    private Dataset dataset;


    private BorderFact() {

    }

    private BorderFact(FactBuilder builder) {
        this.from = builder.from;
        this.polity = builder.polity;
        this.border = builder.border;
        this.subject = polity.getName();
        this.predicate = "ENTERED";
        this.object = border.getName();
        this.dataset = builder.dataset;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private String name = "Border Fact";
        private String subject = "none";
        private String predicate = "NONE";
        private String object = "none";
        private Dataset dataset;
        private Polity polity;
        private Border border;

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

        public FactBuilder alliance(Border b) {
            this.border = b;
            return this;
        }

        public BorderFact build() {
            return new BorderFact(this);
        }

    }

    @Override
    public Long getId() {
        return id;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Border getBorder() {
        if(this.border==null){
            this.border =  (Border) new FactServiceImpl().getRelatedInstitution(this);
        }
        return border;
    }

    public void setBorder(Border border) {
        this.border = border;
    }

    public Dataset getDataset() {
        return dataset;
    }

    public void setDataset(Dataset dataset) {
        this.dataset = dataset;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof BorderFact)) return false;
        if (!super.equals(o)) return false;

        BorderFact fact = (BorderFact) o;

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
