package edu.gmu.css.relations;

import edu.gmu.css.agents.Process;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.data.Resources;
import edu.gmu.css.worldOrder.WorldOrder;
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
        this.commitment = new Resources.ResourceBuilder().build();
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

    protected ProcessDisposition(Builder builder) {
        this.S = false;
        this.P = false;
        this.C = true;
        this.N = builder.N;
        this.U = builder.commitment != null && builder.commitment.getPax() >= 0;
        this.K = true;
        this.from = builder.from;
        this.until = builder.until;
        this.during = builder.during;
        this.owner = builder.owner;
        this.process = builder.process;
        this.commitment = builder.commitment;
        this.objective = builder.objective;
        this.subject = builder.subject;
        this.side = builder.side;
    }


    public static class Builder {
        private boolean N;
        private Long from;
        private Long until;
        private Integer during;
        private Polity owner;
        private Process process;
        private Resources commitment;
        private SecurityObjective objective;
        private Institution subject;
        private int side;

        public Builder from(Long f) {
            this.from = f;
            return this;
        }

        public Builder until(Long u) {
            this.until = u;
            return this;
        }

        public Builder owner(Polity o) {
            this.owner = o;
            return this;
        }

        public Builder process(Process p) {
            this.process = p;
            return this;
        }

        public Builder during(Integer d) {
            this.during = d;
            return this;
        }

        public Builder need(Boolean n) {
            this.N = n;
            return this;
        }

        public Builder commitment(Resources r) {
            this.commitment = r;
            return this;
        }

        public Builder objective(SecurityObjective o) {
            this.objective = o;
            return this;
        }

        public Builder subject(Institution i) {
            this.subject = i;
            return this;
        }

        public Builder side(Integer s) {
            this.side = s;
            return this;
        }

        public ProcessDisposition build() {
            ProcessDisposition pd = new ProcessDisposition(this);
            owner.addProcess(pd);
            process.addProcessParticipant(pd);
            return pd;
        }
    }

    public void commit(Resources resources) {
        commitment = resources;
        this.U = true;
    }

    public void commitMore(Resources resources) {
        commitment.increaseBy(resources);
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

    public void learnPolityWarNeed(WorldOrder wo) {
        if (owner.evaluateWarNeed(this, wo))
            setN(true);
    }
}
