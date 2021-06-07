package edu.gmu.css.service;

import edu.gmu.css.entities.DiscretePolityFact;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.State;
import edu.gmu.css.worldOrder.WorldOrder;

import java.util.HashMap;
import java.util.Map;

import static edu.gmu.css.worldOrder.WorldOrder.DEBUG;

public class DiscretePolityFactServiceImpl
        extends GenericService<DiscretePolityFact>
        implements DiscretePolityFactService {

    public DiscretePolityFact getPolityData(Polity p, int year) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", p.getId());
        params.put("year", year);
        String query = "MATCH (p:Polity)<-[d:DESCRIBES_POLITY_OF]-(f:DiscretePolityFact) " +
                "WHERE id(p) = $id AND d.from.year <= $year AND ($year <= d.until.year OR d.until.year IS NULL) " +
                "RETURN f ORDER BY d.from LIMIT 1";
        DiscretePolityFact dpf = session.queryForObject(DiscretePolityFact.class, query, params);
        if (dpf != null) {
            dpf.setPolity(p);
            return dpf;
        } else {
            if (DEBUG) System.out.println(p.getName() + " has no discrete polity fact");
            DiscretePolityFact neutralPolity = new DiscretePolityFact.FactBuilder()
                    .from(0L)
                    .until(2500L)
                    .polity(p)
                    .autocracyRating(5)
                    .democracyRating(5)
                    .polityScore(0)
                    .build();
            return neutralPolity;
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
