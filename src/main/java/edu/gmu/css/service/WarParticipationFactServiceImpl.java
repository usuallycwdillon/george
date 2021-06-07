package edu.gmu.css.service;

import edu.gmu.css.entities.WarParticipationFact;

public class WarParticipationFactServiceImpl
        extends GenericService<WarParticipationFact>
        implements WarParticipationFactService {


    @Override
    Class<WarParticipationFact> getEntityType() {
        return WarParticipationFact.class;
    }

}
