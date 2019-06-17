

## Setup 

Given a map year and boundary years for data, a world is instantiated. This example uses 1816.

1. Set initial parameters, including those set by database query
1. Import _Territories_ that are primary territory of a State, including the _Tiles_ that compose it.
    1. Rehydrate _Territories_ with first order relations.
    1. Initiate social networks on _Territories_. 
    1. Link _Territories_ to _States_ (or create a generic _Polity_ as a placeholder)
    1. (Alternatively, to reset population data) Populate the _Tiles_ as a Zipf distribution of NMC population; divide 
    urban population among tiles with sufficiently large population.
1. Load institutional data for _States_:
    1. Borders
    1. Diplomatic Exchange
    1. Alliances
    1. (Future accomodation for Trade and IGO membership)
1. Create _Leadership_ objects for _States_ and add them to the schedule. 
    1. _Leadership_ and _Polities_ know each other
    1. Configure _Leadership_ to match Polity IV Data information (incomplete)
    1. _Leaderships_ set economic and security policies; security policies come from NMC MILEX and MILPER data
    1.  Add _States_ to the schedule.
1. Initialize weekly history of wars (how many distinct wars ongoing each week)
1. Add the _Tiles_ to the schedule
1. Create a _Probabilistic Causality_ agent to initiate conflicts between _States_ by Poisson average.
1. Create the *world* steppable:
    1. Measure global probability of war each week.
    1. Have _Territories_ update their data on the first week of every simulation year.
    1. Record the number of ongoing processes (by type), institutions (by type)
    1. Stop the simulation if:
        1. the global probability of war is zero,
        1. there has been peace for a configurable (100) number of years,
    1. Schedule the world to step each week.   
 
## Simulation Process

The _Probabilistic Causality_ (PC) agent may create an _Issue_ on any given step (week) between a random State Leadership and 
a non-allied State within two border-crossings. The _Issue_ is also associated with a new _Process Disposition_ agent. 
The issue can last between 1 and 523 weeks/steps. The _Issue_ can specify the conflict object: any specific institution 
(such as a Border, Trade Agreement, War, ...), any Resource (a Territory/set of tiles, wealth, military personnel, ... ); 
or a Process (conflict process, peace process, state-making process, ...). These specifications are not currently being 
used, but the framework is designed to be extended in this way. Once a State Leadership agent has initiated an Issue, it 
exists until its duration has expired or the associated _Process_ has institutionalized (become a War, Trade Agreement, 
...). 

A _Process Disposition_ (PD) agent has no fixed duration and may outlive the preceding _Issue_. The PD agent represents 
one State's side of a new international process; a gross approximation of a domestic process that involves the _Leadership_ 
and the _Common Weal_. If the _State_ is willing to undertake military action against the target polity, a new _War Process_ 
begins and the initiating _State_ has already progressed via the canonical process to an interim fiat where a conflict
exists (C) and the group is willing to undertake action (U). The target Polity is involved in this new process (whether 
they want to be or not), the international process begins at an interim fiat where a conflict exists (C) and the targeted
polity also creates its own domestic PD toward this international process. This event represents four new objects:
1. an _Issue_ with some random longevity measured in weeks/steps
1. the initiator's _Process Disposition_ wherein __C__ and __U__ are `true`
1. the tartget's _Process Disposition_ wherein __C__ is `true`
1. a _War Process_ wherein __C__ is `true`
  
The _Issue_ will continue to exist for the term of its initial declaration unless superseded by a _War_ or _Conflict_, 
at which time its Stoppable gets called and it is removed from the MASON schedule. The lifetime of the other three objects 
is interconnected, but can be described primarily in terms of the _War Process_ and the conditions under which it develops.  

The _Issue_ is not stored as an object in the database, but as a reference value in the property fields of the other three
objects. The _War Process_ is stored generically, as a _Process_ node and the _Process Disposition_ objects are relations
between the _Process_ node and the _State_ nodes. 



  






