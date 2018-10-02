package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.time.LocalDate;
import java.util.List;

@NodeEntity
public class Year extends Entity {

    @Id @GeneratedValue
    private Long id;
    @Index(unique = true)
    private String name;
    private int weeksThisYear;
    @Convert(DateConverter.class)
    private LocalDate last; // Last day of the year a new week can start;
    @Convert(DateConverter.class)
    private LocalDate began;
    @Convert(DateConverter.class)
    private LocalDate ended;
    @Convert(DateConverter.class)
    private LocalDate firstWeekBegins; // Date of the first week of the year
    @Convert(DateConverter.class)
    private LocalDate lastWeekEnds;

    @Relationship (direction = "INCOMING", type = "PART_OF")
    private List<Week> weeks;

    public Year () {}

    public Year (String name) {
        this.name = name;
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

    public LocalDate getLast() {
        return last;
    }

    public LocalDate getBegan() {
        return began;
    }

    public LocalDate getEnded() {
        return ended;
    }

    public LocalDate getFirstWeekBegins() {
        return firstWeekBegins;
    }

    public LocalDate getLastWeekEnds() {
        return lastWeekEnds;
    }

    public List<Week> getWeeks() {
        return weeks;
    }
}
