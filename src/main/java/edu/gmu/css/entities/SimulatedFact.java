package edu.gmu.css.entities;

import org.neo4j.ogm.annotation.NodeEntity;

@NodeEntity
public class SimulatedFact {

    String name;
    String levycode;
    int numParticipants;
    Double durationMonths;
    Double participationMonths;
    Double magnitude;
    Double concentration;

}
