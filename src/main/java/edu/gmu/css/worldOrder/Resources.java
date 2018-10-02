package edu.gmu.css.worldOrder;

import edu.gmu.css.agents.Tile;

import java.util.HashSet;
import java.util.Set;

public class Resources {
    /**
     * Resources are some combination of the resource types (and values) a State government has at its disposal.
     */
    private int population;
    private int products;
    private int natResources;
    private double wealth;

    public static class ResourceBuilder {
        private int population;
        private int products;
        private int natResources;
        private double wealth;

        public ResourceBuilder() { }

        public ResourceBuilder population(int population) {
            this.population = population;
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

        public ResourceBuilder wealth(double wealth) {
            this.wealth = wealth;
            return this;
        }


        public Resources build() {
            Resources resources = new Resources();
            return resources;

        }
    }

    private Resources(ResourceBuilder builder) {
        this.population = builder.population;
        this.products = builder.products;
        this.natResources = builder.natResources;
        this.wealth = builder.wealth;
    }


    private Resources() { }

    public void add(Resources other) {
        this.population += other.population;
        this.natResources += other.natResources;
        this.products += other.products;
        this.wealth += other.wealth;
    }

    public void subtract(Resources other) {
        this.population -= other.population;
        this.natResources -= other.natResources;
        this.products -= other.products;
        this.wealth -= other.wealth;
    }

    public int getPopulation(){
        return this.population;
    }

    public int getProduct() {
        return this.products;
    }

    public int getNatResources() {
        return natResources;
    }

    public double getWealth() {
        return wealth;
    }

    public void setPopulation(int population) {
        this.population = population;
    }

    public void setProducts(int products) {
        this.products = products;
    }

    public void setNatResources(int natResources) {
        this.natResources = natResources;
    }

    public void setWealth(double wealth) {
        this.wealth = wealth;
    }


}
