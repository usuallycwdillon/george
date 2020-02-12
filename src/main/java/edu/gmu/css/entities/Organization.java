package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.relations.OrganizationMembership;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;

import java.util.List;

@NodeEntity
public class Organization extends Entity {
    /**
     *
     */
    @Property
    protected long from;
    @Property
    protected long until;
    @Relationship
    protected List<OrganizationMembership> membershipList;


    public Organization() {

    }

    public Organization(Institution institution) {

    }



}
