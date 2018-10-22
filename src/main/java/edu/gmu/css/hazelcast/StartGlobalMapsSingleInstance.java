package edu.gmu.css.hazelcast;

import com.hazelcast.config.Config;
import com.hazelcast.core.Hazelcast;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.core.IMap;
import edu.gmu.css.agents.Tile;
import edu.gmu.css.entities.Territory;

import java.util.Set;

public class StartGlobalMapsSingleInstance {

    public static void main(String[] args) {
        Config hazelConfig = new Config();
        HazelcastInstance hzi = Hazelcast.newHazelcastInstance(hazelConfig);
        HazelcastInstance hzj = Hazelcast.newHazelcastInstance(hazelConfig);
    }
}
