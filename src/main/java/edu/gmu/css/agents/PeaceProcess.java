//package edu.gmu.css.agents;
//
//import sim.engine.SimState;
//import sim.engine.Steppable;
//
//public class PeaceProcess implements GlobalProcess {
//
//    public GlobalProcess newGlobalProcess() {return new PeaceProcess();}
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
//    public void createInstitution() {
//
//    }
//
//}
//
///** Binary version of Cioffi-Revilla `Canonical Process` Engine, dialectically
// *
// *  [Omega] [SPC] [UNK]  status  Fiat Sum
// *      [0] [000] [001]  [0,0,1]       1    Two of two or more states are at war with each other; we already knew that NOT IMPLEMENTED
// *      [0] [001] [001]  [0,1,1]       2    ASSUME THIS IS ALREADY THE CASE BY THE EXISTENCE OF THIS OBJECT
// *      [0] [001] [011]  [0,1,3]       4    At least two states want peace (with each other)
// *      [0] [011] [011]  [0,3.3]       6    no action undertaken; conflict will persist
// *      [0] [001] [111]  [0,1,7]       8    States will offer peace terms
// *      [0] [011] [111]  [0,3,7]       10   conflict persists; will negotiate
// *      [0] [111] [111]  [0,7,7]       14   Peace terms agreed; new PeaceInstitution will be created
// *      [1] [000] [001]  [1,0,1]   e   2    THIS IS THE DEFAULT STATE WHEN THE PEACE PROCESS IS CREATED - NOT IMPLEMENTED
// *      [1] [001] [001]  [1,1,1]   x   3
// *      [1] [001] [011]  [1,1,3]   E   5    need to take action is recognized
// *      [1] [011] [011]  [1,3.3]   X   7    no action undertaken; challenge persists
// *      [1] [001] [111]  [1,1,7]   W   9    action undertaken, challenge does not persist
// *      [1] [011] [111]  [1,3,7]   Z   11   action taken, challenge persists, no success
// *      [1] [111] [111]  [1,7,7]   A   15   action is successful; resolves challenge
// */