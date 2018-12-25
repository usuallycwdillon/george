package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import org.neo4j.ogm.annotation.*;
import org.neo4j.register.Register;


@RelationshipEntity(type="DISPOSITION_IN")
public class ProcessDisposition {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    private Polity owner;
    @EndNode
    private Process process;
    @Property
    private Long from;
    @Property
    private Long until;
    @Property
    private Integer during;
    // The owning polity only cares about it's own (internal) relation to the process S, P, and C are not necessary
    @Transient
    private boolean U;
    @Transient
    private boolean N;
    @Transient
    private boolean K;


    public ProcessDisposition() {
        this.U = false;
        this.N = false;
        this.K = true;      // default state is for K to be true (otherwise there would be no process or relation to it
    }

    public ProcessDisposition(Polity polity, Process process, Integer year) {
        this();
        this.owner = polity;
        this.process = process;
        this.during = year;
    }

    public ProcessDisposition(Polity polity, Process process, Long from) {
        this();
        this.owner = polity;
        this.process = process;
        this.from = from;
    }

    public Long getId() {
        return id;
    }

    public Polity getOwner() {
        return owner;
    }

    public Process getProcess() {
        return process;
    }

    public Long getFrom() {
        return from;
    }

    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    public boolean isU() {
        return U;
    }

    public void setU(boolean u) {
        U = u;
    }

    public boolean isN() {
        return N;
    }

    public void setN(boolean n) {
        N = n;
    }

    public boolean isK() {
        return K;
    }

    public void setK(boolean k) {
        K = k;
    }

    public Long getOwnerId() {
        return owner.getId();
    }

    public Long getProcessId() {
        return process.getId();
    }


}
