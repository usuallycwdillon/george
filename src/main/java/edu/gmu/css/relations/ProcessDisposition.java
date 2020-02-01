package edu.gmu.css.relations;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.Resources;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;


@RelationshipEntity(type="DISPOSITION_IN")
public class ProcessDisposition implements Serializable {

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
    @Transient
    private boolean S;
    @Transient
    private boolean P;
    @Transient
    private boolean C;
    @Transient
    private boolean U;
    @Transient
    private boolean N;
    @Transient
    private boolean K;
    @Transient
    private Resources commitment;
    @Transient
    private SecurityObjective objective;
    @Transient
    private Institution subject;
    @Transient
    private int side;


    public ProcessDisposition() {
        this.S = false;
        this.P = false;
        this.C = true;
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

    public boolean atS() {
        return S;
    }

    public void setS(boolean s) {
        this.S = s;
    }

    public boolean atP() {
        return P;
    }

    public void setP(boolean p) {
        this.P = p;
    }

    public boolean atC() {
        return this.C;
    }

    public void setC(boolean c) {
        this.C = c;
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

    public Institution getSubject() {
        return subject;
    }

    public void setSubject(Institution subject) {
        this.subject = subject;
    }

    public int getSide() {
        return side;
    }

    public void setSide(int side) {
        this.side = side;
    }

    public void learnPolityWarNeed() {
        if (owner.getLeadership().evaluateWarNeed(process.getIssue()) +
                owner.getTerritory().getCommonWeal().evaluateWarNeed(process.getIssue()) > 1.0)
            setN(true);
    }
}
