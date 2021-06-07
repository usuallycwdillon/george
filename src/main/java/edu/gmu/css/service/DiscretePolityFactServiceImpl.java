package edu.gmu.css.service;

import edu.gmu.css.entities.DiscretePolityFact;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.State;

import javax.management.remote.rmi._RMIConnection_Stub;
import java.util.HashMap;
import java.util.Map;

public class DiscretePolityFactServiceImpl extends GenericService<DiscretePolityFact> implements DiscretePolityFactService {

    public DiscretePolityFact getPolityData(Polity p, int year) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", p.getId());
        params.put("year", year);
        String query = "MATCH (p:Polity)<-[d:DESCRIBES_POLITY_OF]-(f:DiscretePolityFact) " +
                "WHERE id(p) = $id AND d.from.year <= $year <= d.until.year " +
                "RETURN f ORDER BY d.from LIMIT 1";
        DiscretePolityFact dpf = session.queryForObject(DiscretePolityFact.class, query, params);
        if (dpf != null) {
            dpf.setPolity(p);
            return dpf;
        } else {
            return null;
        }
    }

    public DiscretePolityFact getStatePolityData(State s, int year) {
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
