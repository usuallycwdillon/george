package edu.gmu.css.hazelcast;

import com.hazelcast.config.Config;
import com.hazelcast.core.Hazelcast;
import com.hazelcast.core.HazelcastInstance;


public class StartHazelcastInstance {

    public static void main(String[] args) {
        //Config config = new DeployedConfig();
        Config config = new LocalConfig();

        HazelcastInstance hzi = Hazelcast.newHazelcastInstance(config);

    }

}


//  java -cp dependentfile1.jar;dependentfile2.jar;c:\location_of_jar\myjar.jar com.mypackage.myClass