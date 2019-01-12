package edu.gmu.css.entities;

public class Resources {
    /**
     * Resources are some combination of the resource types (and values) a State government has at its disposal.
     */
    private int pax;
    private int products;
    private int natResources;
    private double treasury;


    public static class ResourceBuilder {
        private int pax = 0;
        private int products = 0;
        private int natResources = 0;
        private double treasury = 0.0;

        public ResourceBuilder() { }

        public ResourceBuilder pax(int pax) {
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

        public Resources build() {
            Resources resources = new Resources();
            return resources;
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
        this.pax += other.pax;
        this.natResources += other.natResources;
        this.products += other.products;
        this.treasury += other.treasury;
    }

    public void reduceBy(Resources other) {
        this.pax -= other.pax;
        this.natResources -= other.natResources;
        this.products -= other.products;
        this.treasury -= other.treasury;
    }

    public Resources multipliedBy(double val) {
        return new ResourceBuilder()
                .pax((int)(this.pax * val))
                .natResources((int)(this.natResources * val))
                .products((int)(this.products * val))
                .treasury(this.treasury * val)
                .build();
    }

    public Resources evaluativeSum(Resources other) {
        return new ResourceBuilder()
                .pax(this.pax + other.getPax())
                .natResources(this.natResources + other.getNatResources())
                .products(this.products + other.getProduct())
                .treasury(this.treasury + other.getTreasury())
                .build();
    }

    public Resources evaluativeAvailableDifference(Resources other) {
        return new ResourceBuilder()
                .pax(Math.min(this.pax, other.getPax()))
                .natResources(Math.max((this.natResources - other.getNatResources()), 0))
                .products(Math.max((this.products - other.getProduct()), 0))
                .treasury(Math.max((this.treasury - other.getTreasury()), 0.0))
                .build();
    }

    public boolean isSufficientFor(Resources other) {
        return this.pax >= other.getPax()
                && this.treasury >= other.getTreasury()
                && this.natResources >= other.getNatResources()
                && this.products >= other.getProduct();
    }

    public int getPax(){
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

    public void setPax(int pax) {
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

    public void addPax(int pax) {
        this.pax += pax;
    }

    public void subtractPax(int pax) {
        this.pax -= pax;
    }

    public void addTreasury(double funds) {
        this.treasury += funds;
    }

    public void subtractTreasury(double funds) {
        this.treasury -= funds;
    }

    public void addProducts(int production) {
        this.products += production;
    }

    public void subtractProducts(int consumption) {
        this.products -= consumption;
    }

    public void addNatResources(int discovery) {
        this.natResources += discovery;
    }

    public void subtractNatResources(int reserves) {
        this.natResources -= reserves;
    }



}
