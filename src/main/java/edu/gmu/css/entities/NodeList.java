package edu.gmu.css.entities;


import org.neo4j.ogm.annotation.*;

import java.util.ArrayList;
import java.util.List;

@NodeEntity
public class NodeList extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    String name;

    @Relationship
    List<Entity> entities = new ArrayList<>();


}
