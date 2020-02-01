package edu.gmu.css.entities;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.util.Date;

@NodeEntity
public class Fact extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    Object value;
    @Property @Convert(DateConverter.class)
    Long from;
    @Property @Convert(DateConverter.class)
    Long until;
    @Property
    Integer during;
    @Property
    String name;
    @Property
    String subject;
    @Property
    String predicate;
    @Property
    String object;


    public Fact() {}

    private Fact(FactBuilder builder) {

    }

    public static class FactBuilder {
        private Object value = 0;
        private Long from = 0L;
        private Long until = 0L;
        private Integer during = 0;
        private String name = "unnamed";
        private String subject = "none";
        private String predicate = "NONE";
        private String object = "none";

        public FactBuilder() {}

        public FactBuilder value(Object value) {
            this.value = value;
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

        public FactBuilder during(Integer during) {
            this.during = during;
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

        public Fact build() {
            Fact fact = new Fact(this);
            return fact;
        }
    }


    @Override
    public Long getId() {
        return id;
    }

    public Long getFrom() {
        return from;
    }

    public Long getUntil() {
        return until;
    }

    public Integer getDuring() {
        return during;
    }

    public void setDuring(int d) {
        this.during = d;
    }

    public String getName() {
        return name;
    }

    public Object getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public void setValue(Integer value) {
        this.value = value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public void setValue(Long value) {
        this.value = value;
    }

    public String getSubject() {
        return subject;
    }

    public String getPredicate() {
        return predicate;
    }

    public String getObject() {
        return object;
    }

}
