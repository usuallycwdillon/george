package edu.gmu.css.entities;

import edu.gmu.css.agents.Issue;
import org.neo4j.ogm.annotation.*;

import java.util.Objects;

@NodeEntity
public class ClaimFact extends Fact {

    @Id
    @GeneratedValue private Long id;
    @Property Integer MIDSfromIssue;
    @Property Integer fatalMIDSfromIssue;
    @Property String resolution;
    @Property Integer claimdyad;
    @Property Integer intagibleSalience;
    @Property Integer salience;
    @Property String salienceCategory;
    @Property Integer warsFromIssue;
    @Property Integer tangibleSalience;
    @Property Integer weeksDuration;
    @Property boolean violentResolution;
    @Property Integer allianceResolutionAttempts = 0;
    @Property Integer dipExResolutionAttempts = 0;
    @Property Integer conflictResolutionAttempts = 0;
    @Property String rootIssue;
    @Transient private Issue issue;

    @Relationship (type = "CLAIM", direction = Relationship.INCOMING)
    private Polity claimant;
    @Relationship (type = "CLAIM_AGAINST")
    private Polity target;
    @Relationship (type = "FROM_WEEK")
    Week fromWeek;
    @Relationship (type = "UNTIL_WEEK")
    Week untilWeek;


    public ClaimFact() {

    }

    protected ClaimFact(FactBuilder builder) {
        this.from = builder.from;
        this.until = builder.until;
        this.claimant = builder.claimant;
        this.target = builder.target;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.source = builder.source;
        this.dataset = builder.dataset;
        this.issue = builder.issue;
        this.rootIssue = builder.rootIssue;
        this.name = this.subject + "'s " + rootIssue + object;
    }

    public static class FactBuilder {
        private Polity claimant;
        private Polity target;
        private Long from;
        private Long until;
        private String name;
        private String subject;
        private String predicate = "CLAIM";
        private String object;
        private String source = "GEORGE_";
        private Dataset dataset;
        private Issue issue;
        private String rootIssue;


        public FactBuilder claimant(Polity p) {
            this.claimant = p;
            this.subject = claimant.getName();
            return this;
        }

        public FactBuilder target(Polity p) {
            this.target = p;
            if (Objects.nonNull(p)) this.object = Objects.nonNull(p.getName()) ? p.getName() : "missing state name";
            return this;
        }

        public FactBuilder issue(Issue i) {
            this.issue = i;
            this.rootIssue = i.getClaimType();
            return this;
        }

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
            this.source = "GEORGE_" + dataset.getName();
            return this;
        }

        public ClaimFact build() {
            return new ClaimFact(this);
        }

    }


    @Override
    public Long getId() {
        return id;
    }

    public Integer getMIDSfromIssue() {
        return MIDSfromIssue;
    }

    public void setMIDSfromIssue(Integer MIDSfromIssue) {
        this.MIDSfromIssue = MIDSfromIssue;
    }

    public Integer getFatalMIDSfromIssue() {
        return fatalMIDSfromIssue;
    }

    public void setFatalMIDSfromIssue(Integer fatalMIDSfromIssue) {
        this.fatalMIDSfromIssue = fatalMIDSfromIssue;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public Integer getClaimdyad() {
        return claimdyad;
    }

    public void setClaimdyad(Integer claimdyad) {
        this.claimdyad = claimdyad;
    }

    public Integer getIntagibleSalience() {
        return intagibleSalience;
    }

    public void setIntagibleSalience(Integer intagibleSalience) {
        this.intagibleSalience = intagibleSalience;
    }

    public Integer getSalience() {
        return salience;
    }

    public void setSalience(Integer salience) {
        this.salience = salience;
    }

    public String getSalienceCategory() {
        return salienceCategory;
    }

    public void setSalienceCategory(String salienceCategory) {
        this.salienceCategory = salienceCategory;
    }

    public Integer getWarsFromIssue() {
        return warsFromIssue;
    }

    public void setWarsFromIssue(Integer warsFromIssue) {
        this.warsFromIssue = warsFromIssue;
    }

    public Integer getTangibleSalience() {
        return tangibleSalience;
    }

    public void setTangibleSalience(Integer tangibleSalience) {
        this.tangibleSalience = tangibleSalience;
    }

    public boolean isViolentResolution() {
        return violentResolution;
    }

    public void setViolentResolution(boolean violentResolution) {
        this.violentResolution = violentResolution;
    }

    public Polity getClaimant() {
        return claimant;
    }

    public void setClaimant(Polity claimant) {
        this.claimant = claimant;
    }

    public Polity getTarget() {
        return target;
    }

    public void setTarget(Polity target) {
        this.target = target;
    }

    public Issue getIssue() {
        return issue;
    }

    public void setIssue(Issue issue) {
        this.issue = issue;
    }

    public Week getFromWeek() {
        return fromWeek;
    }

    public void setFromWeek(Week fromWeek) {
        this.fromWeek = fromWeek;
    }

    public Week getUntilWeek() {
        return untilWeek;
    }

    public void setUntilWeek(Week untilWeek) {
        this.untilWeek = untilWeek;
    }

    public void incrementAllianceResolutionAttempt(){
        this.allianceResolutionAttempts++;
    }

    public void incrementDipExResolutionAttempt() {
        this.dipExResolutionAttempts++;
    }

    public void incrementConflictResolutionAttempt() {
        this.conflictResolutionAttempts++;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        ClaimFact claimFact = (ClaimFact) o;

        if (getId() != null ? !getId().equals(claimFact.getId()) : claimFact.getId() != null) return false;
        return getIssue().equals(claimFact.getIssue());
    }

    @Override
    public int hashCode() {
        int result = super.hashCode();
        result = 31 * result + (getId() != null ? getId().hashCode() : 0);
        result = 31 * result + getIssue().hashCode();
        return result;
    }
}
