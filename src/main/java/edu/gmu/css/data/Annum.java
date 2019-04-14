package edu.gmu.css.data;

import sim.engine.SimState;
import sim.engine.Steppable;

public class Annum implements Steppable {

    int weeksSoFar = 0;
    int weeksThisYear = 52;
    int year = 0;


    public Annum() {}

    public void step(SimState simState) {
        weeksSoFar += 1;
        if ((year % 5.6 < 1) && (year % 5.6 >= 0)) {
            weeksThisYear = 53;
        } else {
            weeksThisYear = 52;
        }
        if (weeksSoFar == weeksThisYear) {
            year += 1;
            weeksSoFar = 0;
        }
    }

    public int getYear() {
        return year;
    }

    public int getWeeksSoFar() {
        return weeksSoFar;
    }

    public int getWeeksThisYear() {
        return weeksThisYear;
    }

}
