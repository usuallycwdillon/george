package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.*;

@NodeEntity(label = "List")
public class CategoryList extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    String name;
    @Property
    String type;
    @Relationship
    Institution institution;

    public CategoryList() {
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        CategoryList that = (CategoryList) o;

        return getId().equals(that.getId());
    }

    @Override
    public int hashCode() {
        return getId().hashCode();
    }
}
