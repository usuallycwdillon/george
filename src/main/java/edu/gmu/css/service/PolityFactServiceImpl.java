package edu.gmu.css.service;

import edu.gmu.css.entities.*;
import edu.gmu.css.worldOrder.WorldOrder;
import org.apache.commons.collections4.CollectionUtils;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class PolityFactServiceImpl extends GenericService<Fact> implements FactService {


    public void loadStateInstitutions(State s, WorldOrder wo, int y) {
        WorldOrder worldOrder = wo;
        State state = s;
        Integer year = y;
        Integer dxYear = (year==1816) ? 1817 : year;
        Set<BorderFact> bordersWith = new HashSet<>();
        Set<DipExFact> representedAt = new HashSet<>();
        Set<AllianceParticipationFact> allianceWith = new HashSet<>();
        Set<PeaceFact> peaceList = new HashSet<>();

        Map<String, Object> params = new HashMap<>();
        params.put("cowcode", state.getCowcode());
        params.put("during", year);
        params.put("dxYear", dxYear);

        // Borders
        String bq = "MATCH (s:State{cowcode:$cowcode})-[:SHARES_BORDER{during:$during}]->(f:Fact) RETURN f";
        Iterable<Fact> borders = session.query(Fact.class, bq, params);
        for (Fact f : borders) {
            BorderFact b = (BorderFact) f;
            bordersWith.add(b);
            worldOrder.allTheInstitutions.add(b.getBorder());
        }
//        CollectionUtils.addAll(bordersWith, (BorderFact) borders);
        state.addBorderFacts(bordersWith);
//        for (BorderFact b : bordersWith){
//            worldOrder.allTheInstitutions.add(b.getBorder());
//        }
        // Alliances
        String aq = "MATCH (s:State{cowcode:$cowcode})-[e:ENTERED]->(f:Fact) " +
                "WHERE e.from.year <= $during AND (e.until.year IS NULL OR e.until.year >= $during) " +
                "RETURN f";
        Iterable<Fact> alliances = session.query(Fact.class, aq, params);
        for (Fact f : alliances) {
            AllianceParticipationFact a = (AllianceParticipationFact) f;
            allianceWith.add(a);
            worldOrder.allTheInstitutions.add(a.getAlliance());
        }
//        CollectionUtils.addAll(allianceWith, (AllianceParticipationFact) alliances);
        state.addAllianceParticipationFacts(allianceWith);
//        for (AllianceParticipationFact f : allianceWith) {
//            worldOrder.allTheInstitutions.add(f.getAlliance());
//        }
        // (Peace) Treaties

        // Diplomatic Exchange (data starts in 1817, but we just pretend it starts in 1816)
        String dq = "MATCH (s:State{cowcode:$cowcode})-[:REPRESENTED{during:$dxYear}]->(f:Fact)-[:REPRESENTED_IN]->(:DiplomaticExchange) " +
                "RETURN f";
        Iterable<Fact> exchanges = session.query(Fact.class, dq, params);
//        CollectionUtils.addAll(representedAt, (DipExFact) exchanges);
        for (Fact f : exchanges) {
            DipExFact d = (DipExFact) f;
            representedAt.add(d);
            worldOrder.allTheInstitutions.add(d.getInstitution());
        }
        state.addDiplomaticFacts(representedAt);
//        for (DipExFact f : representedAt) {
//            worldOrder.allTheInstitutions.add(f.getInstitution());
//        }
        // Trade

        // IGOs

    }

    @Override
    Class<Fact> getEntityType() {
        return Fact.class;
    }

}
