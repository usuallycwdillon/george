package edu.gmu.css.service;

import edu.gmu.css.entities.DiscretePolityFact;
import edu.gmu.css.entities.State;

import javax.management.remote.rmi._RMIConnection_Stub;
import java.util.HashMap;
import java.util.Map;

public class DiscretePolityFactServiceImpl extends GenericService<DiscretePolityFact> implements DiscretePolityFactService {

    public DiscretePolityFact getPolityData(State s, int year) {
        Map<String, Object> params = new HashMap<>();
        params.put("cowcode",  s.getCowcode());
        params.put("year", year);
        String query = "MATCH (s:State{cowcode:$cowcode})<-[d:DESCRIBES_POLITY_OF]-(f:DiscretePolityFact) "
                + "WHERE (d.from.year <= $year <= d.until.year) OR (d.from.year <= $year AND d.until.year IS NULL) "
                + "RETURN f ORDER BY d.from LIMIT 1";
        DiscretePolityFact f = session.queryForObject(DiscretePolityFact.class, query, params);
        if (f != null) {
            f.setPolity(s);
            return f;
        } else {
            return null;
        }
    }


    @Override
    Class<DiscretePolityFact> getEntityType() {
        return DiscretePolityFact.class;
    }

}
