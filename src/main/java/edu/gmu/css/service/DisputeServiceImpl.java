package edu.gmu.css.service;

import edu.gmu.css.entities.Dispute;

public class DisputeServiceImpl extends GenericService<Dispute> implements DisputeService {


    @Override
    Class<Dispute> getEntityType() {
        return Dispute.class;
    }

}
