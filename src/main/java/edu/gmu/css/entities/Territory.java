package edu.gmu.css.entities;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import edu.gmu.css.agents.Tile;
//import edu.gmu.css.relations.Inclusion;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.service.*;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.*;
import java.util.stream.Collectors;

@NodeEntity
public class Territory extends Entity implements Steppable {

    @Id @GeneratedValue (strategy = NameIdStrategy.class)
    String mapKey;
    @Property
    String name;
    @Property
    String cowcode = "NA";
    @Property
    Long creationStep;
    @Property
    String abbr;
    @Property
    Double area = 0.0;
    @Property
    Integer year;
    @Property
    Integer resolution;
    @Property
    Double centrality;
    @Property
    String environment;
    @Property
    Boolean water = false;
    @Transient
    Double population;
    @Transient
    Double urbanPop;
    @Transient
    Double wealth;
    @Transient
    Double gdp;


    @Relationship(type="REPRESENTS_POPULATION", direction = Relationship.INCOMING)
    CommonWeal commonWeal;

    @Relationship(type="OCCUPIED", direction = Relationship.INCOMING)
    OccupiedRelation polity;

    @Relationship(type="INCLUDES")
    Set<Tile> tileLinks;

    @Relationship(type="BORDERS")
    Set<Border> borders;


    public Territory() {
    }

    public Territory(String name, int year) {
        this.year = year;
        this.name = name;
        this.mapKey = name + " " + year;
        this.area = 0.0;
        this.cowcode = "NA";
        this.tileLinks = new HashSet<>();
    }

    @Override
    public void step(SimState simState) {
        this.updateTotals();
    }

    //------------------------------------------------------------------------------------------------------------------

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAbbr() {
        return abbr;
    }

    public void setAbbr(String abbr) {
        this.abbr = abbr;
    }

    public String getCowcode() {
        return cowcode;
    }

    public void setCowcode(String cowcode) {
        this.cowcode = cowcode;
    }

    public Double getArea() {
        return area;
    }

    public void setArea(Double area) {
        this.area = area;
    }

    public int getYear() {
        return year;
    }

    public String getEnvironment() {
        return environment;
    }

    public void setEnvironment(String environment) {
        this.environment = environment;
    }

    public Boolean getWater() {
        return water;
    }

    public void setWater(Boolean water) {
        this.water = water;
    }

    public Double getWealth() {
        return tileLinks.stream().mapToDouble(Tile::getWealth).sum();
    }

    public Double getPopulation() {
        return population;
    }

    public Double getCurrentPopulation() {
        if (tileLinks.size() < 250) {
            double p = 0.0;
            for (Tile i : tileLinks) {
                p += i.getPopulation();
            }
            this.population = p;
        } else {
            this.population = tileLinks.stream().mapToDouble(Tile::getPopulation).sum();
        }
        return this.population;
    }

    public Double getGDP() {
        return gdp;
    }

    public Double getGrossDomesticProductLastYear() {
        this.gdp = tileLinks.stream().mapToDouble(Tile::getGrossTileProductionLastYear).sum();
        return this.gdp;
    }

    public Double getUrbanPopulation() {
        return urbanPop;
    }

    public String getMapKey() {
        return mapKey;
    }

    public Set<Tile> getTileLinks() {
//        if(tileLinks==null || tileLinks.size()==0) {
//            this.tileLinks = new TerritoryServiceImpl().loadIncludedTiles(this.mapKey);
//        }
        return tileLinks;
    }

    public Set<Tile> getPopulatedTileLinks() {
        if (this.tileLinks.size() < 250) {
            Set<Tile> popTiles = new HashSet<>();
            for (Tile t : this.tileLinks) {
                if (t.getPopulation() > 2.0 && t.getWealth() > 0.0) popTiles.add(t);
            }
            return popTiles;
        } else {
            return tileLinks.stream().filter(l -> l.getPopulation() > 2.0 && l.getWealth() > 0.0).collect(Collectors.toSet());
        }
    }

