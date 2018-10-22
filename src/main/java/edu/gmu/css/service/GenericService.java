package edu.gmu.css.service;


import edu.gmu.css.entities.Entity;
import org.neo4j.ogm.session.Session;
import edu.gmu.css.service.Neo4jSessionFactory;


public abstract class GenericService<T extends Entity> implements Service<T> {

    private static final int DEPTH_LIST = 1;
    private static final int DEPTH_ENTITY = 1;
    protected Session session = Neo4jSessionFactory.getInstance().getNeo4jSession();

    @Override
    public Iterable<T> findAll() {
        return session.loadAll(getEntityType(), DEPTH_LIST);
    }

    @Override
    public T find(Long id) {
        return session.load(getEntityType(), DEPTH_ENTITY);
    }

    @Override
    public void delete (Long id) {
        session.delete(session.load(getEntityType(), id));
    }

    @Override
    public T createOrUpdate(T entity) {
        session.save(entity, DEPTH_ENTITY);
        return find(entity.getId());
    }

    abstract Class<T> getEntityType();

}
