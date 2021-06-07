package edu.gmu.css.agents;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.Domain;
import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.PeaceFact;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.Relationship;
import sim.engine.SimState;

import java.util.LinkedList;
import java.util.List;

public class Peace extends Institution {

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
