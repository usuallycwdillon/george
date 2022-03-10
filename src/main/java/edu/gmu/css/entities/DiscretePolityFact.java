package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

@NodeEntity
public class DiscretePolityFact extends Fact {

    @Id @GeneratedValue
    private Long id;
    @Property
    private boolean presentCondition;
    @Property
    private int participationRegulationRating;
    @Property
    private int executiveConstraintsConceptId;
    @Property
    private String executiveRecruitmentConcept;
    @Property
    private String executiveConstraints;
    @Property
    private int politicalCompetitionConceptId;
    @Property
    private String executiveRecruitmentCompetitiveness;
    @Property
    private String compositeAutocracyRating;
    @Property
    private int executiveRecruitmentCompetitivenessRating;
    @Property
    private int executiveRecruitmentOpennessRating;
    @Property
    private int executiveConstraintsRating;
    @Property
    private int participationCompetitivenessRating;
    @Property
    private String politicalCompetitionConcept;
    @Property
    private String executiveRecruitmentRegulation;
    @Property
    private int executiveRecruitmentRegulationRating;
    @Property
    private String executiveConstraintsConcept;
    @Property
    private int executiveRecruitmentConceptId;
    @Property
    private int autocracyRating;
    @Property
    private String compositeDemocracyRating;
    @Property
    private String executiveRecruitmentOpenness;
    @Property
    private int democracyRating;
    @Property
    private String participationCompetitiveness;
    @Property
    private String compositePolityRating;
    @Property
    private String participationRegulation;
    @Property
    private int polityScore;
    @Relationship (type = "DESCRIBES_POLITY_OF")
    private Polity polity;


    public DiscretePolityFact() {

    }

