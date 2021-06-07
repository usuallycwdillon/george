package edu.gmu.css.entities;

import edu.gmu.css.service.DateConverter;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;


public class Dataset extends Entity {

    @Id @GeneratedValue
    Long id;
    @Property
    String filename;
    @Property
    String name;
    @Property
    Integer year;
    @Property
    Double version;
//    @Convert(DateConverter.class)
//    Long published = 0L;
//    @Convert(DateConverter.class)
//    Long validFrom = 0L;
//    @Convert(DateConverter.class)
//    Long validUntil = 0L;
    @Property
    long seed;
    @Transient
    Map<String, Double> warParameters = new HashMap<>();

    @Relationship(type="CONTRIBUTES")
    private final Set<Entity> facts = new HashSet<>();

    public Dataset() {
    }

    public Dataset(String filename, String name, Integer year, Double version) {
        this.filename = filename;
        this.name = name;
        this.year = year;
        this.version = version;
    }

    public Dataset(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        this.seed = WorldOrder.getSeed();
        this.name = "simulation_run_" + seed;
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

    public void removeFact(Entity t){
        this.facts.remove(t);
    }

    public void addAllFacts(Collection<Entity> theseEntities) {
        this.facts.addAll(theseEntities);
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setVersion(Double version) {
        this.version = version;
    }

    public void setSeed(long seed) {
        this.seed = seed;
    }

    public long getSeed() {
        return this.seed;
    }

    public Map<String, Double> getWarParameters() {
        return warParameters;
    }

    public void setWarParameters(Map<String, Double> params) {
        this.warParameters = params;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public int getYear() {
        return this.year;
    }

    //    public Long getPublished() {
//        return published;
//    }
//
//    public Long getValidFrom() {
//        return validFrom;
//    }
//
//    public Long getValidUntil() {
//        return validUntil;
//    }
}

