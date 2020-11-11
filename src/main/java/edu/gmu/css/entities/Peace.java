package edu.gmu.css.entities;

import edu.gmu.css.data.Resources;
import edu.gmu.css.relations.Participation;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.Relationship;
import sim.engine.SimState;
import edu.gmu.css.agents.Process;

import java.util.LinkedList;
import java.util.List;

public class Peace extends Institution {

    @Relationship(type = "PARTICIPATE_IN", direction = Relationship.INCOMING)
    private final List<PeaceFact> participations = new LinkedList<>();

    public Peace() {
    }

    public Peace(Process p, long s) {
        name = "Peace";
        from = s;
        cause = p;
        cost = new Resources.ResourceBuilder().build();
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        double influence = worldOrder.getInstitutionInfluence();
        worldOrder.adjustGlobalWarLikelihood(-1 * influence);
        if (stopped) {
            stopper.stop();
            return;
        }
    }

    public void addPeaceFact(PeaceFact f) {
        participations.add(f);
    }




}
