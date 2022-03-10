package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import edu.gmu.css.service.WeekServiceImpl;
import edu.gmu.css.service.YearServiceImpl;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.time.LocalDate;
import java.util.LinkedList;
import java.util.List;

@NodeEntity
public class Year extends Entity {

    @Id @GeneratedValue private Long id;
    @Index(unique = true) private String name;
    @Convert(DateConverter.class) private Long last; // Last day of the year a new week can start;
    @Convert(DateConverter.class) private Long began;
    @Convert(DateConverter.class) private Long ended;
    @Convert(DateConverter.class) private Long firstWeekBegins; // Date of the first week of the year
    @Convert(DateConverter.class) private Long lastWeekBegins;
    @Property private int intYear;
    @Property private int weeksThisYear;

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

    public int getIntYear() {
        return intYear;
    }

    public List<Week> getWeeks() {
        if(weeks == null) {
            weeks = new WeekServiceImpl().getWeeksInYear(this);
        }
        return weeks;
    }

    public Year getNextYear() {
        if(this.nextYear == null) {
            nextYear = new YearServiceImpl().getNextYear(this);
        }
        return nextYear;
    }

    public Year getLastYear() {
        if(this.lastYear == null) {
            lastYear = new YearServiceImpl().getLastYear(this);
        }
        return lastYear;
    }

    public Week getWeekFromStep(Long s, Long offset) {
        this.weeks = new WeekServiceImpl().getWeekOfYear(this);
        Week k = this.weeks.get(0);
        for (Week w : weeks) {
            if (w.getStepNumber() == s + offset) k = w;
        }
        return k;
    }

    public int getNameAsInteger() {
        return Integer.parseInt(name);
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Year year = (Year) o;

        if (getId() != null ? !getId().equals(year.getId()) : year.getId() != null) return false;
        if (!getName().equals(year.getName())) return false;
        if (!getBegan().equals(year.getBegan())) return false;
        return getEnded() != null ? getEnded().equals(year.getEnded()) : year.getEnded() == null;
    }

    @Override
    public int hashCode() {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + getName().hashCode();
        result = 31 * result + getBegan().hashCode();
        result = 31 * result + (getEnded() != null ? getEnded().hashCode() : 0);
        return result;
    }
}
