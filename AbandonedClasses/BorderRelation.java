package edu.gmu.css.relations;

import edu.gmu.css.entities.Border;
import edu.gmu.css.entities.Territory;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;

@RelationshipEntity(type="BORDERS")
public class BorderRelation implements Serializable {

    @Id @GeneratedValue
    Long id;
    @StartNode
    Territory self;
    @EndNode
    Border border;
    @Property
    int during;

    public BorderRelation() {

    }

    public BorderRelation(Territory start, Border border, int year) {
        this.self = start;
        this.border = border;
        this.during = year;
    }


    public Long getId() {
        return id;
    }

    public Territory getSelf() {
        return self;
    }

    public Territory getNeighbor() {
        return border.getNeighborTerritory(this);
    }

    public int getDuring() {
        return during;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        BorderRelation that = (BorderRelation) o;

        if (getDuring() != that.getDuring()) return false;
        if (!getId().equals(that.getId())) return false;
        if (!getSelf().equals(that.getSelf())) return false;
        return border.equals(that.border);
    }

    @Override
    public int hashCode() {
        int result = getId().hashCode();
        result = 31 * result + getSelf().hashCode();
        result = 31 * result + border.hashCode();
        result = 31 * result + getDuring();
        return result;
    }
}
