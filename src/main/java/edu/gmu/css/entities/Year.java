package edu.gmu.css.entities;

import edu.gmu.css.queries.TimelineQueries;
import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.util.LinkedList;
import java.util.List;

@NodeEntity
public class Year extends Entity {

    @Id @GeneratedValue
    private Long id;
    @Index(unique = true)
    private String name;
    private int weeksThisYear;
    @Convert(DateConverter.class)
    private Long last; // Last day of the year a new week can start;
    @Convert(DateConverter.class)
    private Long began;
    @Convert(DateConverter.class)
    private Long ended;
    @Convert(DateConverter.class)
    private Long firstWeekBegins; // Date of the first week of the year
    @Convert(DateConverter.class)
    private Long lastWeekBegins;

    @Relationship (direction = Relationship.INCOMING, type = "PART_OF")
    private LinkedList<Week> weeks;
    @Relationship (direction = Relationship.OUTGOING, type = "NEXT_YEAR")
    private Year nextYear;
    @Relationship (direction = Relationship.INCOMING, type = "NEXT_YEAR")
    private Year lastYear;

    public Year () {}

    public Year (String name) {
        this.name = name;
    }

    public Year (int y) {
        this.name = y + "";
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getWeeksThisYear() {
        return weeksThisYear;
    }

    public Long getLast() {
        return last;
    }

    public Long getBegan() {
        return began;
    }

    public Long getEnded() {
        return ended;
    }

    public Long getFirstWeekBegins() {
        return firstWeekBegins;
    }

    public Long getLastWeekBegins() {
        return lastWeekBegins;
    }

    public List<Week> getWeeks() {
        if(weeks == null) {
            weeks = TimelineQueries.getWeeksInYear(this);
        }
        return weeks;
    }

    public Year getNextYear() {
        if(this.nextYear == null) {
            nextYear = TimelineQueries.getNextYear(this);
        }
        return nextYear;
    }

    public Year getLastYear() {
        if(this.lastYear == null) {
            lastYear = TimelineQueries.getLastYear(this);
        }
        return lastYear;
    }

}
