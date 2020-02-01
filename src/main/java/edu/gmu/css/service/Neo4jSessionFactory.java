package edu.gmu.css.service;

import org.neo4j.ogm.config.Configuration;
import org.neo4j.ogm.session.Session;
import org.neo4j.ogm.session.SessionFactory;
import edu.gmu.css.service.H3IdStrategy;

public class Neo4jSessionFactory {
    private final static Configuration configuration = new Configuration.Builder()
//            .credentials("neo4j", "george")
//            .uri("file:///home/cw/Code/george/src/main/resources/data/databases/worldOrderData.db")
//            .uri("bolt://neo4j:george@localhost")
//            .uri("bolt://35.186.183.84")
//            .uri("bolt://neo4j:george@192.168.2.94")
            .uri("bolt://neo4j:george@192.168.1.94")
            .useNativeTypes()
            .build();

    static H3IdStrategy idStrategy = new H3IdStrategy();
    static NameIdStrategy nameIdStrategy = new NameIdStrategy();

    private static final SessionFactory sessionFactory = new SessionFactory(
            configuration, "edu.gmu.css.entities", "edu.gmu.css.agents", "edu.gmu.css.relations");

    private static Neo4jSessionFactory factory = new Neo4jSessionFactory();

    public static Neo4jSessionFactory getInstance() {
        return factory;
    }

    private Neo4jSessionFactory() {  }

    public Session getNeo4jSession() {
        return sessionFactory.openSession();
    }

}

