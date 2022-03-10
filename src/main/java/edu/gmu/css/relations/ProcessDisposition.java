package edu.gmu.css.relations;

import edu.gmu.css.agents.Process;
import edu.gmu.css.agents.WarProcess;
import edu.gmu.css.agents.World;
import edu.gmu.css.data.Resources;
import edu.gmu.css.data.SecurityObjective;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.service.AttackPathImpl;
import edu.gmu.css.worldOrder.WorldOrder;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Map;
import java.util.Objects;


public class ProcessDisposition implements Serializable {

    private Polity owner;
    private Process process;
    private Long from;
    private Long until;
    private Integer during;
    private boolean S;
    private boolean P;
    private boolean C;
    private boolean U;
    private boolean N;
    private boolean K;
    private boolean stopped;
    private int uT = 9999;
    protected boolean outcome = false; // whether the other side has acted first
    protected int[] status = new int[] {0, 0, 0};
    protected char fiat = 'x';
    private Resources commitment;
    private final Resources mobilized;
    private SecurityObjective objective = SecurityObjective.ACCEPT;
    private String subject;
    private int side;
    private Map<String, Object> attackPath;


    public ProcessDisposition() {
        this.S = false;
        this.P = false;
        this.C = true;
        this.U = false;
        this.N = false;
        this.K = true;      // default state is for K to be true (otherwise there would be no process or relation to it
        this.commitment = new Resources.ResourceBuilder().build();
        this.mobilized = new Resources.ResourceBuilder().build();
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
        this.U = false;
        this.K = true;
        this.stopped = false;
        this.from = builder.from;
        this.until = builder.until;
        this.during = builder.during;
        this.owner = builder.owner;
        this.process = builder.process;
        this.commitment = builder.commitment;
        this.mobilized = new Resources.ResourceBuilder().build();
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
        private Resources commitment = new Resources.ResourceBuilder().build();
        private SecurityObjective objective;
        private String subject;
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

        public Builder subject(String i) {
            this.subject = i;
            return this;
        }

        public Builder side(Integer s) {
            this.side = s;
            return this;
        }

        public ProcessDisposition build() {
            ProcessDisposition pd = new ProcessDisposition(this);
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

    public void mobilizeCommitment(Resources r) {
        // Mobilize what can be mobilized and add supplemental request for all remaining
        // Note: Supplemental evaluates against whole PD commitment.
        Resources requirement = r;
        if (!Objects.isNull(r) && !r.isEmpty() ) {
            if (owner.getResources().isSufficientFor(requirement)) {
                this.mobilized.increaseBy(requirement);
                owner.getResources().reduceBy(requirement);
            }
        }
//        if (!this.mobilized.isSufficientFor(this.commitment)) {
//            Resources gap = this.commitment.evaluativeDifference(this.mobilized);
//            owner.getSecurityStrategy().addSupplemental(this, gap);
//        }
    }

    public void mobilizeCommitment() {
        this.mobilized.increaseBy(this.commitment);
        owner.getResources().reduceBy(this.commitment);
    }

    public Resources getMobilized() {
        return this.mobilized;
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

    public boolean isOutcome() {
        return outcome;
    }

    public void setOutcome(boolean outcome) {
        this.outcome = outcome;
    }

    public int[] getStatus() {
        return status;
    }

    public void setStatus(int[] status) {
        this.status = status;
    }

    public char getFiat() {
        return fiat;
    }

    public void setFiat(char fiat) {
        this.fiat = fiat;
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

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public int getSide() {
        return side;
    }

    public void setSide(int side) {
        this.side = side;
    }

    public int getUt() {
        return uT;
    }

    public void setUt(int t) {
        this.uT = t;
    }

    public void updateStatus() {
        /** Binary version of Cioffi-Revilla `Canonical Process` Engine, dialectically
         *  The Omega digit reflects whether the outcome has been calculated
         *  The [SPC] digit reflects the external state
         *  The [UNK] digit reflects the internal state
         *
         *  [Omega] [SPC] [UNK]  status  Fiat Sum
         *      [0] [000] [001]  [0,0,1]   -   1    Both States are aware of the other, preliminary to the process; OBE
         *      [0] [001] [001]  [0,1,1]   -   2    A change/challenge occurs between participating States; initial condition for any process
         *      [0] [001] [011]  [0,1,3]   -   4    need to take action is recognized
         *      [0] [011] [011]  [0,3.3]   -   6    no action undertaken; change/challenge persists
         *      [0] [001] [111]  [0,1,7]   -   8    States prepare to act
         *      [0] [011] [111]  [0,3,7]   -   10   change/challenge persists
         *      [0] [111] [111]  [0,7,7]   -   14   Institution will be realized
         *      [1] [000] [001]  [1,0,1]   e   2    Stagnate relationship between 2 or more Polities, preliminary to the process; also OBE
         *      [1] [001] [001]  [1,1,1]   x   3    ...but need to respond does not exist
         *      [1] [001] [011]  [1,1,3]   E   5    need to take action is recognized
         *      [1] [011] [011]  [1,3.3]   X   7    no action undertaken; change/challenge persists
         *      [1] [001] [111]  [1,1,7]   W   9    action undertaken, change/challenge does not persist
         *      [1] [011] [111]  [1,3,7]   Z   11   action taken, change/challenge persists, no success
         *      [1] [111] [111]  [1,7,7]   A   15   action is successful; change/challenge resolves into new institution
         */
        // Canonical Process engine
        int internal = 0;
        int external = 0;
        // Assume _00
        if (this.outcome) {
            this.status[0] = 1;
        } else {
            this.status[0] = 0;
        }
        if (this.C) {
            external += 1;
        }
        if (this.P) {
            external += 2;
        }
        if (this.S) {
            external += 4;
        }
        if (this.K) {
            internal += 1;
        }
        if (this.N) {
            internal += 2;
        }
        if (this.U) {
            internal += 4;
        }

        this.status[1] = external;
        this.status[2] = internal;
        setFiat();
    }

    public int sumStatus() {
        int statusSum = 0;
        statusSum = Arrays.stream(status).sum();
        return statusSum;
    }

    public void setFiat() {
        // This process is designed to "rachet", meaning that the process will advance to the next potential fiat, even
        // if the conditions for equivalence and the outcome have not been met; only that the limitations of theee
        // previous fiat have been surpassed. For example: K, C, N, ~U will be classified as fiat E even before P/~P has been
        // evaluated.
        int [] assessableStatus = this.getStatus();

        if (assessableStatus[1] == 1) {
            if (assessableStatus[2] == 1) {         // 011 = 2, 111 = 3
                this.fiat = 'x';
            } else if (assessableStatus[2] == 3) {  // 013 = 4, 113 = 5
                this.fiat = 'E';
            } else if (assessableStatus[2] == 7) {  // 017 = 8, 117 = 9
                this.fiat = 'W';
            } else {
                this.fiat = '?';
            }
        }
        else if (assessableStatus[1] == 3) {        // 03_
            if (assessableStatus[2] == 3) {         // 033 = 6, 133 = 7
                this.fiat = 'X';
            }
            else if (assessableStatus[2] == 7) {    // 037 = 10, 137 = 11
                this.fiat = 'Z';
            } else {
                this.fiat = '?';
            }
        }
        else if (assessableStatus[1] == 7) {        // 07_
            if (assessableStatus[2] == 7) {         // 077 = 14, 177 = 15
                this.fiat = 'A';
            }
            else {
                this.fiat = '?';
            }
        }
    }

    public void decrementUt() {
        if (this.uT > 0) {
            this.uT -=1;
        } else {
            this.uT = 0;
        }
    }

    public void learnPolityWarNeed(WorldOrder wo) {
        if (owner.evaluateWarNeed(this, wo))
            setN(true);
    }

    public Map<String, Object> getAttackPath(WorldOrder wo) {
        if (this.attackPath == null || this.attackPath.size() == 0) {
            this.attackPath = new AttackPathImpl().findAttackPath(owner.getTerritory(), getEnemy().getTerritory(), wo);
        }
        return this.attackPath;
    }

    public void setAttackPath(Map<String, Object> ap) {
        this.attackPath = ap;
    }

    public Polity getEnemy() {
        ProcessDisposition pd = process.getProcessDispositionList().get(0);
        if (pd == this) {
            return process.getProcessDispositionList().get(1).getOwner();
        } else {
            return pd.getOwner();
        }
    }

    public ProcessDisposition getEnemyDisposition() {
        for (ProcessDisposition pd : process.getProcessDispositionList()) {
            if ( !pd.getOwner().equals(owner) ) {
                return pd;
            }
        }
        return null;
    }

    public boolean strike() {

        return false;
    }

    public int developDisposition(WarProcess p, WorldOrder wo) {
        WarProcess proc = p;
        WorldOrder worldOrder = wo;
        this.updateStatus();
        int statusSum = this.sumStatus();
        if (proc.isStopped() || this.stopped) return statusSum;
        switch (statusSum) {
            case 2:
                this.getOwner().evaluateWarNeed(this, worldOrder);
                break;
            case 3:
                break;
            case 4:
                this.getOwner().evaluateWarWillingness(this, worldOrder);
                break;
            case 5 :
                if (getEnemyDisposition().atP()) setP(true);
                if (getProcess().getIssue().getDuration() == 0) setOutcome(true);
                break;
            case 6:
                setOutcome(true);
                break;
            case 7:
                proc.setOutcome(true);
                break;
            case 8:
                if (this.uT > 0) {
                    decrementUt();
                    if (!getEnemyDisposition().atP() && proc.getIssue().getDuration() == 0) {
                        this.setOutcome(true); // will go to 9W
                        break;
                    }
                } else {
                    int o = objective.value;
                    setP(true);
                    if (o >= 0 && proc.getDispute() == null && proc.getInstitution() == null) {
                        proc.setFirstPunch(this);
                        if (o < 4 && proc.getDispute() == null) {
                            proc.createDispute(worldOrder);
                        } else {
                            if (proc.getInstitution() == null) proc.createWar(this, worldOrder);
                        }
                    }
                }
                break;
            case 9:
                proc.setOutcome(true);
                break;
            case 10: // if issue is resolved and strategic objective is met
                break;
            case 11:
                this.setOutcome(true);
                proc.setOutcome(true);
                break;
            case 14:
                setOutcome(true);
                break;
            case 15:
                // End the war
                this.setS(true);
                proc.setNowFighting(false);
                proc.setOutcome(true);
                break;
        }
        updateStatus();
        this.setFiat();
        return this.sumStatus();
    }

}
