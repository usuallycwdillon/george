package edu.gmu.css.data;

public class EconomicPolicy {

    private double capital;
    private double labor;
    private double taxRate;


    public EconomicPolicy(double capital, double labor, double tax) {
        this.capital = capital;
        this.labor = labor;
        this.taxRate = tax;
    }

    public EconomicPolicy(double[] policy) {
        this.capital = policy[0];
        this.labor = policy[1];
    }

    public EconomicPolicy(double capital, double labor) {
        this.capital = capital;
        this.labor = labor;
    }

    public double getCapital() {
        return capital;
    }

    public void setCapital(double capital) {
        this.capital = capital;
    }

    public double getLabor() {
        return labor;
    }

    public void setLabor(double labor) {
        this.labor = labor;
    }

    public double getTaxRate() {
        return taxRate;
    }

    public void setTaxRate(double taxRate) {
        this.taxRate = taxRate;
    }


}


