package edu.gmu.css.entities;

import edu.gmu.css.service.FactServiceImpl;
import org.neo4j.ogm.annotation.*;

@NodeEntity
public class DipExFact extends Fact {

    @Id @GeneratedValue
    private Long id;
    @Property
    int code;
    @Property
    String level;
    @Property
    double version;

    @Relationship(type = "REPRESENTED", direction = Relationship.INCOMING)
    private Polity mission; // polity representing itself
    @Relationship(type = "REPRESENTED_AT")
    private Polity polity; // polity where the mission represents their polity
//    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
//    private Dataset dataset;
    @Relationship(type = "REPRESENTATION_WITH")
    private DiplomaticExchange institution;


    public DipExFact() {

    }

    private DipExFact(FactBuilder builder) {
        this.name = builder.name;
        this.from = builder.from;
        this.code = builder.code;
        this.level = builder.level;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.dataset = builder.dataset;
        this.mission = builder.mission;
        this.polity = builder.polity;
        this.institution = builder.institution;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private Polity polity;
        private Polity mission;
        private String name = "Diplomatic Exchange";
        private String subject = mission.getName() != null ? mission.getName() : "unknown";
        private String predicate = "REPRESENTED";
        private String object = polity.getName() != null ? polity.getName() : "unknown";
        private Integer code = 2;
        private String level = "ambassador";
        private Dataset dataset;
        private DiplomaticExchange institution;


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

        public FactBuilder code(Integer c) {
            this.code = c;
            return this;
        }

        public FactBuilder level(String l) {
            this.level = l;
            return this;
        }

        public FactBuilder mission(Polity m) {
            this.mission = m;
            return this;
        }

        public FactBuilder polity(Polity p) {
            this.polity = p;
            return this;
        }

        public FactBuilder dataset(Dataset d) {
            this.dataset = d;
            return this;
        }

        public FactBuilder institution(DiplomaticExchange dx) {
            this.institution = dx;
            return this;
        }

        public DipExFact build() {
            return new DipExFact(this);
        }

    }

    @Override
    public Long getId() {
        return id;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public double getVersion() {
        return version;
    }

    public void setVersion(double version) {
        this.version = version;
    }

    public Polity getMission() {
        return mission;
    }

    public void setMission(Polity mission) {
        this.mission = mission;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Dataset getDataset() {
        return dataset;
    }

    public void setDataset(Dataset source) {
        this.dataset = source;
    }

    public DiplomaticExchange getInstitution() {
        if(this.institution==null) {
            this.institution = (DiplomaticExchange) new FactServiceImpl().getRelatedInstitution(this);
        }
        return institution;
    }

    public void setInstitution(DiplomaticExchange institution) {
        this.institution = institution;
    }

//    public Polity findPolity() {
//        Polity p;
//
//        return p;
//    }



    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DipExFact)) return false;
        if (!super.equals(o)) return false;

        DipExFact fact = (DipExFact) o;

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
