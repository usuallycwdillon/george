package edu.gmu.css.worldOrder;

import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.State;
import org.jcolorbrewer.ColorBrewer;
import org.jfree.chart.ChartFrame;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.renderer.category.CategoryItemRenderer;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DatasetUtils;
import scala.Char;
import sim.display.Console;
import sim.display.Controller;
import sim.display.Display2D;
import sim.display.GUIState;
import sim.engine.SimState;
import sim.engine.Steppable;

import javax.swing.*;
import java.awt.*;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public class WorldOrderWithUI extends GUIState {
    /**
     *
     * @param
     *
     */
    private Display2D display;
    private JFrame displayFram;
    private DefaultCategoryDataset treasuryBars;
    private DefaultCategoryDataset milperBars;
    private DefaultCategoryDataset processBars;
    private DefaultCategoryDataset instituBars;
    private JFreeChart treasuriesChart;
    private JFreeChart milpersChart;
    private JFreeChart processChart;
    private JFreeChart instituChart;
    private JFrame treasuryFrame;
    private JFrame milperFrame;
    private JFrame processFrame;
    private JFrame instituFrame;
    private int numStates;
    private Color[] colorGradients;


    // The simulation singleton self-manifest
    public WorldOrderWithUI() {
        super(new WorldOrder(System.currentTimeMillis()));

    }

    public WorldOrderWithUI(SimState state) {
        super(state);
    }



    public static void main(String[] args) {
        WorldOrderWithUI vid = new WorldOrderWithUI();
        Console c = new Console(vid);
        c.setVisible(true);
    }

    public static String getName() {
        return "World Order";
    }


    public void setupPortrayals() {
        final WorldOrder worldOrder = (WorldOrder) state;
        colorGradients = worldOrder.getGradients();

        Steppable treasuriesUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                List<State> states = worldOrder.getAllTheStates();
                for (State s : states) {
                    treasuryBars.addValue(s.getTreasury(), "Wealth", s.getName());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(treasuriesUpdater);

        Steppable milperUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                List<State> states = worldOrder.getAllTheStates();
                for (State s : states) {
                    milperBars.addValue(s.getForces(),"Military Strength",s.getName());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(milperUpdater);
    }

    @Override
    public void init(Controller c) {
        super.init(c);

        // State Wealth (really Military Expenditures)
        final WorldOrder worldOrder = (WorldOrder) state;
        colorGradients = worldOrder.getGradients();
        numStates = colorGradients.length;
//        boolean colorBlindSave = false;
//        ColorBrewer[] pallets = ColorBrewer.getQualitativeColorPalettes(colorBlindSave);
//        ColorBrewer brewer = pallets[0];
//        colorGradients = brewer.getColorPalette(numStates);

        treasuryBars = (DefaultCategoryDataset) createDataset("Wealth");
        treasuriesChart = ChartFactory.createBarChart(
                "",
                "State",
                "Wealth",
                treasuryBars,
                PlotOrientation.VERTICAL,
                false,
                false,
                false
        );
        final CategoryPlot treasuryPlot = treasuriesChart.getCategoryPlot();
        final NumberAxis rangeAxisT = (NumberAxis) treasuryPlot.getRangeAxis();
        rangeAxisT.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisT = treasuryPlot.getDomainAxis();
        xAxisT.setCategoryLabelPositionOffset(45);
        final CategoryItemRenderer treasuryRenderer = new CustomRenderer(colorGradients);
        treasuryPlot.setRenderer(treasuryRenderer);

        treasuryFrame = new ChartFrame("State Wealth", treasuriesChart);
        c.registerFrame(treasuryFrame);

        // Military Personnel
        milperBars = (DefaultCategoryDataset) createDataset("Military Strength");
        milpersChart = ChartFactory.createBarChart(
                "",
                "State",
                "Military Strength",
                milperBars,
                PlotOrientation.VERTICAL,
                false,
                false,
                false
        );
        final CategoryPlot milperPlot = milpersChart.getCategoryPlot();
        final NumberAxis rangeAxisM = (NumberAxis) milperPlot.getRangeAxis();
        rangeAxisM.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisM = milperPlot.getDomainAxis();
        xAxisM.setCategoryLabelPositionOffset(45);
        final CategoryItemRenderer milperRenderer = new CustomRenderer(colorGradients);
        treasuryPlot.setRenderer(milperRenderer);

        milperFrame = new ChartFrame("State Military", milpersChart);
        c.registerFrame(milperFrame);

        // Processess
        processBars = (DefaultCategoryDataset) createDataset("Process in Development");
//        processChart = ChartFactory.createBarChart(
//                "",
//                );


        // Institutions


    }

    private CategoryDataset createDataset(String label) {
        WorldOrder worldOrder = (WorldOrder) state;
        List<State> states = worldOrder.getAllTheStates();

        String[] size = new String[]{label};
        String[] names = states.stream().map(State::getName).toArray(String[]::new);

        final double[][] data = new double[1][numStates];
        return DatasetUtils.createCategoryDataset(
                size,
                names,
                data
        );
    }



    @Override
    public WorldOrder getSimulationInspectedObject() {
        return (WorldOrder) state;
    }


    @Override
    public void start() {
        super.start();
        WorldOrder worldOrder = (WorldOrder) state;
        numStates = worldOrder.getAllTheStates().size();

        setupPortrayals();
    }

    @Override
    public void quit() {
        super.quit();
    }

    class CustomRenderer extends BarRenderer {

        private Paint[] colors;

        public CustomRenderer(final Paint[] colors) {
            this.colors = colors;
        }

        @Override
        public Paint getItemPaint(final int row, final int column) {
            return this.colors[column % this.colors.length];
        }

    }

}
