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
import java.util.Map;
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
    private Color[] procGradients;
    private Color[] instGradients;


    // The simulation singleton self-manifest
    public WorldOrderWithUI() {
        super(new WorldOrder(System.currentTimeMillis()));
    }

    public WorldOrderWithUI(SimState state) {
        super(state);
    }

    public static void main(String[] args) {
        WorldOrderWithUI wowUI = new WorldOrderWithUI();
        Console c = new Console(wowUI);
        c.showAllFrames();
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
//                List<State> states = worldOrder.getAllTheStates();
                for (State s : worldOrder.getAllTheStates()) {
                    treasuryBars.addValue(s.getTreasury() / 1000000.0, "Wealth", s.getName());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(treasuriesUpdater);

        Steppable milperUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
//                List<State> states = worldOrder.getAllTheStates();
                for (State s : worldOrder.getAllTheStates()) {
                    milperBars.addValue(s.getForces(),"Military Strength",s.getName());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(milperUpdater);

        Steppable procUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                Map<String, Long> procCounts =
                        worldOrder.allTheProcs.stream().collect(Collectors
                                .groupingBy(e -> e.getName(), Collectors.counting()));
//                if (procCounts.size() == 0) {
//                    System.out.println("Processes are churning.");
//                }
                for (Map.Entry<String, Long> e : procCounts.entrySet()) {
                    processBars.addValue(e.getValue().intValue(), "Process Counts by Type", e.getKey() );
                }

            }
        };
        worldOrder.schedule.scheduleRepeating(procUpdater);

        Steppable instUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                Map<String, Long> instCounts =
                        worldOrder.allTheInstitutions.stream().collect(Collectors
                                .groupingBy(e -> e.getName(), Collectors.counting()));
//                if (instCounts.size() == 0) {
//                    System.out.println("institutions are forming");
//                }
                for (Map.Entry<String, Long> e : instCounts.entrySet()) {
                    instituBars.addValue(e.getValue(), "Institution Counts by Type", e.getKey());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(instUpdater);
    }

    @Override
    public void init(Controller c) {
        super.init(c);
        final WorldOrder worldOrder = (WorldOrder) state;

        ColorBrewer[] pallets = ColorBrewer.getQualitativeColorPalettes(false);
        ColorBrewer brewer = pallets[0];
        procGradients = brewer.getColorPalette(4);
        instGradients = brewer.getColorPalette(4);
        colorGradients = worldOrder.getGradients();
        numStates = colorGradients.length;

        // Wealth
        treasuryBars = (DefaultCategoryDataset) createStatesDataset("Wealth");
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
        xAxisT.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer treasuryRenderer = new CustomRenderer(colorGradients);
        treasuryPlot.setRenderer(treasuryRenderer);

        treasuryFrame = new ChartFrame("State Wealth", treasuriesChart);
        c.registerFrame(treasuryFrame);

        // Military Personnel
        milperBars = (DefaultCategoryDataset) createStatesDataset("Military Strength");
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
        xAxisM.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer milperRenderer = new CustomRenderer(colorGradients);
        treasuryPlot.setRenderer(milperRenderer);

        milperFrame = new ChartFrame("State Military", milpersChart);
        c.registerFrame(milperFrame);

        // Processess
        processBars = (DefaultCategoryDataset) createProcsDataset("Process Counts by Type");
        processChart = ChartFactory.createBarChart(
                "",
                "Process Type",
                "Count",
                processBars,
                PlotOrientation.VERTICAL,
                false,
                false,
                false
                );
        final CategoryPlot processPlot = processChart.getCategoryPlot();
        final NumberAxis rangeAxisP = (NumberAxis) processPlot.getRangeAxis();
        rangeAxisP.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisP = processPlot.getDomainAxis();
        xAxisP.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer processRenderer = new CustomRenderer(procGradients);
        processPlot.setRenderer(processRenderer);

        processFrame = new ChartFrame("Process Counts", processChart);
        c.registerFrame(processFrame);

        // Institutions
        instituBars = (DefaultCategoryDataset) createInstDataset("Institution Counts by Type");
        instituChart = ChartFactory.createBarChart(
                "",
                "Institution Type",
                "Count",
                instituBars,
                PlotOrientation.VERTICAL,
                false,
                false,
                false
        );
        final CategoryPlot instituPlot = instituChart.getCategoryPlot();
        final NumberAxis rangeAxisI = (NumberAxis) instituPlot.getRangeAxis();
        rangeAxisI.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisI = instituPlot.getDomainAxis();
        xAxisI.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer instituRenderer = new CustomRenderer(instGradients);
        instituPlot.setRenderer(instituRenderer);

        instituFrame = new ChartFrame("Institution Counts", instituChart);
        c.registerFrame(instituFrame);

    }

    private CategoryDataset createStatesDataset(String label) {
        WorldOrder worldOrder = (WorldOrder) state;
        List<State> states = worldOrder.getAllTheStates();
        String[] size = new String[]{label};
        String[] names = states.stream().map(State::getName).toArray(String[]::new);
        final double[][] data = new double[1][numStates];
        return DatasetUtils.createCategoryDataset(size, names, data);
    }

    private CategoryDataset createProcsDataset(String label) {
        String[] size = new String[]{label};
        String[] names = new String[]{"Alliance Process", "Peace Process", "Diplomatic Process", "Conflict Process"};
        final double[][] data = new double[1][4];
        return DatasetUtils.createCategoryDataset(size, names, data);
    }

    private CategoryDataset createInstDataset(String label) {
        String[] size = new String[]{label};
        // TODO: add these institutions: , "Statehood", "Trade"
        String[] names = new String[]{"Alliance", "Border", "Peace", "War", "Diplomatic Exchange"};
        final double[][] data = new double[1][5];
        return DatasetUtils.createCategoryDataset(size, names, data);
    }

    @Override
    public WorldOrder getSimulationInspectedObject() {
        return (WorldOrder) state;
    }

    @Override
    public void start() {
        super.start();
        WorldOrder worldOrder = (WorldOrder) state;
        colorGradients = worldOrder.getGradients();
        numStates = worldOrder.getAllTheStates().size();
        setupPortrayals();
    }

    @Override
    public void load(SimState state) {
        super.load(state);

    }

    @Override
    public void quit() {
        super.quit();
    }

    // subordinate painter
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
