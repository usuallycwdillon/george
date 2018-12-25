package edu.gmu.css.hazelcast;

import com.hazelcast.config.*;
import com.hazelcast.core.Hazelcast;
import com.hazelcast.core.HazelcastInstance;


public class StartHazelcastInstance {

    public static void main(String[] args) {

        Config config = new DeployedConfig();

        HazelcastInstance hzi = Hazelcast.newHazelcastInstance(config);

    }

}
