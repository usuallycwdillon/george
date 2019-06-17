package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;
import org.neo4j.ogm.annotation.typeconversion.Convert;

public class DiscretePolityFact extends Fact {

    @Id @GeneratedValue
    private Long id;
    @Property
    private boolean presentCondition;
    @Property
    private int participationRegulationRating;
    @Property
    private String subject;
    @Property
    private int executiveConstraintsConceptId;
    @Property
    private String executiveRecruitmentConcept;
    @Property
    private String executiveConstraints;
    @Property
    private String source;
    @Property
    private int politicalCompetitionConceptId;
    @Property
    private String executiveRecruitmentCompetitiveness;
    @Property
    private String compositeAutocracyRating;
    @Property @Convert(DateConverter.class)
    private Long from;
    @Property @Convert(DateConverter.class)
    private Long until;
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
    private String name;
    @Property
    private int democracyRating;
    @Property
    private String participationCompetitiveness;
    @Property
    private String compositePolityRating;
    @Property
    private String participationRegulation;
    @Property
    private String object;
    @Property
    private int polityScore;
    @Relationship (type = "DESCRIBES_POLITY_OF")
    private Polity polity;


    public DiscretePolityFact() {

    }

    @Override
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    @Override
    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
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

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
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

    @Override
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    @Override
    public String getObject() {
        return object;
    }

    public void setObject(String object) {
        this.object = object;
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
}


