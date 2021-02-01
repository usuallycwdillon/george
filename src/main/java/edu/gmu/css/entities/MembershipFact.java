package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import org.neo4j.cypher.internal.frontend.v2_3.ast.functions.Str;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import javax.xml.crypto.Data;

@NodeEntity
public class MembershipFact {

    @Id
    @GeneratedValue
    Long id;
    @Property @Convert(DateConverter.class)
    Long from;
    @Property @Convert(DateConverter.class)
    Long until;
    @Property
    String subject;
    @Property
    String predicate;
    @Property
    String object;
    @Property
    String name;
    @Property
    String source;
    @Property
    String scope;

    @Relationship(type = "MEMBER", direction = Relationship.INCOMING)
    private Polity polity;
    @Relationship(type = "MEMBER_OF")
    private Statehood system;
    @Relationship(type = "CONTRIBUTES", direction = Relationship.INCOMING)
    private Dataset dataset;


    public MembershipFact() {

    }

    public MembershipFact(FactBuilder builder) {
        this.name = builder.name;
        this.from = builder.from;
        this.until = builder.until;
        this.subject = builder.subject;
        this.predicate = builder.predicate;
        this.object = builder.object;
        this.source = builder.source;
        this.scope = builder.scope;
        this.dataset = builder.dataset;
        this.polity = builder.polity;
        this.system = builder.system;
    }

    public static class FactBuilder {
        private final Long from = 0L;
        private final Long until = 0L;
        private final String name = "System Membership";
        private String subject;
        private final String predicate = "MEMBER";
        private String object;
        private final String source = "GEORGE_";
        private final String scope = "Global";
        private Dataset dataset;
        private Polity polity;
        private Statehood system;
    }

    public Long getId() {
        return id;
    }

    public Long getFrom() {
        return from;
    }

    public void setFrom(Long from) {
        this.from = from;
    }

    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getPredicate() {
        return predicate;
    }

    public void setPredicate(String predicate) {
        this.predicate = predicate;
    }

    public String getObject() {
        return object;
    }

    public void setObject(String object) {
        this.object = object;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public Polity getPolity() {
        return polity;
    }

    public void setPolity(Polity polity) {
        this.polity = polity;
    }

    public Statehood getSystem() {
        return system;
    }

    public void setSystem(Statehood system) {
        this.system = system;
    }

    public Dataset getDataset() {
        return dataset;
    }

    public void setDataset(Dataset dataset) {
        this.dataset = dataset;
    }
}
