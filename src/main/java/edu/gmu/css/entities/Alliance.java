package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.AllianceType;
import org.neo4j.ogm.annotation.NodeEntity;
import sim.engine.SimState;

@NodeEntity
public class Alliance extends Institution {

    private AllianceType allianceType;

    public Alliance() {

    }

    public Alliance(Process process) {

    }

    public Alliance(AllianceType type) {
       allianceType = type;
    }

    @Override
    public void step(SimState simState) {

    }


}
