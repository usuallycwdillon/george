package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;


public abstract class Entity {

    @Id @GeneratedValue
    private Long id;

    public Long getId() {
        return id;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this) return true;
        if (o == null || id == null || this.getClass() != o.getClass()) return false;

        Entity entity = (Entity) o;
        if (!id.equals(entity.id)) return false;

        return true;
    }
}
