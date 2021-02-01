package edu.gmu.css.relations;

import edu.gmu.css.entities.DiplomaticExchange;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import org.neo4j.ogm.annotation.*;

@RelationshipEntity(type="REPRESENTATION")
public class DiplomaticRepresentation extends InstitutionParticipation {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    private Polity owner;
    @EndNode
    private DiplomaticExchange institution;
    @Property
    private Integer during;
    @Property
    private String level;

    public DiplomaticRepresentation() {

    }

    public DiplomaticRepresentation(Polity self, DiplomaticExchange exchange, int year) {
        this.owner = self;
        this.institution = exchange;
        this.during = year;

    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Polity getOwner() {
        return owner;
    }

    public void setOwner(Polity owner) {
        this.owner = owner;
    }

    @Override
    public Institution getInstitution() {
        return institution;
    }

    public void setInstitution(DiplomaticExchange institution) {
        this.institution = institution;
    }

    @Override
    public Integer getDuring() {
        return during;
    }

    public void setDuring(int during) {
        this.during = during;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }
}
