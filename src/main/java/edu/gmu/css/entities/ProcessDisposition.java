package edu.gmu.css.entities;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.SecurityObjective;
import org.neo4j.ogm.annotation.*;


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
    @Transient
    private Resources commitment;
    @Transient
    SecurityObjective objective;


    public ProcessDisposition() {
        this.U = false;
        this.N = false;
        this.K = true;      // default state is for K to be true (otherwise there would be no process or relation to it
    }

    public ProcessDisposition(Polity polity, Process process, int year) {
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

    public void commit(Resources resources) {
        commitment = resources;
        this.U = true;
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

    public boolean atU() {
        return U;
    }

    public void setU(boolean u) {
        U = u;
    }

    public boolean atN() {
        return N;
    }

    public void setN(boolean n) {
        N = n;
    }

    public boolean atK() {
        return K;
    }

    public void setK(boolean k) {
        K = k;
    }

    public Resources getCommitment() {
        return commitment;
    }

    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }

    public Long getOwnerId() {
        return owner.getId();
    }

    public Long getProcessId() {
        return process.getId();
    }

    public SecurityObjective getObjective() {
        return objective;
    }

    public void setObjective(SecurityObjective objective) {
        this.objective = objective;
    }
}
