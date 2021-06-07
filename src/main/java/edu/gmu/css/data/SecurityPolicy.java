package edu.gmu.css.data;

import java.io.Serializable;

public class SecurityPolicy implements Serializable {

    private double military;
    private double foreign;

    public SecurityPolicy(double m, double f) {
        this.military = m;
        this.foreign = f;
    }

    public SecurityPolicy(double[] policy) {
        // Always is a balance of the total policy
        this.military = policy[0] / (policy[0] + policy[1]);
        this.foreign = policy[1] / (policy[0] + policy[1]);
    }

    public double getMilitary() {
        return military;
    }

    public void setMilitary(double military) {
        this.military = military;
    }

    public double getForeign() {
        return foreign;
    }

    public void setForeign(double foreign) {
        this.foreign = foreign;
    }
}
