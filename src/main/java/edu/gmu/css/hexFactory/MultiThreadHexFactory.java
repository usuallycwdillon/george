package edu.gmu.css.hexFactory;

import edu.gmu.css.entities.Dataset;
import edu.gmu.css.entities.Territory;
import edu.gmu.css.agents.Tile;

import edu.gmu.css.service.Neo4jSessionFactory;
import org.geotools.data.FileDataStore;
import org.geotools.data.FileDataStoreFinder;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.ogm.config.Configuration;
import org.neo4j.ogm.session.SessionFactory;
import org.opengis.feature.simple.SimpleFeature;

import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.transaction.Transaction;

import java.io.*;
import java.util.*;

public class MultiThreadHexFactory extends Thread {
    private Thread t;
    private String threadName;




    MultiThreadHexFactory(String name) {
        threadName = name;
        System.out.println("Creating " + threadName);
    }

    public void run() {
        System.out.println("Running " + threadName);
        try {

            // action


            Thread.sleep(50);
        } catch (InterruptedException e) {
            System.out.println("Thread interrupted: " + threadName);
            e.printStackTrace();
        } finally {
            System.out.println("Thread " + threadName + " exiting now.");
        }
        System.out.println("Thread " + threadName + " exiting now.");
    }

    public void start() {
        System.out.println("Starting " + threadName);
        if (t==null) {
            t = new Thread(this, threadName);
            t.start();
        }
    }

}

