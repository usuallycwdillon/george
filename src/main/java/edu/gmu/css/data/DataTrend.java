package edu.gmu.css.data;


import one.util.streamex.DoubleStreamEx;

import java.util.ArrayList;

public class DataTrend<T> extends ArrayList<T> {

    private int duration; // duration of record in steps/weeks

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

    public double latestDiff() {
        int idx = this.size();
        double value = 0.0;
        if (idx > 2) {
            Double last = (Double) this.get(idx - 1);
            Double prev = (Double) this.get(idx - 2);
            value = last - prev;
        }
        return value;
    }


}
