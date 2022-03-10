package edu.gmu.css.worldOrder;

import edu.gmu.css.entities.State;
import org.jcolorbrewer.ColorBrewer;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartFrame;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.renderer.category.CategoryItemRenderer;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DatasetUtils;
import sim.display.Console;
import sim.display.Controller;
import sim.display.Display2D;
import sim.display.GUIState;
import sim.engine.SimState;
import sim.engine.Steppable;

import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class WorldOrderWithUI extends GUIState {

    /**
     *
     * @param
     *
     */
    private Display2D display;
    private JFrame displayFram;
    private DefaultCategoryDataset gdpBars;
    private DefaultCategoryDataset treasuryBars;
    private DefaultCategoryDataset milperBars;
    private DefaultCategoryDataset processBars;
    private DefaultCategoryDataset instituBars;
    private DefaultCategoryDataset popBars;
    private DefaultCategoryDataset uPopBars;
    private DefaultCategoryDataset wealthBars;
    private DefaultCategoryDataset satisfactionBars;
    private JFreeChart gdpChart;
    private JFreeChart treasuriesChart;
    private JFreeChart milpersChart;
    private JFreeChart processChart;
    private JFreeChart instituChart;
    private JFreeChart popChart;
    private JFreeChart uPopChart;
    private JFreeChart wealthChart;
    private JFreeChart satisfactionChart;
    private JFrame gdpFrame;
    private JFrame treasuryFrame;
    private JFrame milperFrame;
    private JFrame processFrame;
    private JFrame instituFrame;
    private JFrame popFrame;
    private JFrame uPopFrame;
    private JFrame wealthFrame;
    private JFrame satisfactionFrame;
    private int numStates;
    private Color[] colorGradients;
    private Color[] procGradients;
    private Color[] instGradients;


    public static void main(String[] args) {
        WorldOrderWithUI wowUI = new WorldOrderWithUI();
        Console c = new Console(wowUI);
        c.showAllFrames();
        c.setVisible(true);
    }

    // The simulation singleton
    public WorldOrderWithUI() {
        super(new WorldOrder(System.currentTimeMillis(), 1816));
    }

    public WorldOrderWithUI(SimState state) {
        super(state);
    }

    public static String getName() {
        return "World Order";
    }

    public void setupPortrayals() {
        final WorldOrder worldOrder = (WorldOrder) state;
        colorGradients = worldOrder.getGradients();

        Steppable gdpUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                if (worldOrder.getCountdown()==0) {
                    for (State s : worldOrder.getAllTheStates().values()) {
                        gdpBars.addValue(Math.log10(s.getTerritory().getGdpTrans() + 1.0), "GDP", s.getName());
                    }
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(gdpUpdater);

        Steppable treasuriesUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                for (State s : worldOrder.getAllTheStates().values()) {
                    treasuryBars.addValue(Math.log10(s.getTreasury() + 1.0), "State Treasury", s.getName());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(treasuriesUpdater);

        Steppable milperUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                for (State s : worldOrder.getAllTheStates().values()) {
                    milperBars.addValue(Math.log10(s.getForces() + 1.0),"Military Strength",s.getName());
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(milperUpdater);

        Steppable popUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                if (worldOrder.getCountdown()==0) {
                    for (State s : worldOrder.getAllTheStates().values()) {
                        popBars.addValue(Math.log10(s.getTerritory().getPopulationTrans() + 1.0), "Population", s.getName());
                    }
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(popUpdater);

        Steppable uPopUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                if (worldOrder.getCountdown()==0) {
                    for (State s : worldOrder.getAllTheStates().values()) {
                        uPopBars.addValue(Math.log10(s.getTerritory().getUrbanPopulationTrans() + 1.0), "Urban Population", s.getName() );
                    }
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(uPopUpdater);

        Steppable wealthUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                if (worldOrder.getCountdown()==0) {
                    for (State s : worldOrder.getAllTheStates().values()) {
                        wealthBars.addValue(Math.log10(s.getTerritory().getWealthTrans() + 1.0), "Wealth", s.getName());
                    }
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(wealthUpdater);

        Steppable satisfactionUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                if (worldOrder.getCountdown()==0) {
                    for (State s : worldOrder.getAllTheStates().values()) {
                        satisfactionBars.addValue(s.getTerritory().getSatisfaction(), "Satisfacation", s.getName() );
                    }
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(satisfactionUpdater);

        Steppable procUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                Map<String, Long> procCounts =
                        worldOrder.allTheProcs.stream().collect(Collectors
                                .groupingBy(e -> e.getName(), Collectors.counting()));
                for (Map.Entry<String, Long> e : procCounts.entrySet()) {
                    processBars.addValue(e.getValue().intValue(), "Process Counts by Type", e.getKey() );
                }
            }
        };
        worldOrder.schedule.scheduleRepeating(procUpdater);

        Steppable instUpdater = new Steppable() {
            @Override
            public void step(SimState simState) {
                Map<String, Long> instCounts = worldOrder.allTheInstitutions.stream()
                        .filter(e -> e.getStrength() > 0.25)
                        .collect(Collectors.groupingBy(e -> e.getDomainName(), Collectors.counting()));
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
        ColorBrewer brewer = pallets[2];
        procGradients = brewer.getColorPalette(4);
        instGradients = brewer.getColorPalette(5);
        colorGradients = worldOrder.getGradients();
        numStates = colorGradients.length;

        // GDP
        gdpBars = (DefaultCategoryDataset) createStatesDataset("GDP");
        gdpChart = ChartFactory.createBarChart("GDP Last Year",
                "State",
                "log10( GDP )",
                gdpBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot gdpPlot = gdpChart.getCategoryPlot();
        final NumberAxis rangeAxisG = (NumberAxis) gdpPlot.getRangeAxis();
        rangeAxisG.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisG = gdpPlot.getDomainAxis();
        xAxisG.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer gdpRenderer = new CustomRenderer(colorGradients);
        gdpPlot.setRenderer(gdpRenderer);

        gdpFrame = new ChartFrame("GDP Last Year", gdpChart);
        c.registerFrame(gdpFrame);

        // Population
        popBars = (DefaultCategoryDataset) createStatesDataset("Population");
        popChart = ChartFactory.createBarChart("Population Last Year",
                "State",
                "log10( Population )",
                popBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot popPlot = popChart.getCategoryPlot();
        final NumberAxis rangeAxisP = (NumberAxis) popPlot.getRangeAxis();
        rangeAxisP.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisP = popPlot.getDomainAxis();
        xAxisP.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer popRenderer = new CustomRenderer(colorGradients);
        popPlot.setRenderer(popRenderer);

        popFrame = new ChartFrame("Population Last Year", popChart);
        c.registerFrame(popFrame);

        // Urban Population
        uPopBars = (DefaultCategoryDataset) createStatesDataset("Urban Population");
        uPopChart = ChartFactory.createBarChart("Urban Population Last Year",
                "State",
                "log10( Urban Population )",
                uPopBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot uPopPlot = uPopChart.getCategoryPlot();
        final NumberAxis rangeAxisU = (NumberAxis) uPopPlot.getRangeAxis();
        rangeAxisU.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisU = uPopPlot.getDomainAxis();
        xAxisU.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer uPopRenderer = new CustomRenderer(colorGradients);
        uPopPlot.setRenderer(uPopRenderer);

        uPopFrame = new ChartFrame("Urban Population Last Year", uPopChart);
        c.registerFrame(uPopFrame);

        // Wealth (kapital)
        wealthBars = (DefaultCategoryDataset) createStatesDataset("Wealth");
        wealthChart = ChartFactory.createBarChart("Working Capital Last Year",
                "State",
                "log10( Wealth )",
                wealthBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot wealthPlot = wealthChart.getCategoryPlot();
        final NumberAxis rangeAxisW = (NumberAxis) wealthPlot.getRangeAxis();
        rangeAxisW.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisW = wealthPlot.getDomainAxis();
        xAxisW.setCategoryLabelPositionOffset(15);
        final CategoryItemRenderer wealthRenderer = new CustomRenderer(colorGradients);
        wealthPlot.setRenderer(wealthRenderer);

        wealthFrame = new ChartFrame("Working Capital Last Year", wealthChart);
        c.registerFrame(wealthFrame);

        // Satisfaction
        satisfactionBars = (DefaultCategoryDataset) createStatesDataset("Satisfaction");
        satisfactionChart = ChartFactory.createBarChart("Average Population Satisfaction",
                "State",
                "Satisfaction",
                satisfactionBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot satisfactionPlot = satisfactionChart.getCategoryPlot();
        final NumberAxis rangeAxisS = (NumberAxis) satisfactionPlot.getRangeAxis();
        rangeAxisS.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisS = satisfactionPlot.getDomainAxis();
        xAxisS.setCategoryLabelPositionOffset(10);
        final CategoryItemRenderer satisfactionRenderer = new CustomRenderer(colorGradients);
        satisfactionPlot.setRenderer(satisfactionRenderer);

        satisfactionFrame = new ChartFrame("Average Population Satisfaction", satisfactionChart);
        c.registerFrame(satisfactionFrame);

        // Treasury
        treasuryBars = (DefaultCategoryDataset) createStatesDataset("State Treasury");
        treasuriesChart = ChartFactory.createBarChart(
                "Available State Treasury",
                "State",
                "log10( treasury )",
                treasuryBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot treasuryPlot = treasuriesChart.getCategoryPlot();
        final NumberAxis rangeAxisT = (NumberAxis) treasuryPlot.getRangeAxis();
        rangeAxisT.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisT = treasuryPlot.getDomainAxis();
        xAxisT.setCategoryLabelPositionOffset(10);
        final CategoryItemRenderer treasuryRenderer = new CustomRenderer(colorGradients);
        treasuryPlot.setRenderer(treasuryRenderer);

        treasuryFrame = new ChartFrame("Treasury", treasuriesChart);
        c.registerFrame(treasuryFrame);

        // Military Personnel
        milperBars = (DefaultCategoryDataset) createStatesDataset("Military Strength");
        milpersChart = ChartFactory.createBarChart(
                "Available Military Personnel",
                "State",
                "log10( Military Personnel )",
                milperBars,
                PlotOrientation.HORIZONTAL,
                false,
                true,
                false
        );
        final CategoryPlot milperPlot = milpersChart.getCategoryPlot();
        final NumberAxis rangeAxisM = (NumberAxis) milperPlot.getRangeAxis();
        rangeAxisM.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisM = milperPlot.getDomainAxis();
        xAxisM.setCategoryLabelPositionOffset(10);
        final CategoryItemRenderer milperRenderer = new CustomRenderer(colorGradients);
        milperPlot.setRenderer(milperRenderer);

        milperFrame = new ChartFrame("Military Strength", milpersChart);
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
        final NumberAxis rangeAxisPr = (NumberAxis) processPlot.getRangeAxis();
        rangeAxisPr.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        CategoryAxis xAxisPr = processPlot.getDomainAxis();
        xAxisPr.setCategoryLabelPositionOffset(10);
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
        xAxisI.setCategoryLabelPositionOffset(10);
        final CategoryItemRenderer instituRenderer = new CustomRenderer(instGradients);
        instituPlot.setRenderer(instituRenderer);

        instituFrame = new ChartFrame("Institution Counts", instituChart);
        c.registerFrame(instituFrame);
    }

    private CategoryDataset createStatesDataset(String label) {
        WorldOrder worldOrder = (WorldOrder) state;
        List<State> states = new ArrayList<State>(worldOrder.getAllTheStates().values());
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
        String[] names = new String[]{"Alliance", "Border", "Peace", "War", "Diplomacy"};
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
