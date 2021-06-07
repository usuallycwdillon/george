package edu.gmu.css.service;

import edu.gmu.css.agents.Person;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;

import java.util.Collection;
import java.util.stream.Collectors;

public class PersonServiceImpl extends GenericService<Person> implements PersonService {

    public Collection<Person> loadAll(String territory) {
        Filter bp = new Filter("birthplace", ComparisonOperator.EQUALS, territory);
        return session.loadAll(Person.class, bp, 2);
    }

    @Override
    Class<Person> getEntityType() {
        return Person.class;
    }
}