    public Polity getPolity() {
        if (polity == null) {
            return null;
        } else {
            return polity.getOwner();
        }
    }

    public void setPolity(Polity p, Long step) {
        this.polity = new OccupiedRelation(p, this, step);
    }

    public CommonWeal getCommonWeal() {
        if (commonWeal!=null) {
            return commonWeal;
        }
        this.commonWeal = new CommonWealServiceImpl().findTerritoryCommonWeal(this);
        return commonWeal;
    }

    public void setCommonWeal(CommonWeal commonWeal) {
        this.commonWeal = commonWeal;
    }

    public void initiateGraph() {
        this.commonWeal = new CommonWeal(this, true);
    }

    public void setTileLinks(Set<Tile> i) {
        this.tileLinks = i;
    }

    public void addHex(Tile hex, WorldOrder wo) {
        WorldOrder worldOrder = wo;
        this.tileLinks.add(hex);
        if (!worldOrder.getTiles().containsKey(hex.getAddressYear())) {
            worldOrder.tiles.put(hex.getAddressYear(), hex);
        }
    }

    public Set<Border> getBorders() {
        return borders;
    }


//    private void processItem(Map<String, Object> i, Map<Long, Tile> t) {
//        Map<String, Object> map = (Map<String, Object>) i.get("value");
//        ( t.get( map.get("a")) ).loadFacts(map);
//    }

    public void updateTotals() {
        if (this.water) {
            return;
        } else {
            if (tileLinks.size() < 250) {
                double p = 0.0;
                double u = 0.0;
                double w = 0.0;
                double g = 0.0;
                for (Tile i : tileLinks) {
                    p += i.getPopulation();
                    u += i.getUrbanPop();
                    w += i.getWealth();
                    g += i.getWeeklyGrossTileProduction();
                }
                this.population = p;
                this.urbanPop = u;
                this.wealth = w;
                this.gdp = g;
            } else {
                this.population = tileLinks.stream().mapToDouble(Tile::getPopulation).sum();
                this.urbanPop = tileLinks.stream().mapToDouble(Tile::getUrbanPop).sum();
                this.wealth = tileLinks.stream().mapToDouble(Tile::getWealth).sum();
                this.gdp = tileLinks.stream().mapToDouble(Tile::getGrossTileProductionLastYear).sum();
            }
        }
    }


    public double getCurrentSDP() {
        double p = 0.0;
        double g = 0.0;
        double sdp = 0.0;

        if(this.water) {
            return 0.0;
        } else {
            if (tileLinks.size() < 250) {
                for (Tile i : tileLinks) {
                    p += i.getPopulation();
                    g += (i.getWeeklyGrossTileProduction() * 52);
                }
            } else {
                p = tileLinks.stream().mapToDouble(Tile::getPopulation).sum();
                g = tileLinks.stream().mapToDouble(Tile::getWeeklyGrossTileProduction).sum() * 52 ;
            }
            sdp = Math.max((g - (p * 365 * 0.003)), 0.0);
        }
        return sdp;
    }

    public Double assessPopularWarSupport(Entity e) {
        return commonWeal.evaluateWarNeed(e);
    }

    public CommonWeal findCommonWeal() {
        if (commonWeal == null) {
            this.commonWeal = new CommonWealServiceImpl().findTerritoryCommonWeal(this);
            commonWeal = new CommonWealServiceImpl().find(commonWeal.getId());
            commonWeal.loadPersonMap();
            commonWeal.findLeaders();
            return commonWeal;
        } else {
            return commonWeal;
        }
    }

    public void loadCommonWeal() {
        if (commonWeal == null) {
            this.findCommonWeal();
        }
        commonWeal.loadPersonMap();
        commonWeal.findLeaders();
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Territory)) return false;
        if (!super.equals(o)) return false;

        Territory territory = (Territory) o;

        return getMapKey().equals(territory.getMapKey());
    }

    @Override
    public int hashCode() {
        return getMapKey().hashCode();
    }

}
