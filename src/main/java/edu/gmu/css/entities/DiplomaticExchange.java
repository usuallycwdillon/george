package edu.gmu.css.entities;


import edu.gmu.css.relations.InstitutionParticipation;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import edu.gmu.css.agents.Process;

import java.util.List;
import java.util.Set;

@NodeEntity
public class DiplomaticExchange extends Institution {

    @Id @GeneratedValue
    private Long id;


    public DiplomaticExchange() {
    }

    public DiplomaticExchange(Process process) {

    }

    @Override
    public void step(SimState simState) {

    }

    @Override
    public Long getId() {
        return this.id;
    }


}
