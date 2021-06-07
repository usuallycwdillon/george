package edu.gmu.css.service;

import edu.gmu.css.entities.Dataset;

public class DatasetServiceImpl extends GenericService<Dataset> implements DatasetService {



    @Override
    Class<Dataset> getEntityType() {
        return Dataset.class;
    }
}
