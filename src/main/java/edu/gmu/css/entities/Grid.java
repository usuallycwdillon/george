package edu.gmu.css.entities;

import com.uber.h3core.AreaUnit;
import com.uber.h3core.H3Core;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.service.GridServiceImpl;
import edu.gmu.css.service.TileServiceImpl;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.math3.linear.SingularMatrixException;
import org.apache.commons.math3.stat.regression.OLSMultipleLinearRegression;
import org.neo4j.ogm.annotation.*;

import java.io.IOException;
import java.io.Serializable;
import java.util.*;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;

@NodeEntity
public class Grid extends Entity implements Serializable {
    /**
     *
     */
    @Id @GeneratedValue
    private Long id;
    @Property private String address;
    @Property private Long h3Id;
    @Property private Integer face;
    @Property private Integer resolution;
    @Property private Double km2;
    @Property private Double adjustedR2;
    @Property private Double popGrowthAdjR2;
    @Property private Double minPopGrowth;
    @Property private Double maxPopGrowth;
    @Property private Double meanPopGrowth;
    @Property private Double sdPopGrowth;
    @Property private Double logPopCoef;
    @Property private Double yearCoef;
    @Property private Double builtAreaCoef;
    @Property private Double intercept;
    @Property private Double popDensityCoef;
    @Property private Double popUrbanPopCoef;
    @Property private Double urbanDensityCoef;
    @Property private Double popGrowthGtpCoef;
    @Property private Double popGrowthIntercept;
    @Property private Double popYearCoef;
    @Property private Double popBuiltAreaCoef;
    @Transient private int matrixStatus;
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
        return h3Id;
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

    public Double getPopGrowthAdjR2() {
        return popGrowthAdjR2;
    }

    public Double getLogPopCoef() {
        return logPopCoef;
    }

    public Double getYearCoef() {
        return yearCoef;
    }

    public Double getBuiltAreaCoef() {
        return builtAreaCoef;
    }

    public Double getIntercept() {
        return intercept;
    }

    public Double getPopDensityCoef() {
        return popDensityCoef;
    }

    public Double getPopUrbanPopCoef() {
        return popUrbanPopCoef;
    }

    public Double getPopGrowthGtpCoef() {
        return popGrowthGtpCoef;
    }

    public Double getPopGrowthIntercept() {
        return popGrowthIntercept;
    }

    public Double getPopYearCoef() {
        return popYearCoef;
    }

    public Double getPopBuiltAreaCoef() {
        return popBuiltAreaCoef;
    }

    public Double getUrbanDensityCoef() {
        return urbanDensityCoef;
    }

    public List<Tile> getTiles() {
        return tiles;
    }

    public Double getMinPopGrowth() {
        return minPopGrowth;
    }

    public Double getMaxPopGrowth() {
        return maxPopGrowth;
    }

    public Double getMeanPopGrowth() {
        return meanPopGrowth;
    }

    public Double getSdPopGrowth() {
        return sdPopGrowth;
    }

