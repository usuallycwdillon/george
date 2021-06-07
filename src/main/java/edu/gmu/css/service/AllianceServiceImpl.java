package edu.gmu.css.service;

import edu.gmu.css.entities.Alliance;

public class AllianceServiceImpl extends GenericService<Alliance> implements AllianceService {



    @Override
    Class<Alliance> getEntityType() {
        return Alliance.class;
    }
}
