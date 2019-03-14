package edu.gmu.css.data;


import java.util.ArrayList;

public class DataTrend<T> extends ArrayList<T> {

    private int duration;

    public DataTrend(int size) {
        this.duration = size;
    }

    public boolean add(T h) {
        boolean element = super.add(h);
        if (size() > duration) {
            removeRange(0, size() - (duration - 1));
        }
        return element;
    }

    public double average() {
        int yearsYet = this.size();
        double measure = this.stream().mapToDouble(h -> (Double) h).sum();
        return measure / yearsYet;
    }

}
