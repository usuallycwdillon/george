package edu.gmu.css.entities;

import lombok.Builder;
import sim.engine.SimState;
import sim.engine.Steppable;
import sim.engine.Stoppable;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class Issue extends Entity implements Steppable, Stoppable {

    private Territory territory;
    private Resources resources;
    private Institution institution;
    private Process process;
    private Integer duration;
    private Long from;
    private Polity target;
    private Stoppable stopper;


    private Issue() {
    }

    private Issue(IssueBuilder builder) {
        this.duration = builder.duration;
        this.resources = builder.resources;
        this.institution = builder.institution;
        this.process = builder.process;
        this.from = builder.from;
    }

    public static class IssueBuilder {
        private Territory territory ;
        private Resources resources = new Resources.ResourceBuilder().build();
        private Institution institution;
        private Process process;
        private Integer duration;
        private Long from;
        private Polity target;

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

        public Issue build() {
            Issue issue = new Issue(this);
            return issue;
        }
    }

    @Override
    public void step(SimState simState) {
        duration -= 1;
        if (duration <= 0) stop();
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

    public void setStopper(Stoppable stopper)   {this.stopper = stopper;}

    public Stoppable getStopper() {
        return this.stopper;
    }

}
