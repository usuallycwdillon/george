package edu.gmu.css.relations;

import edu.gmu.css.agents.DiplomacyProcess;
import edu.gmu.css.entities.DiplomaticExchange;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import org.neo4j.ogm.annotation.*;
import scala.Int;

@RelationshipEntity(type="REPRESENTATION")
public class DiplomaticRepresentation extends InstitutionParticipation {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    private Polity participant;
    @EndNode
    private Institution institution;
    @Property
    private Integer during;
    @Property
    private String level;

    public DiplomaticRepresentation() {

    }

    public DiplomaticRepresentation(Polity self, DiplomaticExchange exchange, int year) {
        this.participant = self;
        this.institution = exchange;
        this.during = year;

    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Polity getParticipant() {
        return participant;
    }

    public void setParticipant(Polity participant) {
        this.participant = participant;
    }

    @Override
    public Institution getInstitution() {
        return institution;
    }

    public void setInstitution(Institution institution) {
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
