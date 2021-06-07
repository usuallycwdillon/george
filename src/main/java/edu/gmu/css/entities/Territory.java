package edu.gmu.css.entities;

import edu.gmu.css.agents.CommonWeal;
import edu.gmu.css.agents.Leadership;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.relations.OccupiedRelation;
import edu.gmu.css.service.CommonWealServiceImpl;
import edu.gmu.css.service.NameIdStrategy;
import edu.gmu.css.service.TileServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@NodeEntity
public class Territory extends Entity implements Steppable {

    @Id @GeneratedValue (strategy = NameIdStrategy.class)
    String mapKey;
    @Property String name;
    @Property String cowcode = "NA";
    @Property Long creationStep;
    @Property String abbr;
    @Property Double area = 0.0;
    @Property Integer year;
    @Property Integer avgRadius;
    @Property Integer resolution;
    @Property Double centrality;
    @Property String environment;
    @Property Boolean water = false;
    @Transient Double population;
    @Transient Double urbanPop;
    @Transient Double wealth;
    @Transient Double gdp;
    @Transient Double satisfaction;

    @Relationship(type="REPRESENTS_POPULATION", direction = Relationship.INCOMING)
    CommonWeal commonWeal;
    @Relationship(type="OCCUPIED", direction = Relationship.INCOMING)
    OccupiedRelation polity;
    @Relationship(type="INCLUDES")
    Set<Tile> tileLinks = new HashSet<>();
    @Relationship(type="BORDERS")
    Set<Border> borders = new HashSet<>();


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
//        this.updateTotals();
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
        return tileLinks.stream().mapToDouble(Tile::getWealthTrans).sum();
    }

    public Double getPopulation() {
        return population;
    }

    public Double getCurrentPopulation() {
        if (tileLinks.size() < 250) {
            double p = 0.0;
            for (Tile i : tileLinks) {
                p += i.getPopulationTrans();
            }
            this.population = p;
        } else {
            this.population = tileLinks.stream().mapToDouble(Tile::getPopulationTrans).sum();
        }
        return this.population;
    }

    public Double getGDP() {
        return gdp;
    }

    public Double getGrossDomesticProductLastYear() {
        if (tileLinks.size() < 250) {
            double g = 0.0;
            for (Tile i :tileLinks) {
                g += i.getGrossTileProductionLastYear();
            }
            this.gdp = g;
        } else {
            this.gdp = tileLinks.stream().mapToDouble(Tile::getGrossTileProductionLastYear).sum();
        }
        return this.gdp;
    }

    public Double getUrbanPopulation() {
        return urbanPop;
    }

    public Double getCurrentUrbanPopulation() {
        if (tileLinks.size() < 250) {
            double p = 0.0;
            for (Tile i : tileLinks) {
                p += i.getUrbanPopTrans();
            }
            this.urbanPop = p;
        } else {
            this.urbanPop = tileLinks.stream().mapToDouble(Tile::getUrbanPopTrans).sum();
        }
        return this.urbanPop;
    }

    public String getMapKey() {
        return mapKey;
    }

    public Set<Tile> getTileLinks() {
        if(tileLinks==null || tileLinks.size()==0) {
            this.tileLinks = new TileServiceImpl().loadIncludedTiles(this);
        }
        return tileLinks;
    }

    public void linkTiles(WorldOrder wo) {
        Map<String, Tile> tileMap = wo.getTiles();
        Collection<Tile> tiles = new TileServiceImpl().loadIncludedTiles(this);
        if (tiles.size() < 250) {
            for (Tile t : tiles) {
                Tile o = tileMap.get(t.getAddressYear());
                o.setLinkedTerritory(this);
                tileLinks.add(o);
            }
        } else {
            tiles.stream().forEach(t -> tileLinks.add(tileMap.get(t.getAddressYear())));
            tileLinks.stream().forEach(t -> t.setLinkedTerritory(this));
        }

    }

    public Set<Tile> getPopulatedTileLinks() {
        if (this.tileLinks.size() < 250) {
            Set<Tile> popTiles = new HashSet<>();
            for (Tile t : this.tileLinks) {
                if (t.getPopulationTrans() > 2.0 && t.getWealthTrans() > 0.0) popTiles.add(t);
            }
            return popTiles;
        } else {
            return tileLinks.stream().filter(l -> l.getPopulationTrans() > 2.0 && l.getWealthTrans() > 0.0).collect(Collectors.toSet());
        }
    }

    public Double getSatisfaction() {
        return this.satisfaction;
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
                double s = 0.0;
                for (Tile i : tileLinks) {
                    p += i.getPopulationTrans();
                    u += i.getUrbanPopTrans();
                    w += i.getWealthTrans();
                    g += i.getGrossTileProductionLastYear();
                    s += i.getSatisfaction();
                }
                this.population = p;
                this.urbanPop = u;
                this.wealth = w;
                this.gdp = g;
                this.satisfaction = s / p;
            } else {
                this.population = tileLinks.stream().mapToDouble(Tile::getPopulationTrans).sum();
                this.urbanPop = tileLinks.stream().mapToDouble(Tile::getUrbanPopTrans).sum();
                this.wealth = tileLinks.stream().mapToDouble(Tile::getWealthTrans).sum();
                this.gdp = tileLinks.stream().mapToDouble(Tile::getGrossTileProductionLastYear).sum();
                this.satisfaction = tileLinks.stream().mapToDouble(Tile::getSatisfaction).average().orElse(0.0);
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
                    p += i.getPopulationTrans();
                    g += (i.getWeeklyGTPTrans() * 52);
                }
            } else {
                p = tileLinks.stream().mapToDouble(Tile::getPopulationTrans).sum();
                g = tileLinks.stream().mapToDouble(Tile::getWeeklyGTPTrans).sum() * 52 ;
            }
            sdp = Math.max((g - (p * 365 * 0.003)), 0.0);
        }
        return sdp;
    }

    public Double assessPopularWarSupport(Entity e) {
        return commonWeal.evaluateWarNeed(e);
    }

    public CommonWeal findCommonWeal() {
        if (this.commonWeal == null) {
            this.commonWeal = new CommonWealServiceImpl().loadFromName( "Residents of " + mapKey);
            this.commonWeal.setTerritory(this);
            Leadership l = commonWeal.getLeadership();
            l.setCommonWeal(this.commonWeal);
            l.setPolity(this.getPolity());
            l.setLeaders(commonWeal.findLeaders());
            this.polity.getOwner().setLeadership(l);
            return commonWeal;
        } else {
            return commonWeal;
        }
    }

    public Integer getRadius() {
        if (avgRadius == null || avgRadius == 0) calculateAvgRadius();
        return avgRadius ;
    }

    public void calculateAvgRadius() {
        // https://en.wikipedia.org/wiki/Centered_hexagonal_number
        int t = tileLinks.size();
        this.avgRadius = (int) (Math.round(
                (3 + (12 * (Math.sqrt(tileLinks.size()) - 3))) / 6)) / 2;
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
