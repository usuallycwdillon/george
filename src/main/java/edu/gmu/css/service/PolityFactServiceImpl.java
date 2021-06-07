package edu.gmu.css.service;

import edu.gmu.css.entities.*;
import edu.gmu.css.worldOrder.WorldOrder;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class PolityFactServiceImpl extends GenericService<Fact> implements FactService {


    public void loadStateInstitutions(State s, WorldOrder wo) {
        int institutionTally = 0;
        WorldOrder worldOrder = wo;
        State state = s;
        Integer year = worldOrder.getFromYear();
        Integer y = year;
        Integer roundDown = y - (y % 5);
        Integer roundUp = wo.getUntilYear();

        Integer dxYear = (year==1816) ? 1817 : year;
        Set<BorderFact> bordersWith = new HashSet<>();
        Set<DipExFact> representedAt = new HashSet<>();
        Set<AllianceParticipationFact> allianceWith = new HashSet<>();
        Set<IgoMembershipFact> membershipFacts = new HashSet<>();

        Map<String, Object> params = new HashMap<>();
        params.put("cowcode", state.getCowcode());
        params.put("during", year);
        params.put("dxYear", dxYear);
        params.put("down", roundDown);
        params.put("up", roundUp);

        // Borders
        String bq = "MATCH (s:State{cowcode:$cowcode})-[:SHARES_BORDER{during:$during}]->(f:Fact) RETURN f";
        Iterable<Fact> borders = session.query(Fact.class, bq, params);
        for (Fact f : borders) {
            BorderFact b = (BorderFact) f;
            bordersWith.add(b);
            worldOrder.allTheInstitutions.add(b.getBorder());
            institutionTally++;
        }
        state.addBorderFacts(bordersWith);

        // Alliances
        String aq = "MATCH (s:State{cowcode:$cowcode})-[e:ENTERED]->(f:Fact) " +
                "WHERE e.from.year <= $during AND (e.until.year IS NULL OR e.until.year >= $during) " +
                "RETURN f";
        Iterable<Fact> alliances = session.query(Fact.class, aq, params);
        for (Fact f : alliances) {
            AllianceParticipationFact a = (AllianceParticipationFact) f;
            allianceWith.add(a);
            worldOrder.allTheInstitutions.add(a.getAlliance());
            institutionTally++;
        }
        state.addAllianceParticipationFacts(allianceWith);

        // (Peace) Treaties

        // Diplomatic Exchange (data starts in 1817, but we just pretend it starts in 1816)
        String dq = "MATCH (s:State{cowcode:$cowcode})-[:REPRESENTED{during:$dxYear}]->(f:Fact)-[:REPRESENTED_IN]->(:DiplomaticExchange) " +
                "RETURN f";
        Iterable<Fact> exchanges = session.query(Fact.class, dq, params);
        for (Fact f : exchanges) {
            DipExFact d = (DipExFact) f;
            representedAt.add(d);
            worldOrder.allTheInstitutions.add(d.getInstitution());
            institutionTally++;
        }
        state.addDiplomaticFacts(representedAt);

        // Trade

        // IGOs
//        String iq = "MATCH (s:State{cowcode:$cowcode})-[m:MEMBERSHIP]->(f:IGOMembershipFact) " +
//                "WHERE $down <= f.during <= $up AND f.membership <> 'Not a Member' RETURN DISTINCT f";
//        Iterable<IgoMembershipFact> memberships = session.query(IgoMembershipFact.class, iq, params);
//        for (IgoMembershipFact f : memberships) {
//            membershipFacts.add(f);
//            worldOrder.allTheInstitutions.add(f.getIgo());
//            institutionTally++;
//        }

        // Finally, tally
        state.establishForeignStrategyCost(institutionTally);
    }

    @Override
    Class<Fact> getEntityType() {
        return Fact.class;
    }

}
