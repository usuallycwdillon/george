//package edu.gmu.css.entities;
//
//import edu.gmu.css.service.DateConverter;
//import edu.gmu.css.entities.Year;
//import org.neo4j.ogm.annotation.*;
//import org.neo4j.ogm.annotation.typeconversion.Convert;
//
//import java.time.LocalDate;
//
//@NodeEntity
//public class Week extends Entity {
//
//    @Id
//    @GeneratedValue
//    private Long id;
//    @Index(unique = true)
//    private String name;
//    @Property
//    Integer weekYear;
//    @Convert(DateConverter.class)
//    private LocalDate began;
//    @Convert(DateConverter.class)
//    private LocalDate ended;
//
//    @Relationship(type = "PART_OF")
//    private Year year;
//
//    public Week() { }
//
//    public Week(String name) {
//        this.name = name;
//    }
//
//    @Override
//    public Long getId() {
//        return id;
//    }
//
//    public String getName() {
//        return name;
//    }
//
//    public LocalDate getBegan() {
//        return began;
//    }
//
//    public LocalDate getEnded() {
//        return ended;
//    }
//
//    public Year getYear() {
//        return year;
//    }
//
//    public Integer getWeekYear() {
//        return weekYear;
//    }
//
//    public void setWeekYear(Integer weakYear) {
//        this.weekYear = weakYear;
//    }
//
//}
