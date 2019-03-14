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
    @Property
    String type;

    @Relationship(type="IS_ONE", direction="INCOMING")
    List<Entity> entities = new ArrayList<>();

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getType() { return type; }

    public List<Entity> getEntities() {
        return entities;
    }

    public void addEntity(Entity e) {
        entities.add(e);
    }
}
