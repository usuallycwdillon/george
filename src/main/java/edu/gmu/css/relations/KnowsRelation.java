package edu.gmu.css.relations;

import edu.gmu.css.agents.Person;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="KNOWS")
public class KnowsRelation {

    @Id @GeneratedValue
    long id;
    @StartNode
    Person knower;
    @EndNode
    Person known;
    @Property
    double popRatio;


    public KnowsRelation() {

    }

    public KnowsRelation(Person a, Person b) {
        this.knower = a;
        this.known = b;
    }

    public double getPopRatio() {
        return popRatio;
    }

    public Person getKnower() {
        return knower;
    }

    public Person getKnown() {
        return known;
    }

    public void setPopRatio(double popRatio) {
        this.popRatio = popRatio;
    }

    public Long getKnowerId() {
        return knower.getId();
    }

    public Long getKnownId() {
        return known.getId();
    }

    public boolean doesKnowerHaveLeadershipRole() {
        return knower.isLeadershipRole();
    }

    public boolean doesKnownHaveLeadershipRole() {
        return known.isLeadershipRole();
    }

}
