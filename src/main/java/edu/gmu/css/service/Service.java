package edu.gmu.css.service;

import edu.gmu.css.entities.Entity;

public interface Service<T  extends Entity> {
    public Iterable<T> findAll();

    public T find(Long id);

    public void delete(Long id);

    public T createOrUpdate(T object);
}
