package edu.gmu.css.service;

import edu.gmu.css.agents.Person;
import org.neo4j.ogm.cypher.ComparisonOperator;
import org.neo4j.ogm.cypher.Filter;

import java.util.Collection;

public class PersonServiceImpl extends GenericService<Person> implements PersonService {

    public Collection<Person> loadAll(String territory) {
        Filter bp = new Filter("birthplace", ComparisonOperator.EQUALS, territory);
        Collection<Person> people = session.loadAll(Person.class, bp, 1);
        return people;
    }

    @Override
    Class<Person> getEntityType() {
        return Person.class;
    }
}
