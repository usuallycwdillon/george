package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.PeaceFact;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.LinkedList;
import java.util.List;

@NodeEntity
public class Peace extends Institution {

    @Id @GeneratedValue Long id;
    @Property private final String name;
    @Property private final Enum domain;
    @Property private Double maintenance;
    @Property private double strength;

    @Relationship(type = "PARTICIPATE_IN", direction = Relationship.INCOMING)
    private final List<PeaceFact> participations = new LinkedList<>();

    public Peace() {
        name = "Peace";
        domain = Domain.PEACE;
        cost = new Resources.ResourceBuilder().build();
    }

    public Peace(Process p, long s) {
        name = "Peace";
        from = s;
        cause = p;
        cost = new Resources.ResourceBuilder().build();
        domain = Domain.PEACE;
        strength = 0.50;
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        double influence = worldOrder.getInstitutionInfluence();
        worldOrder.adjustGlobalWarLikelihood(-1.0 * influence);
        if (stopped) {
            stopper.stop();
            return;
        }
    }

    @Override
    public Long getId() {
        return id;
    }


    public void addPeaceFact(PeaceFact f) {
        participations.add(f);
    }




}

