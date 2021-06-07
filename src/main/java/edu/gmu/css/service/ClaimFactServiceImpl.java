package edu.gmu.css.service;

import edu.gmu.css.entities.ClaimFact;

public class ClaimFactServiceImpl extends GenericService<ClaimFact> implements ClaimFactService {




    @Override
    Class<ClaimFact> getEntityType() {
        return ClaimFact.class;
    }

}
