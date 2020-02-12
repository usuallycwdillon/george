package edu.gmu.css.data;

import edu.gmu.css.agents.Process;
import edu.gmu.css.entities.*;
import edu.gmu.css.worldOrder.WorldOrder;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

public class Issue extends Entity implements Steppable, Stoppable {

    private Territory territory;
    private Resources resources;
    private Institution institution;
    private Process process;
    private Integer duration;
    private Long from;
    private Polity target;
    private Polity instigator;
    private IssueType issueType;
    private Stoppable stopper;
    private boolean stopped;


    private Issue() {
    }

    private Issue(IssueBuilder builder) {
        this.duration = builder.duration;
        this.resources = builder.resources;
        this.institution = builder.institution; // What results from the process (below)?
        this.process = builder.process;         // What process does this Issue initiate?
        this.from = builder.from;
        this.target = builder.target;
        this.territory = builder.territory;
        this.instigator = builder.instigator;
        this.issueType = builder.issueType;
    }

    public static class IssueBuilder {
        private Territory territory ;
        private Institution institution;
        private Process process;
        private Integer duration;
        private Long from;
        private Polity target;
        private Polity instigator;
        private IssueType issueType;
        private Resources resources = new Resources.ResourceBuilder().build();

        public IssueBuilder() {

        }

        public IssueBuilder territory(Territory t) {
            this.territory = t;
            return this;
        }

        public IssueBuilder resources(Resources r) {
            this.resources = r;
            return this;
        }

        public IssueBuilder institution(Institution i) {
            this.institution = i;
            return this;
        }

        public IssueBuilder process(Process p) {
            this.process = p;
            return this;
        }

        public IssueBuilder duration(Integer d) {
            this.duration = d;
            return this;
        }

        public IssueBuilder from(Long f) {
            this.from = f;
            return this;
        }

        public IssueBuilder target(Polity s) {
            this.target = s;
            return this;
        }

        public IssueBuilder issueType(IssueType it) {
            this.issueType = it;
            return this;
        }

        public IssueBuilder instigator(Polity p) {
            this.instigator = p;
            return this;
        }

        public Issue build() {
            Issue issue = new Issue(this);
            return issue;
        }
    }

    @Override
    public void step(SimState simState) {
        WorldOrder worldOrder = (WorldOrder) simState;
        /*
         *  Always decrement steps remaining.
         *  If there is not a process ongoing, ask instigator to evaluateWarNeed, which may create one.
         *  If there is a process and time runs out, inform it that this Issue no longer persists then self-destruct;
         *  otherwise, there's nothing else to do.
         */
        if (!stopped) {
            duration -= 1;
            if (process == null) {
                instigator.evaluateWarNeed(worldOrder, this);
            } else {
                if (duration <= 0) conclude((WorldOrder) simState);
            }
        }
    }

    public void stop() {
        stopper.stop();
    }

    public Territory getTerritory() {
        return territory;
    }

    public void setTerritory(Territory territory) {
        this.territory = territory;
    }

    public Resources getResources() {
        return resources;
    }

    public void setResources(Resources resources) {
        this.resources = resources;
    }

    public Institution getInstitution() {
        return institution;
    }

    public void setInstitution(Institution institution) {
        this.institution = institution;
    }

    public Process getProcess() {
        return process;
    }

    public void setProcess(Process process) {
        this.process = process;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public Long getFrom() {
        return from;
    }

    public void setFrom(Long from) {
        this.from = from;
    }

    public Polity getTarget() {
        return target;
    }

    public void setTarget(Polity target) {
        this.target = target;
    }

    public Polity getInstigator() {
        return instigator;
    }

    public void setStopper(Stoppable stopper)   {this.stopper = stopper;}

    public Stoppable getStopper() {
        return this.stopper;
    }

    public boolean isStopped() {
        return stopped;
    }

    public void setStopped(boolean stopped) {
        this.stopped = stopped;
    }

    public void conclude(WorldOrder wo) {
        stopped = true;
        stopper.stop();
        if (process != null) process.setP(false);
//        if (institution != null) institution.conclude(wo);
    }

}
