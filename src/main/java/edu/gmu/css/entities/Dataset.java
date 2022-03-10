package edu.gmu.css.entities;

import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;

import java.time.LocalDate;
import java.util.*;

@NodeEntity
public class Dataset extends Entity {

    @Id @GeneratedValue private Long id;
    @Property private String filename;
    @Property private String recordDate;
    @Property private String name;
    @Property private Integer startYear;
    @Property private Double version;
    @Property private boolean randomOutcomes;
    @Property private boolean useDiplomacy;
    @Property private boolean useAlliances;
    @Property private boolean conquest;
    @Property private boolean schism;
    @Property private boolean entres;
    @Property private long tileHydrationTime = 0L;
    @Property private long polityHydrationTime = 0L;
    @Property private int initialDuration = 0;
    @Property private int stabilityDuration = 0;
    @Property private int finalDuration = 0;
    @Property private double initialWarLikelihood = 0.0;
    @Property private double finalWarLikelihood = 0.0;
    @Property private double institutionalInfluence = 0.0;
    @Property private double institutionalStagnation = 0.0;
    @Property private long seed;
    @Transient private Map<String, Double> warParameters = new HashMap<>();

    @Relationship(type="CONTRIBUTES")
    private final Set<Entity> facts = new HashSet<>();

    public Dataset() {
    }

    public Dataset(String filename, String name, Integer StartYear, Double version) {
        this.filename = filename;
        this.name = name;
        this.startYear = StartYear;
        this.version = version;
    }

    public Dataset(WorldOrder wo) {
        WorldOrder worldOrder = wo;
        this.seed = WorldOrder.getSeed();
        this.name = "simulation_run_" + seed;
        this.recordDate = LocalDate.now().toString();
        this.startYear = worldOrder.getFromYear();
        this.initialDuration = worldOrder.getOverallDuration();
        this.stabilityDuration = worldOrder.getStabilityDuration();
        this.randomOutcomes = WorldOrder.isRANDOM();
        this.useDiplomacy = WorldOrder.isDIPEX();
        this.useAlliances = WorldOrder.isALLIANCES();
        this.conquest = WorldOrder.isCONQUEST();
        this.schism = WorldOrder.isSCHISM();
        this.entres = WorldOrder.isENTRES();
        this.institutionalInfluence = worldOrder.getInstitutionInfluence();
        this.institutionalStagnation = worldOrder.getInstitutionStagnationRate();
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

    public void addFacts(Fact t) {
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

    public void setStartYear(int startYear) {
        this.startYear = startYear;
    }

    public Integer getStartYear() {
        return this.startYear;
    }

    public void setStartYear(Integer startYear) {
        this.startYear = startYear;
    }

    public boolean isRandomOutcomes() {
        return randomOutcomes;
    }

    public void setRandomOutcomes(boolean randomOutcomes) {
        this.randomOutcomes = randomOutcomes;
    }

    public boolean isUseDiplomacy() {
        return useDiplomacy;
    }

    public void setUseDiplomacy(boolean useDiplomacy) {
        this.useDiplomacy = useDiplomacy;
    }

    public boolean isUseAlliances() {
        return useAlliances;
    }

    public void setUseAlliances(boolean useAlliances) {
        this.useAlliances = useAlliances;
    }

    public boolean isConquest() {
        return conquest;
    }

    public void setConquest(boolean conquest) {
        this.conquest = conquest;
    }

    public boolean isSchism() {
        return schism;
    }

    public void setSchism(boolean schism) {
        this.schism = schism;
    }

    public long getTileHydrationTime() {
        return tileHydrationTime;
    }

    public void setTileHydrationTime(long tileHydrationTime) {
        this.tileHydrationTime = tileHydrationTime;
    }

    public long getPolityHydrationTime() {
        return polityHydrationTime;
    }

    public void setPolityHydrationTime(long polityHydrationTime) {
        this.polityHydrationTime = polityHydrationTime;
    }

    public long getInitialDuration() {
        return initialDuration;
    }

    public void setInitialDuration(int initialDuration) {
        this.initialDuration = initialDuration;
    }

    public long getStabilityDuration() {
        return stabilityDuration;
    }

    public void setStabilityDuration(int stabilityDuration) {
        this.stabilityDuration = stabilityDuration;
    }

    public long getFinalDuration() {
        return finalDuration;
    }

    public void setFinalDuration(int finalDuration) {
        this.finalDuration = finalDuration;
    }

    public double getInitialWarLikelihood() {
        return initialWarLikelihood;
    }

    public void setInitialWarLikelihood(double initialWarLikelihood) {
        this.initialWarLikelihood = initialWarLikelihood;
    }

    public double getFinalWarLikelihood() {
        return finalWarLikelihood;
    }

    public void setFinalWarLikelihood(double finalWarLikelihood) {
        this.finalWarLikelihood = finalWarLikelihood;
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


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Dataset dataset = (Dataset) o;

        if (getId() != null ? !getId().equals(dataset.getId()) : dataset.getId() != null) return false;
        if (!getName().equals(dataset.getName())) return false;
        return getStartYear() != null ? getStartYear().equals(dataset.getStartYear()) : dataset.getStartYear() == null;
    }

    @Override
    public int hashCode() {
        int result = getName().hashCode();
        result = 31 * result + (getStartYear() != null ? getStartYear().hashCode() : 0);
        return result;
    }
}