    public void loadGridInfo() {
        try {
            H3Core h3 = H3Core.newInstance();
            this.h3Id = h3.stringToH3(getAddress());
            this.face = h3.h3GetBaseCell(getAddress());
            this.resolution = h3.h3GetResolution(getAddress());
            if (this.km2==null) {
                this.km2 = h3.cellArea(this.getAddress(), AreaUnit.km2);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
//        new GridServiceImpl().createOrUpdate(this);
    }

    public Double modelPopGrowth(WorldOrder wo, Tile rq) {
        WorldOrder worldOrder = wo;
        Tile requestingTile = rq;
        List<Tile> linkedTiles = new TileServiceImpl().getGridTiles(this);
        linkedTiles.sort(Comparator.comparing(Tile::getYear));

        int l = linkedTiles.size();
        this.matrixStatus = 0;
        double [] gtps = new double[l];
        double [] pops = new double[l];
        double [] uPop = new double[l];
        double [] prat = new double[l];
        double [] bilt = new double[l];
        double [] yrdf = new double[l];
        double [] year = new double[l];
        String [] adds = new String[l];

        int i = 0;
        int g = 0;
        int p = 0;
        int u = 0;
        int b = 0;

        for (Tile dt : linkedTiles) {
            adds[i] = dt.getAddress();
            double gtp = dt.getWeeklyGTP();
            gtps[i] = Math.log10(gtp + 1.0);
            if (gtp > 0.0) g++;
            double pop = dt.getPopulation() / this.km2;
            pops[i] = pop;
            if (pop > 0.0) p++;
            year[i] = dt.getYear() * 1.0;
            if (i>0) {
                yrdf[i] = (year[i] - year[i - 1]) * 1.0;
                prat[i] = pops[i - 1] > 0.0 ? 1.0 + ( (pops[i] - (pops[i - 1])) / yrdf[i] ) / pops[i - 1] : 1.0;
                if (i==25) {
                    // straight line annualized delta last two years
                    prat[25] = prat[24] + (yrdf[25] * ((prat[24] - prat[23]) / yrdf[24]));
                }
            } else {
                yrdf[0] = 10.0;
                prat[0] = 1.0;
            }
            double urb = dt.getUrbanPop();
            uPop[i] = urb;
            if (urb > 0.0) u++;
            double blt = dt.getBuiltArea();
            bilt[i] = blt;
            if (blt > 0.0) b++;
            i++;
        }
        if (g > 6) {
            this.matrixStatus += 1;
        }
        if (p > 6) {
            this.matrixStatus += 1;
        }
        if (year.length > 6) {
            this.matrixStatus += 1;
        }

        int k = 3;
        if (g <= 0 || p <= 0) {
            return 0.0;
        }

        if (u > 5 && b < 5 ) {
            k = 4;
            this.matrixStatus = 4;
        }
        if (b > 5 && u < 6) {
            k = 4;
            this.matrixStatus = 5;
        }
        if (b > 6 && u > 6) {
            k = 5;
            this.matrixStatus = 6;
        }

        double[] yield = new double[i];
        double[][] matrix = new double[i][k];

        for (int j=0;j<i;j++) {
            yield[j] = prat[j];
            double [] values = new double[k];
            values[0] = gtps[j];
            values[1] = pops[j];
            values[2] = year[j];
            if (this.matrixStatus == 4) {
                values[3] = uPop[j];
            }
            if (this.matrixStatus == 5) {
                values[3] = bilt[j];
            }
            if (this.matrixStatus == 6) {
                values[3] = uPop[j];
                values[4] = bilt[j];
            }
            matrix[j] = values;
        }

        OLSMultipleLinearRegression model = new OLSMultipleLinearRegression();
        try {
            model.newSampleData(yield, matrix);
        } catch (SingularMatrixException e) {
            e.printStackTrace();
        }

        double[] params = model.estimateRegressionParameters();
        this.popGrowthIntercept = params[0];
        if (this.popGrowthIntercept.isInfinite() || this.popGrowthIntercept.isNaN()) this.popGrowthIntercept = 0.0;
        this.popGrowthGtpCoef = params[1];
        if (this.popGrowthGtpCoef.isInfinite() || this.popGrowthGtpCoef.isNaN()) this.popGrowthGtpCoef = 0.0;
        this.popDensityCoef = params[2];
        if (this.popDensityCoef.isInfinite() || this.popDensityCoef.isNaN()) this.popDensityCoef = 0.0;
        this.popYearCoef = params[3];
        if (this.popYearCoef.isInfinite() || this.popYearCoef.isNaN()) this.popYearCoef = 0.0;
        if (this.matrixStatus == 4) {
            this.popUrbanPopCoef = params[4];
            if (this.popUrbanPopCoef.isInfinite() || this.popUrbanPopCoef.isNaN()) this.popUrbanPopCoef = 0.0;
        }
        if (this.matrixStatus == 5) {
            this.popBuiltAreaCoef = params[4];
            if (this.popBuiltAreaCoef.isInfinite() || this.popBuiltAreaCoef.isNaN()) this.popBuiltAreaCoef = 0.0;
        }
        if (this.matrixStatus == 6) {
            this.popUrbanPopCoef = params[4];
            this.popBuiltAreaCoef = params[5];
            if (this.popUrbanPopCoef.isInfinite() || this.popUrbanPopCoef.isNaN()) this.popUrbanPopCoef = 0.0;
            if (this.popBuiltAreaCoef.isInfinite() || this.popBuiltAreaCoef.isNaN()) this.popBuiltAreaCoef = 0.0;
        }
        this.popGrowthAdjR2 = model.calculateAdjustedRSquared();

        double ex = worldOrder.getWeekExp();
        if (DEBUG) System.out.println("The matrix: \n" + printMatrix(matrix));
        if (DEBUG) System.out.println("The simulated growth rate: \n" + printArray(yield));

        Double rate = this.calculatePopGrowthNow(requestingTile, ex);
        requestingTile.setInitialPopRate(rate);
        if ( requestingTile.isSafeToSave() )  {
            new TileServiceImpl().updateThisTile(requestingTile);
        }
        return rate;
    }

    public Double calculatePopGrowthNow(Tile t, double x) {
        Tile tile = t;
        double ex = x;
        Double r = 1.00007421;
        if (this.matrixStatus == 3) {
            Double baseRate = this.popGrowthIntercept + (
                    this.popGrowthGtpCoef * Math.log10(tile.getWeeklyGTP() + 1.0)) + (
                    this.popDensityCoef * tile.getPopulationTrans() / this.km2) + (
                    this.popYearCoef * tile.getYear());
            r = Math.pow(baseRate, ex);
        } else if (this.matrixStatus == 4) {
            Double urbanRate = this.popGrowthIntercept + (
                    this.popGrowthGtpCoef * Math.log10(tile.getWeeklyGTP() + 1.0)) + (
                    this.popDensityCoef * tile.getPopulationTrans() / this.km2) + (
                    this.popYearCoef * tile.getYear()) + (
                    this.popUrbanPopCoef * tile.getUrbanPopTrans());
            r = Math.pow(urbanRate, ex);
        } else if (this.matrixStatus == 5) {
            Double builtRate = this.popGrowthIntercept + (
                    this.popGrowthGtpCoef * Math.log10(tile.getWeeklyGTP() + 1.0)) + (
                    this.popDensityCoef * tile.getPopulationTrans() / this.km2) + (
                    this.popYearCoef * tile.getYear()) + (
                    this.popBuiltAreaCoef * tile.getBuiltAreaTrans());
            r = Math.pow(builtRate, ex);
        } else if (this.matrixStatus == 6) {
            Double biltUrbanRate = this.popGrowthIntercept + (
                    this.popGrowthGtpCoef * Math.log10(tile.getWeeklyGTP() + 1.0)) + (
                    this.popDensityCoef * tile.getPopulationTrans() / this.km2) + (
                    this.popYearCoef * tile.getYear()) + (
                    this.popUrbanPopCoef * tile.getUrbanPopTrans()) + (
                    this.popBuiltAreaCoef * tile.getBuiltAreaTrans());
            r = Math.pow(biltUrbanRate, ex);
        } else {
            r = 1.00007421; // something like global average
        }
        return r;
    }


    public int getMatrixStatus() {
        if (this.matrixStatus==0) {
            int status = -1;
            if (!Objects.isNull(this.popGrowthIntercept) && this.popGrowthIntercept != 0.0) status += 1;
            if (!Objects.isNull(this.popGrowthGtpCoef) && this.popGrowthGtpCoef != 0.0) status += 1;
            if (!Objects.isNull(this.popDensityCoef) && this.popDensityCoef != 0.0) status += 1;
            if (!Objects.isNull(this.popYearCoef) && this.popYearCoef != 0.0) status += 1;
            if (status == 3 && !Objects.isNull(this.popUrbanPopCoef) && this.popUrbanPopCoef != 0.0 &&
                    (Objects.isNull(this.popBuiltAreaCoef) || this.popBuiltAreaCoef == 0.0) ) status = 4;
            if (status == 3 && !Objects.isNull(this.popBuiltAreaCoef) && this.popBuiltAreaCoef != 0.0 &&
                    (Objects.isNull(this.popUrbanPopCoef) || this.popUrbanPopCoef == 0.0)) status = 5;
            if (status == 3 && !Objects.isNull(this.popUrbanPopCoef) && this.popUrbanPopCoef != 0.0 &&
                               !Objects.isNull(this.popBuiltAreaCoef) && this.popBuiltAreaCoef != 0.0) status = 6;
            return this.matrixStatus = status;
        } else {
            return this.matrixStatus;
        }

    }

    public static String printMatrix(double[][] a) {
        String r = " ";
        int l = a.length;
        for (int i=0;i<l;i++) {
            double[] row = a[i];
            r += Arrays.toString(row);
            r+= "; ";
        }
        return r;
    }

    private static String printArray(double[] a) {
        String r = Arrays.toString(a);
        return r;
    }

    private static String printArray(int[] a) {
        String r = Arrays.toString(a);
        return r;
    }


    private int findArrayIndex(String [] s, String c) {
        int x = 0;
        for (int i=0; i<s.length;i++) {
            if (s[i].equals(c)) x = i;
        }
        return x;
    }

    @Override
    public String toString() {
        return "Grid{" +
                "id:" + id +
                ", address:'" + address + '\"' +
                "}";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

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
