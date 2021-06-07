package edu.gmu.css.util;

import edu.gmu.css.data.Resources;

public class Lanchester {
    private final Resources sideA = new Resources.ResourceBuilder().build();
    private final Resources sideB = new Resources.ResourceBuilder().build();

    public Lanchester(Resources mine, Resources theirs) {
        this.sideA.increaseBy(mine);
        this.sideB.increaseBy(theirs);
    }

    public double calculateMyForceConcentration() {
        double myPax = sideA.getPax();
        double theirPax = sideB.getPax();
        if (myPax == 0) return -1;
        if (theirPax == 0) return -9;
        double forceConcentration = 0.0;
        double minForce = Math.min(myPax, theirPax);
        int mag = (int) Math.log10(minForce) + 1;
        double unitSize = Math.exp(mag);
        double myUnits = myPax / unitSize;
        double theirUnits = theirPax / unitSize;
        forceConcentration = (myUnits * myUnits) / (theirUnits * theirUnits);

        return forceConcentration;
    }

}
