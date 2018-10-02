//package edu.gmu.css.agents;
//
//import edu.gmu.css.worldOrder.WorldOrder;
//import sim.engine.SimState;
//
//import java.util.HashSet;
//import java.util.Set;
//
//public class WarProcess implements GlobalProcess {
//    /**
//     * Processes are spawned in the context of 'we' and the the environment; which is 'the World'.
//     * Some State is (or, would be) the instigator of war while the other is a target. Regardless, once the process
//     * begins, it is a process that exists in the world regardless of which state caused it to happen. (A lit fuse is lit
//     * regardless of who lit it.)
//     */
//    private State instigator;
//    private State target;
//    private long creationStep;
//    private Set<State> we = new HashSet<>();
//    private Fiat fiat;
//    private double effect;
//    private double cost;
//    private int[] status = new int[3];
//
//
//    public WarProcess newGlobalProcess() {return new WarProcess();}
//
//
//    @Override
//    public void setStatus() {
//
//    }
//
//    @Override
//    public void setFiat() {
//
//    }
//
//    @Override
//    public void step(SimState simState) {
//
//    }
//
//    @Override
//    public void createInstitution() {
//
//    }
//
//}
//
//
///** Binary version of Cioffi-Revilla `Canonical Process` Engine, dialectically
// *
// *  [Omega] [SPC] [UNK]  status  Fiat Sum
// *      [0] [000] [001]  [0,0,1]       1    Both States are aware of the other; initial condition for this process
// *      [0] [001] [001]  [0,1,1]       2    One or the other state is dissatisfied with the other
// *      [0] [001] [011]  [0,1,3]       4    need to take action is recognized
// *      [0] [011] [011]  [0,3.3]       6    no action undertaken; conflict persists
// *      [0] [001] [111]  [0,1,7]       8    States prepare for war
// *      [0] [011] [111]  [0,3,7]       10   conflict persists, though armed/prepared to fight
// *      [0] [111] [111]  [0,7,7]       14   War will break out.
// *      [1] [000] [001]  [1,0,1]   e   2    States are aware of each other; stagnate relationship
// *      [1] [001] [001]  [1,1,1]   x   3    ...but need to respond does not exist
// *      [1] [001] [011]  [1,1,3]   E   5    need to take action is recognized
// *      [1] [011] [011]  [1,3.3]   X   7    no action undertaken; challenge persists
// *      [1] [001] [111]  [1,1,7]   W   9    action undertaken, challenge does not persist
// *      [1] [011] [111]  [1,3,7]   Z   11   action taken, challenge persists, no success
// *      [1] [111] [111]  [1,7,7]   A   15   action is successful; resolves challenge
// */