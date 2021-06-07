package edu.gmu.css.service;

import edu.gmu.css.entities.AllianceParticipationFact;
import edu.gmu.css.entities.State;
import org.neo4j.ogm.model.Result;

import java.util.*;


public class AlliancePartnerImpl extends GenericService<State> implements StateService {

    public List<String> getAlliancePartnerIds(AllianceParticipationFact f) {
        List<String> partners = new ArrayList<>();
        String q = "MATCH (af:AllianceParticipationFact) WHERE id(af) = $id WITH af \n" +
        "MATCH (af)-[:ENTERED_INTO]->(a:Alliance{ssType:'Type I: Defense Pact'}" +
                ")<-[:ENTERED_INTO]-(pf:AllianceParticipationFact)<-[:ENTERED]-(s:State) \n" +
        "WHERE af<>pf RETURN DISTINCT s.cowcode AS cow";
        Result r = session.query(q, Collections.singletonMap("id", f.getId().toString()), true);
        Iterator<Map<String, Object>> rit = r.iterator();
        while (rit.hasNext()) {
            partners.add((String) rit.next().get("cow"));
        }
        return partners;
    }

    @Override
    public Class<State> getEntityType() {
        return State.class;
    }
}
