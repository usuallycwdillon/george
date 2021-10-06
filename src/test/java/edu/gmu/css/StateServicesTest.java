package edu.gmu.css;

import edu.gmu.css.service.ThreatNetworkServiceImpl;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertTrue;

public class StateServicesTest {

    @Test
    public void testRiskyNeighborsService() {
        List<String> names = new ThreatNetworkServiceImpl().getRiskyNeighbors(11364L, 1816);
        assertTrue(names.size() == 5);
        assertTrue(names.contains("325"));  // Italy
        assertTrue(names.contains("220"));  // France
        assertTrue(names.contains("230"));  // Spain
        assertTrue(names.contains("200"));  // UK
        assertTrue(names.contains("225"));  // Switzerland
    }

    @Test
    public void testAnyNeighborsService() {
        List<String> names = new ThreatNetworkServiceImpl().getAnyNeighbor(11364L, 1816);
        assertTrue(names.size() == 12);
        assertTrue(names.contains("200"));  // UK
        assertTrue(names.contains("220"));  // France
        assertTrue(names.contains("225"));  // Switzerland
        assertTrue(names.contains("230"));  // Spain
        assertTrue(names.contains("245"));  // Bavaria
        assertTrue(names.contains("255"));  // Germany
        assertTrue(names.contains("269"));  // Saxony
        assertTrue(names.contains("271"));  // Wuerttemburg
        assertTrue(names.contains("273"));  // Hesse Electoral
        assertTrue(names.contains("275"));  // Hesse Grand Ducal
        assertTrue(names.contains("300"));  // Austria-Hungary
        assertTrue(names.contains("325"));  // Italy
    }

















}
