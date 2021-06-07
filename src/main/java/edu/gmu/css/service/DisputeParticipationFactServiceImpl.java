package edu.gmu.css.service;

import edu.gmu.css.entities.DisputeParticipationFact;

public class DisputeParticipationFactServiceImpl extends GenericService<DisputeParticipationFact> implements DisputeParticipationFactService {

    @Override
    Class<DisputeParticipationFact> getEntityType() {
        return DisputeParticipationFact.class;
    }
}
