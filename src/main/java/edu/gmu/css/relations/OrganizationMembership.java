package edu.gmu.css.relations;


import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.data.MembershipLevel;
import edu.gmu.css.entities.Organization;
import edu.gmu.css.entities.Polity;
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
