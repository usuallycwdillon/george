package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import edu.gmu.css.service.WeekServiceImpl;
import edu.gmu.css.service.YearServiceImpl;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

@NodeEntity
public class Week extends Entity {

    @Id
    @GeneratedValue
    private Long id;
    @Index(unique = true) @Property private String name;
    @Property Integer forYear;
    @Property @Convert(DateConverter.class) private Long began;
    @Property @Convert(DateConverter.class) private Long ended;
    @Property private Long stepNumber;

    @Relationship(type = "PART_OF")
    private Year year;
    @Relationship(type = "NEXT_WEEK", direction = Relationship.OUTGOING)
    private Week nextWeek;
    @Relationship(type = "NEXT_WEEK", direction = Relationship.INCOMING)
    private Week prevWeek;
    @Relationship (type = "FROM_WEEK", direction = Relationship.INCOMING)
    private Fact fromWeek;
    @Relationship (type = "UNTIL_WEEK", direction = Relationship.INCOMING)
    private Fact untilWeek;

    public Week() { }

    public Week(String name) {
        this.name = name;
    }

    public Week(Long stepNumber) {
        this.stepNumber = stepNumber;
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
            year = new YearServiceImpl().getYearFromIntVal(forYear);
        }
        return year;
    }

    public Week getNextWeek() {
        if (this.nextWeek == null) {
            nextWeek = new WeekServiceImpl().getNextWeek(this);
        }
        return nextWeek;
    }

    public Week getPrevWeek() {
        if (this.prevWeek == null) {
            prevWeek = new WeekServiceImpl().getLastWeek(this);
        }
        return prevWeek;
    }

    public void setYear(Year y) {
        this.year = y;
    }

    public Integer getForYear() {
        return forYear;
    }

    public Long getStepNumber() {
        return stepNumber;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Week week = (Week) o;

        if (getId() != null ? !getId().equals(week.getId()) : week.getId() != null) return false;
        if (getForYear() != null ? !getForYear().equals(week.getForYear()) : week.getForYear() != null) return false;
        if (getBegan() != null ? !getBegan().equals(week.getBegan()) : week.getBegan() != null) return false;
        return getStepNumber().equals(week.getStepNumber());
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + (getForYear() != null ? getForYear().hashCode() : 0);
        result = 31 * result + (getBegan() != null ? getBegan().hashCode() : 0);
        result = 31 * result + getStepNumber().hashCode();
        return result;
    }
}
