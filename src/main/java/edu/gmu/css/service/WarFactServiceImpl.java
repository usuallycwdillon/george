package edu.gmu.css.service;

import edu.gmu.css.entities.WarFact;

public class WarFactServiceImpl extends GenericService<WarFact> implements WarFactService {

    @Override
    Class<WarFact> getEntityType() {
        return WarFact.class;
    }

}
