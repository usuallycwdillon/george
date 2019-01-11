package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.Property;
import org.neo4j.ogm.annotation.Relationship;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;


public class Dataset extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    String filename;
    @Property
    String name;
    @Property
    Double version;
    @Convert(DateConverter.class)
    LocalDate published;
    @Convert(DateConverter.class)
    LocalDate validFrom;
    @Convert(DateConverter.class)
    LocalDate validUntil;
    @Property
    long seed;
    @Property
    LocalDateTime dateTime;


    @Relationship(type="CONTRIBUTES")
    private Set<Entity> facts = new HashSet<>();

    public Dataset() {
    }

    public Dataset(String filename, String name, Double version) {
        this.filename = filename;
        this.name = name;
        this.version = version;
        this.facts = new HashSet<>();
    }

    public Dataset(long seed) {
        this.name = "simulation_run";
        this.dateTime = LocalDateTime.now();
        this.filename = name + "_" + dateTime;
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getFilename() {
        return filename;
    }

    public String getName() {
        return name;
    }

    public Double getVersion() {
        return version;
    }

    public Set<Entity> getFacts() {
        return facts;
    }

    public void addFacts(Entity t) {
        this.facts.add(t);
    }

    public void addAllFacts(Collection<Entity> theseEntities) {
        this.facts.addAll(theseEntities);
    }

    public LocalDate getPublished() {
        return published;
    }

    public LocalDate getValidFrom() {
        return validFrom;
    }

    public LocalDate getValidUntil() {
        return validUntil;
    }
}

