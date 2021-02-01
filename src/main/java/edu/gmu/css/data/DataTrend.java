package edu.gmu.css.data;


import one.util.streamex.DoubleStreamEx;

import java.util.ArrayList;
import java.util.List;

public class DataTrend<T> extends ArrayList<T> {

    private final int duration; // duration of record in steps/weeks

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
        int count = this.size();
        double measure = this.stream().mapToDouble(h -> (Double) h).sum();
        return measure / count;
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

    public double pastYearAverage() {
        int from;
        int until;
        if(this.size()==0) {
            return 0.0;
        } else if (this.size() < 53) {
            from = 0;
            until = this.size() -1;
        } else {
            from = this.size() - 53;
            until = this.size() - 1;
        }
        List<T> sublist = this.subList(from, until);
        double total = sublist.stream().mapToDouble(v -> (Double) v).sum();
        return total / 52.0;
    }

    public double pastYearDiff() {
        int from;
        int until;
        if (this.size() > 53) {
            from = this.size() - 53;
            until = this.size() - 1;
        } else {
            from = 0;
            until = this.size() -1;
        }
        Double first = (Double) this.get(from);
        Double last = (Double) this.get(until);
        return last - first;
    }

    public double averageSince(int d) {
        int from = this.size() - d;
        int until = this.size() - 1;
        if (this.size() < d) {
            from = 0;
        }
        List<T> sublist = this.subList(from, until);
        int span = until - from;
        double total = sublist.stream().mapToDouble(v -> (Double) v).sum();
        return total / span;
    }

    public double pastYearTotal() {
        int s = this.size();
        if (this.size() > 53) {
            List<T> sublist = this.subList(s - 53, s - 1);
            return sublist.stream().mapToDouble(v -> (Double) v).sum();
        } else {
            return this.stream().mapToDouble(v -> (Double) v).sum();
        }
    }

    public int countBelowThreshold(double t, boolean i) {
        int count = 0;
        if (i) {
            count = (int) (this.stream().filter(v -> (Double) v <= t).count()) ;
        } else {
            count = (int) (this.stream().filter(v -> (Double) v < t).count()) ;
        }
        return count;
    }

    public double yearAgoValue() {
        int from;
        if (this.size() > 53) {
            from = this.size() - 53;
        } else {
            from = 0;
        }
        return (Double) this.get(from);
    }

    public Double mostRecent() {
        return (Double) this.get(this.size() - 1);
    }

}
