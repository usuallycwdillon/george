package edu.gmu.css.entities;


import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.data.MembershipLevel;
import org.neo4j.ogm.annotation.EndNode;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.RelationshipEntity;
import org.neo4j.ogm.annotation.StartNode;

@RelationshipEntity
public class OrganizationMembership {

    @StartNode
    protected Polity polity;
    @EndNode
    protected Organization organization;
    @Property
    protected long from;
    @Property
    protected long until;
    @Property
    protected MembershipLevel level;
}
