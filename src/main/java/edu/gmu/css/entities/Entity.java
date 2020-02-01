package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;

import java.io.Serializable;


public abstract class Entity implements Serializable {

    @Id @GeneratedValue
    private Long id;
    private static final long serialVersionUID = 1L;

    public Long getId() {
        return id;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this) return true;
        if (o == null || id == null || this.getClass() != o.getClass()) return false;

        Entity entity = (Entity) o;
        return id.equals(entity.id);
    }


}
