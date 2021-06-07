package edu.gmu.css.service;

import edu.gmu.css.entities.DisputeFact;

public class DisputeFactServiceImpl extends GenericService<DisputeFact> implements DisputeFactService {


    @Override
    Class<DisputeFact> getEntityType() {
        return DisputeFact.class;
    }
}
