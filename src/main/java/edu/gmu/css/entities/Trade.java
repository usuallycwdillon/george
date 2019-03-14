package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.relations.TradeRelation;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class Trade extends Institution{

    @Id @GeneratedValue
    Long id;
    @Property
    Long from;
    @Property
    Long until;
    @Relationship
    Set<TradeRelation> tradePartnerships = new HashSet<>();

    public Trade() {
    }

    public Trade(Process process) {

    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Long getFrom() {
        return from;
    }

    public void setFrom(Long from) {
        this.from = from;
    }

    @Override
    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    public Set<TradeRelation> getTradePartnerships() {
        return tradePartnerships;
    }

    public void setTradePartnerships(Set<TradeRelation> tradePartnerships) {
        this.tradePartnerships = tradePartnerships;
    }

    @Override
    public void step(SimState simState) {

    }
}
