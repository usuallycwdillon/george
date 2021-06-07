package edu.gmu.css;

import edu.gmu.css.entities.State;
import edu.gmu.css.service.StateServiceImpl;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertTrue;

public class StateServicesTest {

    @Test
    public void testRiskyNeighborsService() {
        List<State> states = new StateServiceImpl().getRiskyNeighbors(11364L, 1816);
        List<String> names = new ArrayList<>();
        for (State s : states) {
            names.add(s.getName());
        }
        assertTrue(states.size() == 5);
        assertTrue(names.contains("Italy"));
        assertTrue(names.contains("France"));
        assertTrue(names.contains("Spain"));
        assertTrue(names.contains("United Kingdom"));
        assertTrue(names.contains("Switzerland"));
    }


















}
