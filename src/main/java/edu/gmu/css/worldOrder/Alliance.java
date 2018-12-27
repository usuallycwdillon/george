package edu.gmu.css.worldOrder;

import edu.gmu.css.data.AllianceType;
import org.neo4j.ogm.annotation.GeneratedValue;
import org.neo4j.ogm.annotation.Id;
import org.neo4j.ogm.annotation.NodeEntity;
import sim.engine.SimState;

@NodeEntity
public class Alliance extends Institution {

    private AllianceType allianceType;

    public Alliance() {

    }

    public Alliance(AllianceType type) {
       allianceType = type;
    }

    @Override
    public void step(SimState simState) {

    }


}
