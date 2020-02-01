package edu.gmu.css.entities;

import edu.gmu.css.queries.TimelineQueries;
import edu.gmu.css.service.DateConverter;
import edu.gmu.css.entities.Year;
import edu.gmu.css.service.Neo4jSessionFactory;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.time.LocalDate;

@NodeEntity
public class Week extends Entity {

    @Id
    @GeneratedValue
    private Long id;
    @Index(unique = true)
    private String name;
    @Property
    Integer forYear;
    @Convert(DateConverter.class)
    private Long began;
    @Convert(DateConverter.class)
    private Long ended;
    @Property
    private long stepNumber;

    @Relationship(type = "PART_OF")
    private Year year;
    @Relationship(type = "NEXT_WEEK", direction = Relationship.OUTGOING)
    private Week nextWeek;
    @Relationship(type = "NEXT_WEEK", direction = Relationship.INCOMING)
    private Week prevWeek;

    public Week() { }

    public Week(String name) {
        this.name = name;
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Long getBegan() {
        return began;
    }

    public Long getEnded() {
        return ended;
    }

    public Year getYear() {
        if (this.year == null) {
            year = TimelineQueries.getYearFromIntVal(forYear);
        }
        return year;
    }

    public Week getNextWeek() {
        if (this.nextWeek == null) {
            nextWeek = TimelineQueries.getNextWeek(this);
        }
        return nextWeek;
    }

    public Week getPrevWeek() {
        if (this.prevWeek == null) {
            prevWeek = TimelineQueries.getLastWeek(this);
        }
        return prevWeek;
    }

    public Integer getForYear() {
        return forYear;
    }

    public long getStepNumber() {
        return stepNumber;
    }


}
