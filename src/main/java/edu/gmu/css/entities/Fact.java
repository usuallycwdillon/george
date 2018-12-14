package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Property;

@NodeEntity
public class Fact extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    Object value;

    public Fact() {}

    public Object getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }
}