    public DiscretePolityFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.polity = builder.polity;
        this.name = builder.name;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.source = builder.source;
        this.dataset = builder.dataset;
        this.autocracyRating = builder.autocracyRating;
        this.democracyRating = builder.democracyRating;
        this.polityScore = builder.polityScore;
    }

    public static class FactBuilder {
        private Long from = 0L;
        private Long until = 0L;
        private Polity polity;
        private String name = "Discrete Polity Fact";
        private String subject = "GEORGE";
        private String predicate = "DESCRIBES_POLITY_OF";
        private String object;
        private String source = "GEORGE_";
        private Dataset dataset;
        private int autocracyRating;
        private int democracyRating;
        private int polityScore;

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

        public FactBuilder polity(Polity p) {
            this.polity = p;
            this.object = p.getName();
            return this;
        }

        public FactBuilder autocracyRating(int i) {
            this.autocracyRating = i;
            return this;
        }

        public FactBuilder democracyRating(int i) {
            this.democracyRating = i;
            return this;
        }

        public FactBuilder polityScore(int i) {
            this.polityScore = i;
            return this;
        }

        public DiscretePolityFact build() {
            return new DiscretePolityFact(this);
        }
    }



    @Override
    public Long getId() {
        return id;
    }



    public boolean isPresentCondition() {
        return presentCondition;
    }

    public void setPresentCondition(boolean presentCondition) {
        this.presentCondition = presentCondition;
    }

    public int getParticipationRegulationRating() {
        return participationRegulationRating;
    }

    public void setParticipationRegulationRating(int participationRegulationRating) {
        this.participationRegulationRating = participationRegulationRating;
    }

    public int getExecutiveConstraintsConceptId() {
        return executiveConstraintsConceptId;
    }

    public void setExecutiveConstraintsConceptId(int executiveConstraintsConceptId) {
        this.executiveConstraintsConceptId = executiveConstraintsConceptId;
    }

    public String getExecutiveRecruitmentConcept() {
        return executiveRecruitmentConcept;
    }

    public void setExecutiveRecruitmentConcept(String executiveRecruitmentConcept) {
        this.executiveRecruitmentConcept = executiveRecruitmentConcept;
    }

    public String getExecutiveConstraints() {
        return executiveConstraints;
    }

    public void setExecutiveConstraints(String executiveConstraints) {
        this.executiveConstraints = executiveConstraints;
    }

    public int getPoliticalCompetitionConceptId() {
        return politicalCompetitionConceptId;
    }

    public void setPoliticalCompetitionConceptId(int politicalCompetitionConceptId) {
        this.politicalCompetitionConceptId = politicalCompetitionConceptId;
    }

    public String getExecutiveRecruitmentCompetitiveness() {
        return executiveRecruitmentCompetitiveness;
    }

    public void setExecutiveRecruitmentCompetitiveness(String executiveRecruitmentCompetitiveness) {
        this.executiveRecruitmentCompetitiveness = executiveRecruitmentCompetitiveness;
    }

    public String getCompositeAutocracyRating() {
        return compositeAutocracyRating;
    }

    public void setCompositeAutocracyRating(String compositeAutocracyRating) {
        this.compositeAutocracyRating = compositeAutocracyRating;
    }

    public int getExecutiveRecruitmentCompetitivenessRating() {
        return executiveRecruitmentCompetitivenessRating;
    }

    public void setExecutiveRecruitmentCompetitivenessRating(int executiveRecruitmentCompetitivenessRating) {
        this.executiveRecruitmentCompetitivenessRating = executiveRecruitmentCompetitivenessRating;
    }

    public int getExecutiveRecruitmentOpennessRating() {
        return executiveRecruitmentOpennessRating;
    }

    public void setExecutiveRecruitmentOpennessRating(int executiveRecruitmentOpennessRating) {
        this.executiveRecruitmentOpennessRating = executiveRecruitmentOpennessRating;
    }

    public int getExecutiveConstraintsRating() {
        return executiveConstraintsRating;
    }

    public void setExecutiveConstraintsRating(int executiveConstraintsRating) {
        this.executiveConstraintsRating = executiveConstraintsRating;
    }

    public int getParticipationCompetitivenessRating() {
        return participationCompetitivenessRating;
    }

    public void setParticipationCompetitivenessRating(int participationCompetitivenessRating) {
        this.participationCompetitivenessRating = participationCompetitivenessRating;
    }

    public String getPoliticalCompetitionConcept() {
        return politicalCompetitionConcept;
    }

    public void setPoliticalCompetitionConcept(String politicalCompetitionConcept) {
        this.politicalCompetitionConcept = politicalCompetitionConcept;
    }

    public String getExecutiveRecruitmentRegulation() {
        return executiveRecruitmentRegulation;
    }

    public void setExecutiveRecruitmentRegulation(String executiveRecruitmentRegulation) {
        this.executiveRecruitmentRegulation = executiveRecruitmentRegulation;
    }

    public int getExecutiveRecruitmentRegulationRating() {
        return executiveRecruitmentRegulationRating;
    }

    public void setExecutiveRecruitmentRegulationRating(int executiveRecruitmentRegulationRating) {
        this.executiveRecruitmentRegulationRating = executiveRecruitmentRegulationRating;
    }

    public String getExecutiveConstraintsConcept() {
        return executiveConstraintsConcept;
    }

    public void setExecutiveConstraintsConcept(String executiveConstraintsConcept) {
        this.executiveConstraintsConcept = executiveConstraintsConcept;
    }

    public int getExecutiveRecruitmentConceptId() {
        return executiveRecruitmentConceptId;
    }

    public void setExecutiveRecruitmentConceptId(int executiveRecruitmentConceptId) {
        this.executiveRecruitmentConceptId = executiveRecruitmentConceptId;
    }

    public int getAutocracyRating() {
        return autocracyRating;
    }

    public void setAutocracyRating(int autocracyRating) {
        this.autocracyRating = autocracyRating;
    }

    public String getCompositeDemocracyRating() {
        return compositeDemocracyRating;
    }

    public void setCompositeDemocracyRating(String compositeDemocracyRating) {
        this.compositeDemocracyRating = compositeDemocracyRating;
    }

    public String getExecutiveRecruitmentOpenness() {
        return executiveRecruitmentOpenness;
    }

    public void setExecutiveRecruitmentOpenness(String executiveRecruitmentOpenness) {
        this.executiveRecruitmentOpenness = executiveRecruitmentOpenness;
    }

    public int getDemocracyRating() {
        return democracyRating;
    }

    public void setDemocracyRating(int democracyRating) {
        this.democracyRating = democracyRating;
    }

    public String getParticipationCompetitiveness() {
        return participationCompetitiveness;
    }

    public void setParticipationCompetitiveness(String participationCompetitiveness) {
        this.participationCompetitiveness = participationCompetitiveness;
    }

    public String getCompositePolityRating() {
        return compositePolityRating;
    }

    public void setCompositePolityRating(String compositePolityRating) {
        this.compositePolityRating = compositePolityRating;
    }

    public String getParticipationRegulation() {
        return participationRegulation;
    }

    public void setParticipationRegulation(String participationRegulation) {
        this.participationRegulation = participationRegulation;
    }

    public int getPolityScore() {
        return polityScore;
    }

    public void setPolityScore(int polityScore) {
        this.polityScore = polityScore;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

//    public Year getYear() {
//        if (this.year==null) {
//            this.year = new FactServiceImpl().getRelatedYear(this);
//        }
//        return this.year;
//    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DiscretePolityFact)) return false;
        if (!super.equals(o)) return false;

        DiscretePolityFact fact = (DiscretePolityFact) o;

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
//        result = 31 * result + (getSubject() != null ? getSubject().hashCode() : 0);
        result = 31 * result + (getPredicate() != null ? getPredicate().hashCode() : 0);
        result = 31 * result + (getObject() != null ? getObject().hashCode() : 0);
        return result;
    }

}


