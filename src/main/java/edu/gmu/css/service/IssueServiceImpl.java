package edu.gmu.css.service;

import edu.gmu.css.agents.Issue;

public class IssueServiceImpl extends GenericService<Issue> implements IssueService {




    @Override
    Class<Issue> getEntityType() {
        return Issue.class;
    }
}
