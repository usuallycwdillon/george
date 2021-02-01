package edu.gmu.css.data;

import java.io.Serializable;

public class Resources implements Serializable {
    /**
     * Resources are some combination of the resource types (and values) a State government has at its disposal.
     */
    private double pax;         // e.g. military personnel
    private int products;       // gov't controlled items
    private int natResources;   // gov't controlled resources
    private double treasury;    // gov't controlled cash
    private boolean sufficient;



    public static class ResourceBuilder {
        private double pax = 0.0;
        private int products = 0;
        private int natResources = 0;
        private double treasury = 0.0;
        private boolean sufficient = true;

        public ResourceBuilder() { }

        public ResourceBuilder pax(double pax) {
            this.pax = pax;
            return this;
        }

        public ResourceBuilder products(int products) {
            this.products = products;
            return this;
        }

        public ResourceBuilder natResources(int natResources) {
            this.natResources = natResources;
            return this;
        }

        public ResourceBuilder treasury(double treasury) {
            this.treasury = treasury;
            return this;
        }

        public ResourceBuilder sufficient(boolean s) {
            this.sufficient = s;
            return this;
        }

        public Resources build() {
            return new Resources(this);
        }
    }

    private Resources(ResourceBuilder builder) {
        this.pax = builder.pax;
        this.products = builder.products;
        this.natResources = builder.natResources;
        this.treasury = builder.treasury;
    }

    private Resources() { }

    // Methods to evaluate and manipulate Resources

    public void increaseBy(Resources other) {
        if (other != null) {
            this.pax += other.pax;
            this.products += other.products;
            this.natResources += other.natResources;
            this.treasury += other.treasury;
        }
    }

    public void reduceBy(Resources other) {
        if (other != null) {
            this.pax -= other.pax;
            this.products -= other.products;
            this.natResources -= other.natResources;
            this.treasury -= other.treasury;
        }
    }

    public Resources multipliedBy(double val) {
        return new ResourceBuilder()
                .pax(this.pax * val)
                .products((int)(this.products * val))
                .natResources((int)(this.natResources * val))
                .treasury(this.treasury * val)
                .build();
    }

    public Resources applyRatios(double[] r) {
        return new ResourceBuilder()
                .pax(this.pax * r[0])
                .products((int)(this.products * r[1]))
                .natResources((int)(this.natResources * r[2]))
                .treasury(this.treasury * r[3])
                .build();
    }

    public Resources evaluativeSum(Resources other) {
        return new ResourceBuilder()
                .pax(this.pax + other.getPax())
                .products(this.products + other.getProduct())
                .natResources(this.natResources + other.getNatResources())
                .treasury(this.treasury + other.getTreasury())
                .build();
    }

    public Resources evaluativeAvailableDifference(Resources other) {
        if (other != null) {
            return new ResourceBuilder()
                    .pax(Math.max(this.pax - other.getPax(), 0.0))
                    .products(Math.max((this.products - other.getProduct()), 0))
                    .natResources(Math.max((this.natResources - other.getNatResources()), 0))
                    .treasury(Math.max((this.treasury - other.getTreasury()), 0.0))
                    .build();
        } else {
            return new Resources.ResourceBuilder().build();
        }
    }

    public boolean isSufficientFor(Resources other) {
        if (other != null) {
            if(this.pax >= other.getPax()
                    && this.treasury >= other.getTreasury()
                    && this.natResources >= other.getNatResources()
                    && this.products >= other.getProduct() ) {
                this.sufficient = true;
                return this.sufficient;
            } else {
                this.sufficient = false;
                return this.sufficient;
            }
        } else {
            return true;
        }
    }

    public double [] calculateRatios(Resources total) {
        double[] ratios = new double[4];
        double x;   // 0
        double p;   // 1
        double n;   // 2
        double t;   // 3

        if (pax > 0) {
            x = total.getPax() != 0 ? total.getPax() : pax;
            ratios[0] = Math.min(1.0, (pax / x));
        } else {
            ratios[0] = 1.0;
        }

        if (products > 0) {
            p = total.getProduct() != 0 ? total.getProduct() * 1.0 : products * 1.0;
            ratios[1] = Math.min(1.0, ((products * 1.0) / p));
        } else {
            ratios[1] = 1.0;
        }

        if (natResources > 0) {
            n = total.getNatResources() != 0 ? total.getNatResources() * 1.0 : natResources * 1.0;
            ratios[2] = Math.min(1.0, ((natResources * 1.0) / n));
        } else {
            ratios[2] = 1.0;
        }

        if (treasury > 0.0) {
            t = total.getTreasury() != 0.0 ? total.getTreasury() : treasury;
            ratios[3] = Math.min(1.0, (treasury / t));
        } else {
            ratios[3] = 1.0;
        }
        return ratios;
    }

    public void decrementPax(double number) {
        this.pax -= number;
    }

    public void decrementTreasury(double number) {
        this.treasury -= number;
    }

    public void decrementProducts(int number) {
        this.products -= number;
    }

    public void decrementNatResources(int number) {
        this.natResources -= number;
    }

    public void incrementPax(double number) {
        this.pax += number;
    }

    public void incrementTreasury(double number) {
        this.treasury += number;
    }

    public void incrementNatResources(int number) {
        this.natResources += number;
    }

    public void incrementProducts(int number) {
        this.products += number;
    }

    public double getPax(){
        return this.pax;
    }

    public int getProduct() {
        return this.products;
    }

    public int getNatResources() {
        return natResources;
    }

    public double getTreasury() {
        return treasury;
    }

    public void setPax(double pax) {
        this.pax = pax;
    }

    public void setProducts(int products) {
        this.products = products;
    }

    public void setNatResources(int natResources) {
        this.natResources = natResources;
    }

    public void setTreasury(double treasury) {
        this.treasury = treasury;
    }

    public double getCostPerPax() {
        return treasury / pax;
    }

    public boolean isSufficient() {
        return this.sufficient;
    }



}
