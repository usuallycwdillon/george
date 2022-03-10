package edu.gmu.css.util;

import edu.gmu.css.data.Resources;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;

public class Lanchester {
    private final Resources sideA = new Resources.ResourceBuilder().build();
    private final Resources sideB = new Resources.ResourceBuilder().build();

    public Lanchester(Resources attackers, Resources defenders) {
        this.sideA.increaseBy(attackers);
        this.sideB.increaseBy(defenders);
    }

    public double calculateAttackForceConcentration() {
        double myPax = sideA.getPax();
        double theirPax = sideB.getPax();
        if (myPax == 0.0) return -1;
        if (theirPax == 0.0) return -9;
        Double forceConcentration = 0.0;
        double minForce = Math.min(myPax, theirPax);
        int mag = (int) Math.round(Math.log10(minForce + 1) );
        double unitSize = Math.pow(10,mag);
        double myUnits = myPax / unitSize;
        double theirUnits = theirPax / unitSize;
        forceConcentration = (myUnits * myUnits) / (theirUnits * theirUnits);

        if(
                DEBUG &&
                        (forceConcentration.isNaN() || forceConcentration.isInfinite())) {
            System.out.println("Side A has " + sideA + "\nSide B has " + sideB +
                    "\n\tand the force concentration is " + forceConcentration);
        }
        return forceConcentration;
    }

}
