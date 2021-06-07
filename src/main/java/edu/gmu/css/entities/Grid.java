package edu.gmu.css.entities;

import com.uber.h3core.AreaUnit;
import com.uber.h3core.H3Core;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

@NodeEntity
public class Grid extends Entity implements Serializable {
    /**
     *
     */
    @Id @GeneratedValue
    private Long id;
    @Property private String address;
    @Property private Long H3Id;
    @Property private Integer face;
    @Property private Integer resolution;
    @Property private Double km2;
    @Property private Double adjustedR2;
    @Property private Double pgAdjR2;
    @Property private Double lpopCoef;
    @Property private Double yearCoef;
    @Property private Double builtCoef;
    @Property private Double intercept;
    @Property private Double dPopCoef;
    @Property private Double dUrbCoef;
    @Property private Double wGTPCoef;
    @Property private Double pgntrcpt;
    @Relationship(type = "ON_R4GRID", direction = Relationship.INCOMING)
    private final List<Tile> tiles = new ArrayList<>();

    public Grid() {
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getAddress() {
        return address;
    }

    public Long getH3Id() {
        return H3Id;
    }

    public Integer getFace() {
        return face;
    }

    public Integer getResolution() {
        return resolution;
    }

    public Double getKm2() {
        if (this.km2==null) {
            try{
                H3Core h3 = H3Core.newInstance();
                this.km2 = h3.cellArea(address,AreaUnit.km2);
                return this.km2;
            } catch(IOException e) {
                e.printStackTrace();
            }
        }
        return km2;
    }

    public Double getAdjustedR2() {
        return adjustedR2;
    }

    public Double getPgAdjR2() {
        return pgAdjR2;
    }

    public Double getLpopCoef() {
        return lpopCoef;
    }

    public Double getYearCoef() {
        return yearCoef;
    }

    public Double getBuiltCoef() {
        return builtCoef;
    }

    public Double getIntercept() {
        return intercept;
    }

    public Double getdPopCoef() {
        return dPopCoef;
    }

    public Double getdUrbCoef() {
        return dUrbCoef;
    }

    public Double getwGTPCoef() {
        return wGTPCoef;
    }

    public Double getPgntrcpt() {
        return pgntrcpt;
    }

    public List<Tile> getTiles() {
        return tiles;
    }

    public void loadGridInfo() {
        try {
            H3Core h3 = H3Core.newInstance();
            this.H3Id = h3.stringToH3(getAddress());
            this.face = h3.h3GetBaseCell(getAddress());
            this.resolution = h3.h3GetResolution(getAddress());
            if (this.km2==null) {
                this.km2 = h3.cellArea(this.getAddress(), AreaUnit.km2);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public String toString() {
        return "Grid{" +
                "id=" + id +
                ", address='" + address + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        Grid grid = (Grid) o;

        if (!getId().equals(grid.getId())) return false;
        return getAddress().equals(grid.getAddress());
    }

    @Override
    public int hashCode() {
        int result = getId().hashCode();
        result = 31 * result + getAddress().hashCode();
        return result;
    }
}
