package edu.gmu.css.entities;


import org.neo4j.ogm.annotation.*;

import java.util.ArrayList;
import java.util.List;

@NodeEntity(label = "List")
public class NodeList extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    String name;

    @Relationship
    List<Entity> entities = new ArrayList<>();

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public List<Entity> getEntities() {
        return entities;
    }

    public void addEntity(Entity e) {
        entities.add(e);
    }
}
