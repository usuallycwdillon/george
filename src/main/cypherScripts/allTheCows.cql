// This Cypher Query Language (CQL) script will import several key peace science data sets into a Neo4j graph database
// for grounding and/or validating agent-based simulation models of world politics and International Relations.
//
// @author {Clarence Dillon, cdillon2@gmu.edu}
// Department of Computational and Data Sciences, George Mason University College of Science
//
//  See the README.md for project notes and a few instructions about using this file and the imported data.
//
//  Data gets created/imported in this order, with resources metadata (the provenance chain) preceding each import:
//  1. Time tree -- an in-graph representation of weeks and months in years in a timeline, beginning 1815
//  2. Levy Great Powers, Great Power Wars
//  3. import states2016.csv 
//  2. (DONE) import major2016
//  4. (DONE) import NMC_5_0-wsupplementary.csv /
//  5. (DONE) import Gleditsch extended war data
//  6. (DONE) import Diplomatic_Exchange_2006v1.csv /
// *** Done *** up to line 1055
//  7. import COW_Trade_4.0 and Trade Supplements
//  8. import cow_alliances
//  9. import Intergovernmental_Organizations(v2.3)
// 10. import MIDA_4.csv /
//     import MIDB_4.csv / 
// 11. import MIDLOC_1.1.csv  
// 12. import Inter-StateWarData_v4.0.csv
// 13. import Intra-StateWarData_v4.1.csv
// 14. import Extra-StateWarData_v4.0.csv /
// 15. import MID Narratives 200
// 16. revise tasks 1-15 so that data is parsed correctly (regex?) from original sources without modifications.
// end of tasks


// Before I get started, I want to add nodes in the graph to represent years, since some data is about
// years as much as it about the state. e.g., (state)-[:HAS_MILEX_IN]->(1818{began:date({year:1818, month:1, day:1})})
// I am trying to follow ISO 8601, which specifies that the first week of the year begins on the first Thursday of the 
// year (even though there was no ISO when the bulk of the data begins, in 1815. The last week of the year always 
// includes 28 December. The last day of the year, 31 December could occur on the first week of the following year.)
// Assert uniqueness of beginning dates and create index for faster date querying
CREATE CONSTRAINT ON (y:Year) ASSERT y.began IS UNIQUE;
CREATE CONSTRAINT ON (w:Week) ASSERT w.began IS UNIQUE;

// Reported on Neo4j Slack on 18June2018, Neo4j has a bug that intermittently reports bad first day of the week when 
// given a year and week number. My workaround was to create a spreadsheet of values and read it in. 
//WITH range(1815, 2020) AS years
//FOREACH (yr IN years |
//  MERGE (y:Year{name:toString(yr), began:date({year:yr, month:1, day:1}), ended:date({year:yr, month:12, day:31}),
//  last:date({year:yr, month:12, day:28}) })
//  SET y.weeksThisYear = y.last.week );

//begany,beganm,begand,endedy,endedm,endedd,weeknum,year
//LOAD CSV WITH HEADERS FROM "file:///weeksNums.csv" AS row
//MATCH (y:Year{began:date({year:toInteger(row.year)})})
//CREATE (w:Week{began:date({year:toInteger(row.begany), month:toInteger(row.beganm), day:toInteger(row.begand)}),
// ended:date({year:toInteger(row.endedy), month:toInteger(row.endedm), day:toInteger(row.endedd)}),
// weekOfYear:toInteger(row.weeknum), name:toString((toInteger(row.year) * 100) + row.weeknum)-[:PART_OF{
//  weekOfYear:toInteger(row.weeknum)}]->(y)

// Before using the script below to create date Try this:
// ```UNWIND[date({year:1816,week:1}), date({year:1816,week:52}), date({year:1817,week:1}), date({year:1817,week:10}), 
//   date({year:1817,week:30}), date({year:1817,week:52}), date({year:1818,week:1}), date({year:1818,week:52}), 
//   date({year:1819,week:1}), date({year:1819,week:52}) ] AS theFirstDateOfThisWeek RETURN theFirstDateOfThisWeek```
// 
// I get this:
// ```theFirstDateOfThisWeek
// "1816-01-01" // correct
// "1816-12-23" // correct
// "1817-12-30" // should be "1816-12-30" year is +1
// "1818-03-03" // should be "1817-03-03" year is +1
// "1818-07-21" // should be "1817-07-21" year is +1
// "1818-12-22" // should be "1817-12-22" year is +1
// "1817-12-30" // should be "1817-12-29" mo/day for 1817
// "1818-12-22" // should be "1818-12-28" mo/day for 1817
// "1819-01-04" // correct
// "1819-12-27" // correct ```
// ==== update 4 SEP 2018 =====
// This seems have been corrected in Neo4j v3.4.6.

WITH range(1815, 2020) AS years
FOREACH (yr IN years |
  MERGE (y:Year{name:toString(yr), began:date({year:yr, month:1, day:1}), ended:date({year:yr, month:12, day:31}),
  last:date({year:yr, month:12, day:28}) })
  SET y.weeksThisYear = y.last.week,
      y.firstWeekBegins = date({year:yr,week:1}),
      y.lastWeekBegins = date({year:yr, week:y.weeksThisYear})
  FOREACH (wk IN range(1,y.weeksThisYear) |
    MERGE (w:Week{weekYear:((yr * 100) + wk), forYear:yr})
    SET w.name = toString(w.weekYear),
        w.began = date({year:yr, week:wk}),
        w.ended = date(w.began + duration('P5D') )
    CREATE (w)-[:PART_OF{weekCount:wk}]->(y)
    )
);

// Control for filename conflicts in the data imports...
CREATE CONSTRAINT ON (f:Dataset) ASSERT f.filename IS UNIQUE;

// ####################################################################################################################
// Jack Levy's "Great Power Wars" cover the years 1495-1815. I have munged together data from the OCR(?) text copies of 
// Levy's data that can be found at ICPSR and GESIS. The Levy dataset is a smaller than COW data, making it a nice 
// dataset to develop the import script and schema data; a recommendation from Claudio Cioffi-Revilla at the beginning
// of this validation project.

// Levy Great Power Wars Metadata
CREATE (s:Source{ 
  name:"Levy Great Power Wars", 
  version:toFloat(1.0),
  published:date({year:1994, month:4}),
  validFrom:date({year:1495, month:1, day:1}),   
  validUntil:date({year:1815, month:12, day:31}),
  citation:"Levy, Jack S. Great Power Wars, 1495-1815. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 1994-05-20. https://doi.org/10.3886/ICPSR09955.v1",
  host:"ICPSR",
  url:["https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/9955","https://dbk.gesis.org/dbksearch/sdesc2.asp?no=8119&db=e&doi=10.4232/1.8119"],   
  overview:"This study identifies 'great power' wars, i.e., major-minor wars, or those involving at least one great power on each side. In order to exclude protracted conflicts with low levels of fighting, an annual average of 1,000 battle deaths was required for inclusion in this collection. Great powers are defined as countries or states that play a major role in international politics with respect to security-related issues. Such powers must have a high level of military capability relative to other states and be able to project military power beyond their borders with the option of using force, or the threat of force, to help shape their external environment. They play a large role in international organizations and politics and are perceived as great powers by other members of the international community. Variables in this collection include the duration of each war, its severity in terms of the number of battle-connected deaths, the extent of the war (defined as the number of great powers participating in the fighting), magnitude of the war (combining extent and duration indicators), and the concentration of war (the ratio of severity to magnitude).",
  purpose:"All wars from 1495 to 1815 in which the sum of fatalities for all participants was at least 1,000."
})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"Great Power System",
  version:toFloat(1.0),
  published:date({year:1994, month:4}),
  note:"This data file represents this author's recreation of J. Levy's data from ICPSR 09955-0001-Codebook.txt and GESIS ZA9119.dta files. The bulk of Levy's war data is missing from the ICPSR archives (DS10 Diskette D00154 download file is missing/not linked).",
  purpose:"Identify the great powers in the system from 1495-1815.",
  url:["https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/9955","https://dbk.gesis.org/dbksearch/sdesc2.asp?no=8119&db=e&doi=10.4232/1.8119"],   
  filename:"Levy_GPW_system.csv"
})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"Great Power Wars Participation",
  version:toFloat(1.0),
  published:date({year:1994, month:4}),
  note:"This data file represents this author's recreation of J. Levy's data from ICPSR 09955-0001-Codebook.txt and GESIS ZA9119.dta files.",
  purpose:"Identify the dates at which great powers began and finished wars. One line per power, per entry/exit, per war.",
  url:["https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/9955","https://dbk.gesis.org/dbksearch/sdesc2.asp?no=8119&db=e&doi=10.4232/1.8119"],   
  filename:"Levy_GPW_participation_data.csv"
})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"Great Power Wars",
  version:toFloat(1.0),
  published:date({year:1994, month:4}),
  note:"This data file represents this author's recreation of J. Levy's data from ICPSR 09955-0001-Codebook.txt and GESIS ZA9119.dta files.",
  purpose:"Data about each war that was fought between the great powers.",
  url:["https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/9955","https://dbk.gesis.org/dbksearch/sdesc2.asp?no=8119&db=e&doi=10.4232/1.8119"],   
  filename:"Levy_GPW_war_data.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Great Power Wars Codebook",
  version:toFloat(1.0),
  published:date({year:1994, month:4}),
  note:"Text document that contains the bulk of Levy's great power war data.",
  purpose:"Document and describe the war data, including bibliographic sources for each war.",
  url:"https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/9955/datadocumentation",
  filename:"09955-0001-Codebook.txt"
});


// Following the model described above, my graph schema for the Levy Great Power system looks like this:
//
// (PC)-[:ASSERTS{asOf:date()}]->(:Fact{from, until})<-[:MEMBER]-(state:State)
//                                                   \-[:MEMBER_OF]-(system:System)<-[:DEFINES]-(source:Source)

MATCH (source:Source{name:"Levy Great Power Wars"})
CREATE (source)-[:DEFINES {
  asOf:date({year:1994, month:4})
  }]->(:System {
    name:"Great Power System", scope:"Global", 
    from:date({year:1495, month:1, day:1}),
    until:date({year:1815, month:12, day:31})
  });

CREATE CONSTRAINT ON (gp:GreatPower) ASSERT gp.levycode IS UNIQUE;

// Identify the members of the system and when they were members
MATCH (gp:System{name:"Great Power System"})
MATCH (df:Dataset{filename:"Levy_GPW_system.csv"})
LOAD CSV WITH HEADERS FROM "file:///Levy_GPW_system.csv" AS row
MERGE (state:GreatPower{
  name:row.State,
  levycode:row.levyStNum
})
CREATE (df)-[:CONTRIBUTES{asOf:date({year:1994, month:4})}]->(f:Fact{
  name:"System Membership",
  source:"Levy Great Power Wars",
  from:date({year:toInteger(row.GreatPowerFrom)}),
  until:date({year:toInteger(row.GreatPowerTo)})
})
MERGE (state)-[:MEMBER]->(f)-[:MEMBER_OF]->(gp)
FOREACH (specific IN CASE WHEN trim(row.cowcode) <> "" THEN [1] ELSE [] END | SET state.cowRelation = row.cowcode);
RETURN "Successfully imported the 1st file, Levy_GPW_system.csv";

// End of Levy_GPW_system.csv


// Levy differentiates begin/end of wars and begin/end of wars as GPW; wars have a from/until as GPW which may be 
// different than the first from/until of states' participation in it. There are multiple facts: when the war was a
// GPW, when each state participated in the war. 
// The model looks like this:
//
// (PC)-[:CONTRIBUTES]->(:Fact)<-[:PARTICIPATED]-(state)
//    \-[:CONTRIBUTES]        \--[:PARTICIPATED_IN]->(war:War:GreatPowerWar)
//                \->(:Fact)<--[:IN_LIST]----------/
//                         \-[:ONE_OF]->(:List{name:"Great Power Wars"})

CREATE CONSTRAINT ON (war:War) ASSERT war.levycode IS UNIQUE;

MATCH (source:Source{name:"Levy Great Power Wars"})
CREATE (source)-[:DEFINES]->(g:List{name:"Great Power Wars"})
CREATE (source)-[:DEFINES]->(w:List{name:"Wars"})
WITH g, w
MATCH (d:Dataset{filename:"Levy_GPW_war_data.csv"})
LOAD CSV WITH HEADERS FROM "file:///Levy_GPW_war_data.csv" AS row
CREATE (war:War:GreatPowerWar{
  levycode:row.warnum,
  name:row.warname,
  description:row.factName,
  numParticipants:toInteger(row.extent),
  durationMonths:toFloat(row.durwar),
  participantMonths:toFloat(row.magnitud),
  magnitude:toFloat(row.severity),
  concentration:toFloat(row.concent)
})
CREATE (d)-[:CONTRIBUTES]->(gf:Fact{
  name:"Great Power War",
  from:date({year:toInteger(row.ybegan), month:toInteger(row.mthbegan)}),
  until:date({year:toInteger(row.yrend), month:toInteger(row.mthend)}) 
  })-[wo:ONE_OF]->(w)
CREATE (d)-[:CONTRIBUTES]->(wf:Fact{
  name:"War",
  from:date({year:toInteger(row.yrgpw), month:toInteger(row.mthgpw)}),
  until:date({year:toInteger(trim(row.yrgpwe)), month:toInteger(trim(row.mthgpwe))})
  })-[go:ONE_OF]->(g)
FOREACH (specific IN CASE WHEN trim(row.daybegan) <> "" THEN [1] ELSE [] END | SET wf.from = date({year:toInteger(row.ybegan), 
  month:toInteger(row.mthbegan), day:toInteger(row.daybegan)}))
FOREACH (specific IN CASE WHEN trim(row.dayend) <> "" THEN [1] ELSE [] END | SET wf.until = date({year:toInteger(row.yrend), 
  month:toInteger(row.mthend), day:toInteger(row.dayend)}))
FOREACH (specific IN CASE WHEN trim(row.daygpw) <> "" THEN [1] ELSE [] END | SET gf.from = date({year:toInteger(row.yrgpw), 
  month:toInteger(row.mthgpw), day:toInteger(row.daygpw)}))
FOREACH (specific IN CASE WHEN trim(row.daygpwe) <> "" THEN [1] ELSE [] END | SET gf.until = date({year:toInteger(row.yrgpwe), 
  month:toInteger(row.mthgpwe), day:toInteger(row.daygpwe)}))
CREATE (war)-[:IN_LIST]->(gf)
CREATE (war)-[:IN_LIST]->(wf);

MATCH (d:Dataset{filename:"Levy_GPW_war_data.csv"})-[:CONTRIBUTES]->(f:Fact), (w:Week)
WHERE w.began <= f.from <= w.ended
MERGE (f)-[:FROM_WEEK]->(w);

MATCH (d:Dataset{filename:"Levy_GPW_war_data.csv"})-[:CONTRIBUTES]->(f:Fact), (w:Week)
WHERE w.began <= f.until <= w.ended 
MERGE (f)-[:UNTIL_WEEK]->(w);

RETURN "Initial load of Levy Levy_GPW_war_data is complete.";

// Levy war participation (when GPs participated in wars)
MATCH (d:Dataset{filename:"Levy_GPW_participation_data.csv"})
LOAD CSV WITH HEADERS FROM "file:///Levy_GPW_participation_data.csv" AS row
WITH d, row
MATCH (war:War{levycode:row.warnum})
CREATE (d)-[:CONTRIBUTES]->(p:Fact{name:"Participation",
  from:date({year:toInteger(row.ybegan), month:toInteger(row.mthbegan), day:toInteger(row.daybegan)}),
  until:date({year:toInteger(row.yrend), month:toInteger(row.mthend), day:toInteger(row.dayend)}),
  durationMonths:toFloat(row.durwar),
  magnitude:toFloat(row.severity),
  concentration:toFloat(row.concent)
  })-[:PARTICIPATED_IN]->(war)
WITH p, row
MATCH (state:GreatPower{levycode:row.stnum})
MERGE (state)-[:PARTICIPATED]->(p);

// end Levy_GPW_participation_data.csv
RETURN "Successfully imported the 3rd file, Levy_GPW_participation_data.csv";
// end Levy source
RETURN "All of the Levy data has been imported into the graph.";

// ####################################################################################################################
// The states2016.csv data is actually a more appropriate file to describe the state system (membership)
// than the system2016.csv because it contains duration data that imply the system during that time period.

// COW State System dataset
CREATE (d:Source{
  project:"Correlates of War", 
  name:"State System Membership", 
  version:toInteger(2016),
  published:date({year:2017, month:2, day:27}),
  validFrom:date({year:1816, month:1, day:1}),
  validUntil:date({year:2016, month:12, day:31}),
  citation:"Correlates of War Project. 2017.'State System Membership List, v2016'. Online, http://correlatesofwar.org'",
  url:"http://correlatesofwar.org/data-sets/state-system-membership",
  host:["Volker Krause (Eastern Michigan University)", "Phil Schafer (University of Michigan)", "Karen Ruth Adams (University of Montana)"],
  poc:"Volker Krause (vkrause@emich.edu)",
  overview:"This data set contains the list of states in the international system as updated and distributed by the Correlates of War Project. These data sets identify states, their standard Correlates of War 'country code' or state number (used throughout the Correlates of War project data sets), state abbreviations, and dates of membership as states and major powers in the international system. Version 2016 extends the temporal domain of the collection through December 2016. \nThe Correlates of War project includes a state in the international system from 1816-2016 for the following criteria. Prior to 1920, the entity must have had a population greater than 500,000 and have had diplomatic missions at or above the rank of charge d’affaires with Britain and France. After 1920, the entity must be a member of the League of Nations or the United Nations, or have a population greater than 500,000 and receive diplomatic missions from two major powers.",
  purpose:"This data set records the fluctuating composition of the state system since 1816. It also identifies countries corresponding to the standard Correlates of War country codes."
  })
CREATE (d)-[:PROVIDES]->(:File{
  name:"State System Codebook",
  version:toInteger(2016),
  published:date({year:2017, month:2, day:27}),
  purpose:"Describes the content and formate of the data, and provides details of the operational criteria for state system membership.",
  url:"http://correlatesofwar.org/data-sets/state-system-membership/state-system-v2016-codebook/at_download/file",
  filename:"State System Membership Codebook V2016.pdf",
  bytesize:toInteger(93891)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"State System FAQ",
  version:toInteger(2016),
  published:date({year:2017, month:2, day:27}),
  purpose:"Contains answers to some FAQs about the state system membership datasets",
  url:"http://correlatesofwar.org/data-sets/state-system-membership/state-system-v2016-faq/at_download/file",
  filename:"State FAQ.pdf",
  bytesize:toInteger(92385)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"States 2016",
  version:toInteger(2016),
  published:date({year:2017, month:2, day:27}),
  purpose:"Provides the entry and exit dates of states, country codes, and abbreviations.",
  url:"http://correlatesofwar.org/data-sets/state-system-membership/states2016/at_download/file",
  filename:"states2016.csv",
  bytesize:toInteger(10845)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Majors 2016",
  version:toInteger(2016),
  published:date({year:2017, month:2, day:27}),
  purpose:"Provides the entry and exit dates for states to be designated as major powers.",
  url:"http://correlatesofwar.org/data-sets/state-system-membership/majors2016/at_download/file",
  filename:"majors2016.csv",
  bytesize:toInteger(539)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"System 2016",
  version:toInteger(2016),
  published:date({year:2017, month:2, day:27}),
  purpose:"Gives the composition of the state system year by year (providing a blank country-year dataset).",
  url:"http://correlatesofwar.org/data-sets/state-system-membership/system2016/at_download/file",
  filename:"system2016.csv",
  bytesize:toInteger(300836)
});

// Identify the system and graph the relationship to the source.
MATCH (so:Source{project:"Correlates of War", name:"State System Membership", version:2016})
CREATE (so)-[:DEFINES{
  asOf:date({year:2017, month:2, day:27})
  }]->(system:System {
    name:"COW State System",
    scope:"Global",
    from:date({year:1816, month:1, day:1}),
    until:date({year:2016, month:12, day:31})
  });

// (PC)-[:CONTRIBUTES{asOf:date()}]->(:Fact{from, until})<-[:MEMBER]-(state:State)
//                                                      \-[:MEMBER_OF]-(system:System)
// Finally, load the data file and graph the relationship of the states to it and the system
CREATE CONSTRAINT ON (st:State) ASSERT st.cowcode IS UNIQUE;

MATCH (d:Dataset{filename:"states2016.csv"}), (y:System{name:"COW State System"})
LOAD CSV WITH HEADERS FROM "file:///states2016.csv" AS row
WITH d, y, row
MERGE (d)-[:CONTRIBUTES{asOf:d.published}]->(f:Fact{
  name:"System Membership",
  from:date({year:toInteger(row.styear), month:toInteger(row.stmonth), day:toInteger(row.stday)}),
  until:date({year:toInteger(row.endyear), month:toInteger(row.endmonth), day:toInteger(row.endday)})
  })-[:MEMBER_OF]->(y)
MERGE (state:State{
    cowcode:row.ccode,
    abb:row.stateabb,
    name:row.statenme})
CREATE (state)-[:MEMBER]->(f);
// Relate Levy's Great Powers to the COW states they became, where appropriate.

MATCH (gp:GreatPower), (s:State) 
WHERE gp.cowRelation = s.cowcode
WITH gp, s
MERGE (gp)-[:BECAME]->(s)
SET gp:State;
// End of states2016.csv

RETURN "Successfully imported the 4th file and the first of the COW datasets, states2016.csv";

// Some states are major powers in the COW state system
MATCH (so:Source{project:"Correlates of War", name:"State System Membership", version:2016})
CREATE (so)-[:DEFINES {
  asOf:date({year:2017, month:2, day:27})
  }]->(mp:System:Subsystem {
    name:"COW Major Powers System", 
    scope:"Global",
    from:date({year:1816, month:1, day:1}),
    until:date({year:2016, month:12, day:31})
  });

MATCH (sy:System {name:"COW State System"})
MATCH (mp:Subsystem {name:"COW Major Powers System"})
MERGE (mp)-[:PART_OF]->(sy);

MATCH (maj:Dataset{filename:"majors2016.csv"}), (sys:System{name:"COW Major Powers System"})
LOAD CSV WITH HEADERS FROM "file:///majors2016.csv" AS row
CREATE (maj)-[:CONTRIBUTES]->(f:Fact{
  from:date({year:toInteger(row.styear), month:toInteger(row.stmonth), day:toInteger(row.stday)}),
  until:date({year:toInteger(row.endyear), month:toInteger(row.endmonth), day:toInteger(row.endday)})
  })-[:MEMBER_OF]->(sys)
WITH f, row
MATCH (state:State{cowcode:row.ccode})
MERGE (state)-[:MEMBER]-(f);
// End of majors2016.csv

RETURN "Successfully imported the 5th (second COW) file, majors2016.csv";
// End COW state system membership source

// @Test
// MATCH (o:Source)-[p:PROVIDES]->(f:Dataset)-[c:CONTRIBUTES]->(t:Fact)<-[:MEMBER]-(s:State)
// MATCH (t)-[m:MEMBER-OF]->(y:System)<-[d:DEFINES]-(o) RETURN o,p,f,c,t,a,s,m,y,d 
// MATCH (n:Source) UNWIND n.host as x WITH n, x WHERE x CONTAINS "Krause" RETURN x, n


// Begin Diplomatic Exchange data
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Diplomatic Exchange", 
  version:toFloat(2016.1),
  published:date({year:2007, month:5, day:18}),
  validFrom:date({year:1817, month:1, day:1}),
  falidUntil:date({year:2005, month:12, day:31}),
  citation:"Bayer, Reşat. 2006. 'Diplomatic Exchange Data set, v2006.1.' Online: http://correlatesofwar.org",
  host:"Reşat Bayer (Koç University)",
  url:"http://correlatesofwar.org/data-sets/formal-alliances",
  overview:"The Correlates of War Diplomatic Exchange data set captures diplomatic representation at the level of chargé d'affaires, minister, and ambassador between members of the Correlates of War interstate system. The 2006 version of the data set includes information for the following years:  1817, 1824, 1827, 1832, 1836, 1840, every five years between 1844 and 1914, every five years between 1920 and 1940, and every five years between 1950 and 2005. The dyadic data describe the level of diplomatic representation and diplomatic exchange between members in the COW system.",
  purpose:"The Diplomatic Exchange data set tracks diplomatic representation at the level of chargé d'affaires, minister, and ambassador between states from 1817-2005."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Diplomatic Exchange Data",
  version:toFloat(2016.1),
  published:date({year:2007, month:5, day:18}),
  purpose:"Data of diplomatic exchange",
  url:"http://correlatesofwar.org/data-sets/diplomatic-exchange/diplomatic-exchange-v2006-1-data/at_download/file",
  filename:"Diplomatic_Exchange_2006v1.csv",
  bytesize:toInteger(12037213)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Diplomatic Exchange codebook",
  version:toFloat(2016.1),
  published:date({year:2007, month:5, day:18}),
  purpose:"Documentation of data.",
  url:"http://correlatesofwar.org/data-sets/diplomatic-exchange/diplomatic-exchange-codebook/at_download/file",
  filename:"Diplomatic_Exchange_2006v1_codebook.pdf",
  bytesize:toInteger(78806)
});


// The Diplomatic Exchange dataset added 621640 labels, created 621640 nodes, set 3108200 properties, 
// created 2486560 relationships. It can take a long time. On my machine, it completed after 145788 ms.
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///Diplomatic_Exchange_2006v1.csv" AS row
WITH row,
CASE row.DR_at_1
  WHEN "0" THEN "No evidence of diplomatic exchange"
  WHEN "1" THEN "chargé d'affaires"
  WHEN "2" THEN "ambassador"
  ELSE "other" END AS dr1,
CASE row.DR_at_2
  WHEN "0" THEN "No evidence of diplomatic exchange"
  WHEN "1" THEN "chargé d'affaires"
  WHEN "2" THEN "ambassador"
  ELSE "other" END AS dr2 
MATCH (s1:State{cowcode:row.ccode1}),(s2:State{cowcode:row.ccode2}), (d:Dataset{name:"Diplomatic Exchange Data"}),(y:Year{name:row.year})
CREATE (d)-[:CONTRIBUTES]->(f1:Fact{
  name:"Diplomatic Exchange",
  version:toFloat(row.version),
  year:date({year:toInteger(row.year)}),
  code:toInteger(row.DR_at_1),
  level:dr1
  })-[:REPRESENTED_AT]->(s2)
CREATE (d)-[:CONTRIBUTES]->(f2:Fact{
  name:"Diplomatic Exchange",
  version:toFloat(row.version),
  year:date({year:toInteger(row.year)}),
  code:toInteger(row.DR_at_2),
  level:dr2
  })-[:REPRESENTED_AT]->(s1)
CREATE (s1)-[r1:REPRESENTED]->(f1)-[:DURING]->(y)
CREATE (s2)-[r2:REPRESENTED]->(f2)-[:DURING]->(y);
// End of the Dip Ex data
RETURN "Successfully loaded the 6th (third COW) file, Diplomatic_Exchange_2006v1";


// Trade, which is kind of huge, so be patient...
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Trade", 
  version:toFloat(4.0),
  published:date({year:2017, month:2, day:20}),
  validFrom:date({year:1870, month:1, day:1}),
  falidUntil:date({year:2014, month:12, day:31}),
  citation:["Barbieri, Katherine and Omar M. G. Omar Keshk. 2016. Correlates of War Project Trade Data Set Codebook, Version 4.0. Online: http://correlatesofwar.org", "Barbieri, Katherine, Omar M. G. Keshk, and Brian Pollins. 2009. 'TRADING DATA: Evaluating our Assumptions and Coding Rules.' Conflict Management and Peace Science. 26(5): 471-491."],
  host:["Katherine Barbieri (University of South Carolina)", "Omar Keshk (Ohio State University)"],
  poc:"Douglas Gibler (dmgibler@bama.ua.edu)",
  url:"http://correlatesofwar.org/data-sets/bilateral-trade",
  overview:"The Correlates of War Formal Alliance data set seeks to identify each formal alliance between at least two states that fall into the classes of defense pact, neutrality or non-aggression treaty, or entente agreement. A defense pact (Type I) is the highest level of military commitment, requiring alliance members to come to each other’s aid militarily if attacked by a third party. As the labels imply, neutrality and non-aggression pacts (Type II) pledge signatories to either remain neutral in case of conflict or to not use or otherwise support the use of force against the other alliance members. Finally, ententes (Type III) provide for the least commitment and obligate members to consult in times of crisis or armed attack. Each alliance classifies the highest level of military support that an alliance member pledges to another alliance member. The data set provides the type, members, and appropriate dates of activity of each identified alliance. \nVersion 4.1 of the alliance data expands the original Singer and Small (1966) deffinitions of alliance types to include neutrality and non-aggression pacts separately. Neutrality pacts are now labeled as Type IIa alliances, and Non-Aggression pacts are labeled as Type IIb alliances. Alliance terms also distinguish between neutrality and non-aggression in the dyadic data. \nIn addition, the fourth version now differentiates between the overall alliance type and the terms of the alliance by specific member. In the alliance member list of data, for example, both the Singer and Small (1966) alliance type and the specific terms by alliance member are included. Only the terms operational for the specific dyad are included in the dyadic and direct-dyad data.",
  purpose:"You are here: Home / Data Sets / Trade (v4.0)
Trade (v4.0)
This data set tracks total national trade and bilateral trade flows between states from 1870-2014. This data set is hosted by Katherine Barbieri, University of South Carolina, and Omar Keshk, Ohio State University."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Dyadic Trade",
  version:toFloat(4.0),
  published:date({year:2017, month:2, day:20}),
  purpose:"Bilateral trade flow data",
  url:"http://correlatesofwar.org/data-sets/bilateral-trade/cow_trade_4.0/at_download/file",
  filename:"Dyadic_COW_4.0.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"National Trade",
  version:toFloat(4.0),
  published:date({year:2017, month:2, day:20}),
  purpose:"National import and export data.",
  url:"http://correlatesofwar.org/data-sets/bilateral-trade/cow_trade_4.0/at_download/file",
  filename:"National_COW_4.0.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Trade Codebook",
  version:toFloat(4.0),
  published:date({year:2017, month:2, day:20}),
  purpose:"Codebook discussing file format, procedures, descriptive statistics, and references",
  url:"http://correlatesofwar.org/data-sets/bilateral-trade/cow_trade_4.0/at_download/file",
  filename:"COW Trade Data Set Codebook.pdf"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Dyadic Trade Supplement",
  version:toFloat(3.0),
  published:date({year:2012, month:2}),
  purpose:"Supplementary source and other information on dyadic trade flows",
  url:"http://correlatesofwar.org/data-sets/bilateral-trade/cow_trade_supplements/at_download/file",
  filename:"dyadic_trade_supplement.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"National Trade and Exchange Rate Supplement",
  version:toFloat(3.0),
  published:date({year:2012, month:2}),
  purpose:"Supplementary source and other information on national trade and exchange rate statistics",
  url:"http://correlatesofwar.org/data-sets/bilateral-trade/cow_trade_supplements/at_download/file",
  filename:"national_trade_and_exchange_rate_supplement.csv"
});

// National Trade data
//      /-[:CONTRIBUTES]->(:Fact)<-[:EXPORTS]-(:State)
//     /                         \-[:DURING]
// (PC)         /-------->(:Year)<--------/
//    \        [:DURING]-\
//     \-[:CONTRIBUTES]->(:Fact)<-[:IMPORTS]-(:State)
//

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///National_COW_4.0.csv" AS row
MATCH (y:Year{began:date({year:toInteger(row.year)})}), (s:State{cowcode:row.ccode}),(f:Dataset{filename:"National_COW_4.0.csv"})
WITH *,
CASE row.source1
  WHEN "-9" THEN "Missing data"
  WHEN "1.1" THEN "Belgium/Luxembourg total import values"
  WHEN "2" THEN "IMF 2015 trade values"
  WHEN "3" THEN "Missing values replaced with reported World Values"
  WHEN "4" THEN "Zero values replaced with missing values"
END AS isource,
CASE row.source2
  WHEN "-9" THEN "Missing data"
  WHEN "1.1" THEN "Belgium/Luxembourg total import values"
  WHEN "2" THEN "IMF 2015 trade values"
  WHEN "3" THEN "Missing values replaced with reported World Values"
  WHEN "4" THEN "Zero values replaced with missing values"
END AS esource
CREATE (d)-[ic:CONTRIBUTES]->(if:Fact{name:"Total Imports"})-[:DURING]->(y)
CREATE (s)-[:IMPORTS]->(if)
CREATE (d)-[ec:CONTRIBUTES]->(ef:Fact{name:"Total Exports"})-[:DURING]->(y)
CREATE (s)-[:EXPORTS]->(ef)
SET ic.source = isource
SET ec.source = esource
WITH if, ef, ic, ec, row
FOREACH (val IN CASE WHEN row.imports<>"-9" THEN [1] ELSE [] END | SET if.totalImports = row.imports )
FOREACH (val IN CASE WHEN row.alt_imports<>"-9" THEN [1] ELSE [] END | SET if.altImports = row.alt_imports )
FOREACH (val IN CASE WHEN row.version<>"" THEN [1] ELSE [] END | SET ic.version = row.version)
FOREACH (val IN CASE WHEN row.exports<>"-9" THEN [1] ELSE [] END | SET ef.totalExports = row.exports ) 
FOREACH (val IN CASE WHEN row.alt_exports<>"-9" THEN [1] ELSE [] END | SET ef.altExports = row.alt_exports ) 
FOREACH (val IN CASE WHEN row.version<>"" THEN [1] ELSE [] END | SET ec.version = row.version);

RETURN "Successfully imported National Trade data";

// Dyadic Trade data
// This file is also quite large and caches a lot of data (all the states, twice). It produces  
// ccode1,ccode2,year,importer1,importer2,flow1,flow2,smoothflow1,smoothflow2,smoothtotrade,spike1,spike2,dip1,dip2,
// trdspike,tradedip,bel_lux_alt_flow1,bel_lux_alt_flow2,china_alt_flow1,china_alt_flow2,source1,source2,version
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///Dyadic_COW_4.0.csv" AS row
MATCH (y:Year{name:row.year}),(s1:State{cowcode:row.ccode1}),
  (s2:State{cowcode:row.ccode2}),(d:Dataset{filename:"Dyadic_COW_4.0.csv"})
CREATE (d)-[c1:CONTRIBUTES]->(f1:Fact{name:"Import", currency:"Millions in 2017 USD"})-[:IMPORTED_FROM]->(s2)
MERGE (s1)-[:IMPORTED]->(f1)-[:DURING]->(y)
CREATE (d)-[c2:CONTRIBUTES]->(f2:Fact{name:"Import", currency:"Millions in 2017 USD"})-[:IMPORTED_FROM]->(s1)
MERGE (s2)-[:IMPORTED]->(f2)-[:DURING]->(y)
WITH *,
CASE row.source1
  WHEN "-9" THEN "Missing data"
  WHEN "1" THEN "Barbieri Version 1 (see 2002 Appendix A)"
  WHEN "2" THEN "Hicks (2015) Imports of State A from State B, Importer's report"
  WHEN "2.01" THEN "Revised Hicks Imports (Hicks Trade, Alternative exchange rates)"
  WHEN "2.1" THEN "Hicks (2015) Exporter's report of Flow 1"
  WHEN "2.11" THEN "Revised Hicks Exporter's report"
  WHEN "3" THEN "IMF import reports (2015)"
  WHEN "4" THEN "Missing import values replaced with IMF exporter's trade figure"
  WHEN "5" THEN "Zero trade values replaced with IMF's exporter's trade (2015)"
  WHEN "6" THEN "Missing COW 4.0 values replaced with COW 3.0 data"
END AS so1comment,
CASE row.source2
  WHEN "-9" THEN "Missing data"
  WHEN "1" THEN "Barbieri Version 1 (see 2002 Appendix A)"
  WHEN "2" THEN "Hicks (2015) Imports of State A from State B, Importer's report"
  WHEN "2.01" THEN "Revised Hicks Imports (Hicks Trade, Alternative exchange rates)"
  WHEN "2.1" THEN "Hicks (2015) Exporter's report of Flow 1"
  WHEN "2.11" THEN "Revised Hicks Exporter's report"
  WHEN "3" THEN "IMF import reports (2015)"
  WHEN "4" THEN "Missing import values replaced with IMF exporter's trade figure"
  WHEN "5" THEN "Zero trade values replaced with IMF's exporter's trade (2015)"
  WHEN "6" THEN "Missing COW 4.0 values replaced with COW 3.0 data"
END AS so2comment
SET c1.source = so1comment
SET c2.source = so2comment
WITH c1,c2,f1,f2,row
FOREACH (val IN CASE WHEN row.flow1<>"-9" THEN [1] ELSE [] END | SET f1.value = row.flow1)
FOREACH (val IN CASE WHEN row.flow2<>"-9" THEN [1] ELSE [] END | SET f2.value = row.flow2)
FOREACH (val IN CASE WHEN row.smoothflow1<>"-9" THEN [1] ELSE [] END | SET f1.smoothedValue = row.smoothflow1)
FOREACH (val IN CASE WHEN row.smoothflow2<>"-9" THEN [1] ELSE [] END | SET f2.smoothedValue = row.smoothflow2)
FOREACH (val IN CASE WHEN row.spike1<>"-9" THEN [1] ELSE [] END | SET f1.spike = row.spike1)
FOREACH (val IN CASE WHEN row.spike2<>"-9" THEN [1] ELSE [] END | SET f2.spike = row.spike2)
FOREACH (val IN CASE WHEN row.dip1<>"-9" THEN [1] ELSE [] END | SET f1.dip = row.dip1)
FOREACH (val IN CASE WHEN row.dip2<>"-9" THEN [1] ELSE [] END | SET f2.dip = row.dip2)
FOREACH (val IN CASE WHEN row.china_alt_flow1<>"-9" THEN [1] ELSE [] END | SET f1.altValue4China = row.china_alt_flow1)
FOREACH (val IN CASE WHEN row.china_alt_flow2<>"-9" THEN [1] ELSE [] END | SET f2.altValue4China = row.china_alt_flow2)
FOREACH (val IN CASE WHEN row.bel_lux_alt_flow1<>"-9" THEN [1] ELSE [] END | SET f1.altValue4BelLux = row.bel_lux_alt_flow1)
FOREACH (val IN CASE WHEN row.bel_lux_alt_flow2<>"-9" THEN [1] ELSE [] END | SET f2.altValue4BelLux = row.bel_lux_alt_flow2)
FOREACH (val IN CASE WHEN row.smoothtotrade<>"-9" THEN [1] ELSE [] END | 
  SET f1.smoothedTotalTrading = row.smoothtotrade
  SET f2.smoothedTotalTrading = row.smoothtotrade )
FOREACH (val IN CASE WHEN row.trdspike<>"-9" THEN [1] ELSE [] END | 
  SET f1.tradeSpike = row.trdspike
  SET f2.tradeSpike = row.trdspike )
FOREACH (val IN CASE WHEN row.tradedip<>"-9" THEN [1] ELSE [] END | 
  SET f1.tradeDip = row.tradedip
  SET f2.tradeDip = row.tradedip )
FOREACH (val IN CASE WHEN row.version<>"-9" THEN [1] ELSE [] END | 
  SET c1.version = row.version
  SET c2.version = row.version );
// Complete Trade
RETURN "Trade is complete";

// ####################################################################################################################
// National Military Capabilities Data
CREATE (d:Source{
  project:"Correlates of War", 
  name:"NMC", 
  version:toFloat(5.0),
  published:date({year:2017, month:2, day:1}),  
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2012, month:12, day:31}),
  citation:["Singer, J. David, Stuart Bremer, and John Stuckey. (1972). 'Capability Distribution, Uncertainty, and Major Power War, 1820-1965.' in Bruce Russett (ed) Peace, War, and Numbers, Beverly Hills: Sage, 19-48.","Singer, J. David. 1987. 'Reconstructing the Correlates of War Dataset on Material Capabilities of States, 1816-1985' International Interactions, 14: 115-32."],
  url:"http://correlatesofwar.org/data-sets/national-material-capabilities",
  host:["J. Michael Greig (University of North Texas)", "Andrew J. Enterline (University of North Texas)"],
  poc:["J. Michael Greig (greig@unt.edu)", "Andrew J. Enterline (ajenter@unt.edu)"],
  overview:"The National Material Capabilities data set contains annual values for total population, urban population, iron and steel production, energy consumption, military personnel, and military expenditure of all state members, currently from 1816-2012. The widely-used Composite Index of National Capability (CINC) index is based on these six variables and included in the data set.",
  purpose:"Power is considered by many to be a central concept in explaining conflict, and six indicators - military expenditure, military personnel, energy consumption, iron and steel production, urban population, and total population - are included in this data set. It serves as the basis for the most widely used indicator of national capability, CINC (Composite Indicator of National Capability) and covers the period 1816-2012."
  })
CREATE (d)-[:PROVIDES]->(:File{
  name:"NMC Codebook",
  version:toFloat(5.0),
  published:date({year:2017, month:2, day:1}),  
  purpose:"The codebook for version 5.0 of the data identifying the variables, variable order, and format of the data set.",
  url:"http://correlatesofwar.org/data-sets/national-material-capabilities/nmc-codebook-v5-1/at_download/file",
  filename:"NMC_Documentation_v5_0.pdf",
  bytesize:toInteger(1744940)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"NMC Abriged",
  version:toFloat(5.0),
  published:date({year:2017, month:2, day:1}),  
  purpose:"Contains the CINC scores and the six indicators",
  url:"http://correlatesofwar.org/data-sets/national-material-capabilities/nmc-v5-1/at_download/file",
  filename:"NMC_5_0.csv",
  bytesize:toInteger(565702)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"NMC Supplemental",
  version:toFloat(5.0),
  published:date({year:2017, month:2, day:1}),  
  purpose:"Includes data and sources for data",
  url:"http://correlatesofwar.org/data-sets/national-material-capabilities/nmc-v5-supplemental/at_download/file",
  filename:"NMC_5_0-wsupplementary.csv",
  bytesize:toInteger(2076344)
});

// Begin National Military Capabilities with Supplemental data
LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
WITH row,
CASE WHEN toInteger(row.milex)="-9" OR row.milex='' THEN "UNK" ELSE toInteger(row.milex) END AS myMilex,
CASE WHEN row.milexsource='' THEN "Not provided" ELSE row.milexsource END AS myMilexSource,
CASE WHEN row.milexnote='' THEN "Not provided" ELSE row.milexnote END AS myMilexNote,
CASE WHEN toInteger(row.year) < 1914 THEN row.year + " GBP, thousands" ELSE row.year + " USD, thousands" END AS denom
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[h:MILEX{
  definition:"Military expenditures are measured in thousands of current-year British Pounds from 1816 until 1913 and in thousands of current-year US Dollars from 1914 onward"
}]->(f:Fact{
  name:"Military Expenditures",
  value:myMilex,
  denomination:denom,
  dataSource:myMilexSource,
  notes:myMilexNote
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 1";

LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
WITH row,
CASE WHEN toInteger(row.milper)=-9 OR row.milper='' THEN "UNK" ELSE toInteger(row.milper) END AS mymilper,
CASE WHEN row.milpersource='' THEN "Not provided" ELSE row.milpersource END AS mymilpersource,
CASE WHEN row.milpernote='' THEN "Not provided" ELSE row.milpernote END AS mymilpernote
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[:MILPER{definition:"Thousands of military personnel."}]->(f:Fact{
  name:"Military PAX",
  value:mymilper,
  denomination:"thousand PAX",
  dataSource:mymilpersource,
  notes:mymilpernote
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 2";

LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
WITH row,
CASE WHEN toInteger(row.irst)=-9 OR row.irst='' THEN "UNK" ELSE toInteger(row.irst) END AS myirst,
CASE WHEN row.irstsource='' THEN "Not provided" ELSE row.irstsource END AS myirstSource,
CASE WHEN row.irstnote='' THEN "Not provided" ELSE row.irstnote END AS myirstNote,
CASE WHEN row.irstqualitycode='' THEN "Not provided" ELSE row.irstqualitycode END AS myirstQC,
CASE WHEN row.irstanomalycode='' THEN "Not provided" ELSE row.irstanomalycode END AS myirstAC
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[:IRON_STEEL_PRODUCTION{definition:"Iron and Steel Production"}]->(f:Fact{
  name:"Iron and Steel Production",
  value:myirst,
  denomination:"thousands of tons",
  dataSource:myirstSource,
  notes:myirstNote,
  quality:myirstQC,
  anomaly:myirstAC
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 3";

LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
WITH row,
CASE WHEN toInteger(row.pec)=-9 OR row.pec='' THEN "UNK" ELSE toInteger(row.pec) END AS mypec,
CASE WHEN row.pecsource='' THEN "Not provided" ELSE row.pecsource END AS mypecSource,
CASE WHEN row.pecnote='' THEN "Not provided" ELSE row.pecnote END AS mypecNote,
CASE WHEN row.pecqualitycode='' THEN "Not provided" ELSE row.pecqualitycode END AS mypecQC,
CASE WHEN row.pecanomalycode='' THEN "Not provided" ELSE row.pecanomalycode END AS mypecAC
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[:PETROL_CONSUMPTION{definition:"Primary Energy Consumption"}]->(f:Fact{
  name:"Energy Consumption",
  value:mypec,
  denomination:"thousands of coal-ton equivalents",
  dataSource:mypecSource,
  notes:mypecNote,
  quality:mypecQC,
  anomaly:mypecAC
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 4";

LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
WITH row,
CASE WHEN toInteger(row.tpop)=-9 OR row.tpop='' THEN "UNK" ELSE toInteger(row.tpop) END AS mytpop,
CASE WHEN row.tpopsource='' THEN "Not provided" ELSE row.tpopsource END AS mytpopSource,
CASE WHEN row.tpopnote='' THEN "Not provided" ELSE row.tpopnote END AS mytpopNote,
CASE WHEN row.tpopqualitycode='' THEN "Not provided" ELSE row.tpopqualitycode END AS mytpopQC,
CASE WHEN row.tpopanomalycode='' THEN "Not provided" ELSE row.tpopanomalycode END AS mytpopAC
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[:POPULATION {definition:"Total Population"}]->(f:Fact{
  name:"Total Population",
  value:mytpop,
  denomination:"thousands of persons",
  dataSource:mytpopSource,
  notes:mytpopNote,
  quality:mytpopQC,
  anomaly:mytpopAC
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 5";

LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
WITH row,
CASE WHEN toInteger(row.upop)=-9 OR row.upop='' THEN "UNK" ELSE toInteger(row.upop) END AS myupop,
CASE WHEN row.upopsource='' THEN "Not provided" ELSE row.upopsource END AS myupopSource,
CASE WHEN row.upopnote='' THEN "Not provided" ELSE row.upopnote END AS myupopNote,
CASE WHEN row.upopqualitycode='' THEN "Not provided" ELSE row.upopqualitycode END AS myupopQC,
CASE WHEN row.upopanomalycode='' THEN "Not provided" ELSE row.upopanomalycode END AS myupopAC,
CASE WHEN row.upopgrowth='' THEN "Not provided" ELSE toFloat(row.upopsource) END AS myupopgrowth,
CASE WHEN row.upopgrowthsource='' THEN "Not provided" ELSE row.upopgrowthsource END AS myupopgrowthSource,
CASE WHEN toInteger(row.year) < 2012 THEN "Population in cities >= 100K population" ELSE "Population in cities >= 300K population" END AS def
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[:URBAN_POPULATION{definition:def}]->(f:Fact{
  name:"Urban Population",
  value:myupop,
  denomination:"population in thousands",
  dataSource:myupopSource,
  notes:myupopNote,
  quality:myupopQC,
  anomaly:myupopAC
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 6";

LOAD CSV WITH HEADERS FROM "file:///NMC_5_0-wsupplementary.csv" AS row
MATCH (state:State{cowcode:row.ccode}), (d:Dataset{filename:"NMC_5_0-wsupplementary.csv"}), (y:Year{name:row.year})
CREATE (state)-[:CINC_SCORE{definition:"Composite Index of National Capability (CINC) score"}]->(f:Fact{
  name:"CINC Score",
  value:toFloat(row.cinc)
  })-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 7 of 7";


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gleditsch extended war data
CREATE (d:Source{
  project:"Gleditsch Expanded Data", 
  name:"Expanded War Data",
  version:toFloat(2.0),
  published:date({year:2013, month:11, day:5}),
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2002, month:12, day:31}),
  citation:"Gleditsch, Kristian Skrede 2004. 'A Revised List of Wars Between and Within Independent States, 1816-2002' International Interactions 30: 231-262",
  url:"http://privatewww.essex.ac.uk/~ksg/expwar.html",
  host:"University of Essex",
  poc:"ksg@essex.ac.uk",
  overview:"These data contain a revised and expanded list of wars to conform with the list of independent states outlined in Gleditsch, Kristian Skrede & Michael D. Ward. 1999. 'Interstate System Membership: A Revised List of the Independent States since 1816.' International Interactions 25:393-413. They are explained in greater detail in Gleditsch, Kristian Skrede 2004. 'A Revised List of Wars Between and Within Independent States, 1816-2002', International Interactions 30:231-262."
})
CREATE (d)-[:PROVIDES]->(eiw:Dataset{
  name:"Expanded Interstate Wars Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"List of interstate wars",
  filename:"exp_iw.asc",
  bytesize:toInteger(10280)
})
CREATE (d)-[:PROVIDES]->(eiwp:Dataset{
  name:"Expanded Interstate Wars Participants Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"Interstate war participants and attribute data",
  filename:"exp_iwpart.asc",
  bytesize:toInteger(42152)
})
CREATE (d)-[:PROVIDES]->(ecw:Dataset{
  name:"Expanded Civil Wars Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"List of civil wars (including 'extra-state' wars)",
  filename:"exp_cw.asc",
  bytesize:toInteger(35008)
})
CREATE (d)-[:PROVIDES]->(ecwp:Dataset{
  name:"Expanded Civil Wars Participants Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"Civil war participants and attribute data",
  filename:"exp_cwpart.asc",
  bytesize:toInteger(58196)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Readme",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"Document data and describe changes.",  
  url:"http://privatewww.essex.ac.uk/~ksg/data/expwar_v2.1.zip",
  filename:"Readme.txt",
  bytesize:toInteger(6108)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Modified Expanded Interstate Wars Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"List of interstate wars, reformatted for easy import into Neo4j",
  filename:"exp_iw_modified.csv",
  bytesize:toInteger(12912)
})-[:MODIFIES]->(eiw)
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Modified Expanded Interstate Wars Participants Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"Interstate war participants and attribute data, reformatted for easy import into Neo4j",
  filename:"exp_iwpart_modified.csv",
  bytesize:toInteger(50777)
})-[:MODIFIES]->(eiwp)
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Modified Expanded Civil Wars Data",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"List of civil wars (including 'extra-state' wars, reformatted for easy import into Neo4j)",
  filename:"exp_cw_modified.csv",
  bytesize:toInteger(43802)
})-[:MODIFIES]->(ecw)
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Modified Expanded Civil Wars Participants Data, reformatted for easy import into Neo4j",
  version:toFloat(2.1),
  published:date({year:2013, month:11, day:5}),
  purpose:"Civil war participants and attribute data",
  filename:"exp_cwpart_modified.csv",
  bytesize:toInteger(68580)
})-[:MODIFIES]->(ecwp);

CREATE (d:Source{
  project:"Gleditsch Expanded Data", 
  name:"Revised List of Independent States",
  version:toFloat(5.0),
  published:date({year:1999}),
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2012, month:12, day:31}),
  citation:"Gleditsch, Kristian S. & Michael D. Ward. 1999. 'Interstate System Membership: A Revised List of the Independent States since 1816.' International Interactions 25: 393-413.",
  url:"http://privatewww.essex.ac.uk/~ksg/statelist.html",
  host:"University of Essex",
  poc:"ksg@essex.ac.uk",
  overview:"These data are explained in greater detail in Gleditsch, Kristian S. & Michael D. Ward. 1999. 'Interstate System Membership: A Revised List of the Independent States since 1816.' International Interactions 25: 393-413. Users should also consult the accompanying case description document outlining the classification of states (in PDF format). Note that the current version of the data contain some changes over the table in the Gleditsch and Ward 1999 article. These are documented in the case description file."
})
CREATE (d)-[:PROVIDES]->(iis:Dataset{
  name:"List of Independent States",
  version:toFloat(5.0),
  published:date({year:2013, month:3, day:14}),
  purpose:"List of independent states",
  filename:"iisystem.dat",
  bytesize:toInteger(9093)
})
CREATE (d)-[:PROVIDES]->(mis:Dataset{
  name:"List of Microstates",
  version:toFloat(5.0),
  published:date({year:2013, month:3, day:14}),
  purpose:"A tentative list of microstates that fall short of the 250,000 threshold.",
  filename:"microstatesystem.dat",
  bytesize:toInteger(4096)
})
CREATE (d)-[:PROVIDES]->(iism:Dataset{
  name:"List of Independent States",
  version:toFloat(5.0),
  published:date({year:2013, month:3, day:14}),
  purpose:"List of independent states",
  filename:"iisystem_modified.csv",
  bytesize:toInteger(12288)
})
CREATE (d)-[:PROVIDES]->(mism:Dataset{
  name:"List of Microstates",
  version:toFloat(5.0),
  published:date({year:2013, month:3, day:14}),
  purpose:"A tentative list of microstates that fall short of the 250,000 threshold.",
  filename:"microstatesystem_modified.csv",
  bytesize:toInteger(4096)
});

MATCH (so:Source{project:"Gleditsch Expanded Data", name:"Revised List of Independent States", version:5.0})
CREATE (so)-[:DEFINES {
  asOf:date({year:2013, month:11, day:5})
  }]->(system:System {
    name:"Expanded State System",
    scope:"Global",
    from:date({year:1816, month:1, day:1}),
    until:date({year:2002, month:12, day:31})
  });

MATCH (source:Dataset{filename:"iisystem_modified.csv"}), (sys:System{name:"Expanded State System"})
LOAD CSV WITH HEADERS FROM "file:///iisystem_modified.csv" AS row
MERGE (source)-[:CONTRIBUTES]->(f:Fact{
  name:"System Membership",
  from:date({year:toInteger(row.syr), month:toInteger(row.smon), day:toInteger(row.sday)}),
  until:date({year:toInteger(row.eyr), month:toInteger(row.emon), day:toInteger(row.eday)})
  })-[:MEMBER_OF]->(sys)
MERGE (state:State{cowcode:row.ccode}) 
  ON CREATE SET state.name = row.statename, state.abb = row.abb
FOREACH (specific IN CASE WHEN row.statename <> state.name THEN [1] ELSE [] END | SET state.altName = row.statename)
FOREACH (specific IN CASE WHEN row.abb <> state.abb THEN [1] ELSE [] END | SET state.altAbb = row.abb)
CREATE (state)-[:MEMBER]->(f);
RETURN "Successfully imported the 8th file, Gleditsch's Expanded State System";

// Microstates
MATCH (so:Source{project:"Gleditsch Expanded Data", name:"Revised List of Independent States", version:5.0})
CREATE (so)-[:DEFINES {
  asOf:date({year:2013, month:11, day:5})
  }]->(system:System {
    name:"Microstate System",
    scope:"Global",
    from:date({year:1816, month:1, day:1}),
    until:date({year:2002, month:12, day:31})
  });

MATCH (source:Dataset{filename:"microstatesystem_modified.csv"})
MATCH (sys:System{name:"Microstate System"})
LOAD CSV WITH HEADERS FROM "file:///microstatesystem_modified.csv" AS row
MERGE (source)-[:CONTRIBUTES]->(f:Fact{
  name:"System Membership",
  from:date({year:toInteger(row.syr), month:toInteger(row.smon), day:toInteger(row.sday)}),
  until:date({year:toInteger(row.eyr), month:toInteger(row.emon), day:toInteger(row.eday)})
  })-[:MEMBER_OF]->(sys)
MERGE (state:State{cowcode:row.ccode}) 
  ON CREATE SET state.name = row.statename, state.abb = row.abb
MERGE (state)-[:MEMBER]->(f)
FOREACH (specific IN CASE WHEN row.statename <> state.name THEN [1] ELSE [] END | SET state.altName = row.statename)
FOREACH (specific IN CASE WHEN row.abb <> state.abb THEN [1] ELSE [] END | SET state.altAbb = row.abb)
CREATE (state)-[:MEMBER]->(f);
RETURN "Successfully imported the 9th file, Gleditsch's Microstate System";

// Gleditsch Expanded War Data
MATCH (d:Source{project:"Gleditsch Expanded Data", name:"Expanded War Data"})
MATCH (f:Dataset{filename:"exp_cw_modified.csv"})
LOAD CSV WITH HEADERS FROM "file:///exp_cw_modified.csv" AS row
CREATE (d)-[:DEFINES]->(ew:List{name:"Expanded Wars"})
CREATE (d)-[:DEFINES]->(ecw:List{name:"Expanded Civil Wars"})
CREATE (f)-[:CONTRIBUTES]->(ewf:Fact{
  name:"Expanded War",
  began:date({year:toInteger(row.syear), month:toInteger(row.smon), day:toInteger(row.sday)}),
  end:date({year:toInteger(row.eyear), month:toInteger(row.emon), day:toInteger(row.eday)})
  })-[:ONE_OF]->(ew)
CREATE (f)-[:CONTRIBUTES]->(ecwf:Fact{
  name:"Expanded Civil War",
  began:date({year:toInteger(row.syear), month:toInteger(row.smon), day:toInteger(row.sday)}),
  end:date({year:toInteger(row.eyear), month:toInteger(row.emon), day:toInteger(row.eday)})
  })-[:ONE_OF]->(ecw)
CREATE (war:War{
  gwid:row.warid,
  name:row.warname,
  cowcode:split(row.newcow,  ";"),
  cow94:row.cow94, 
  cow00:row.cow00, 
  oldwarId:row.oldwid
  })-[:IS_ONE]->(ewf)
CREATE (war)-[:IS_ONE]->(ecwf);
RETURN "Successfully loaded the 10th file, Gleditsch's expanded civil and Intra-state wars";

// Import Civil and Intra-state War participation
//warid,statenum,syr,smon,sday,eyr,emon,eday,deaths,intnl,outcome,continuation
MATCH (g:Dataset{filename:"exp_cwpart_modified.csv"})
LOAD CSV WITH HEADERS FROM "file:///exp_cwpart_modified.csv" AS row
MATCH (state:State{cowcode:row.statenum}),(war:War{gwid:row.warid})
FOREACH (cont in CASE WHEN row.continuation = 'F' THEN [1] ELSE [] END | 
  CREATE (g)-[:CONTRIBUTES]->(f:Fact{
    from:date({year:toInteger(row.syr), month:toInteger(row.smon), day:toInteger(row.sday)}),
    until:date({year:toInteger(row.eyr), month:toInteger(row.emon), day:toInteger(row.eday)}),
    magnitude:toFloat(row.deaths),
    continuation:toBoolean(row.continuation),
    name:"Expanded Civil War Paricipation"})-[:PARTICIPATED_IN]->(war)
  CREATE (state)-[:PARTICIPATED]->(f) ) ;

MATCH (g:Dataset{filename:"exp_cwpart_modified.csv"})
LOAD CSV WITH HEADERS FROM "file:///exp_cwpart_modified.csv" AS row
MATCH (state:State{cowcode:row.statenum}),(war:War{gwid:row.warid})
FOREACH (cont in CASE WHEN row.continuation = 'T' THEN [1] ELSE [] END |
  CREATE (g)-[:CONTRIBUTES]->(f:Fact{
    from:date({year:toInteger(row.syr), month:toInteger(row.smon), day:toInteger(row.sday)}),
    until:date({year:toInteger(row.eyr), month:toInteger(row.emon), day:toInteger(row.eday)}),
    magnitude:toFloat(row.deaths),
    continuation:toBoolean(row.continuation),
    name:"Expanded Civil War Paricipation"})-[:CONTINUED_IN]->(war)
  CREATE (state)-[:CONTINUED]->(f) ) ;

// Import participation in civil and intra-state wars
LOAD CSV WITH HEADERS FROM "file:///exp_cwpart_modified.csv" AS row
MATCH (state:State{cowcode:row.statenum})-[:PARTICIPATED]->(f:Fact)-[:PARTICIPATED_IN]->(war:War{gwid:row.warid})
WITH *,
CASE row.outcome 
  WHEN "1" THEN "Government Won"
  WHEN "2" THEN "Opposition Won"
  WHEN "3" THEN "Compromise"
  WHEN "4" THEN "Tranfomed into Another War Type"
  WHEN "5" THEN "Ongoing as of 31-12-2010"
  WHEN "6" THEN "Stalemate"
  WHEN "7" THEN "Continuing conflict below war level"
  ELSE "Data parse error"
  END AS verdict,
CASE row.intnl
  WHEN "NA" THEN "Not Applicable"
  WHEN "0" THEN toBoolean("FALSE")
  WHEN "1" THEN toBoolean("TRUE")
  ELSE "Data parse error"
  END AS intl
MERGE (f)-[:RESULTED]->(r:Result{outcome:verdict, internationalized:intl})-[:RESULT_FOR]->(state)
MERGE (r)-[:RESULT_OF]->(war);
RETURN "Successfully loaded the 11th file, Gleditsch's expanded civil and Intra-state war participation data.";

// Import Interstate Wars
MATCH (d:Source{project:"Gleditsch Expanded Data", name:"Expanded War Data"})
MATCH (f:Dataset{filename:"exp_iw_modified.csv"})
LOAD CSV WITH HEADERS FROM "file:///exp_iw_modified.csv" AS row
CREATE (d)-[:COVERS]->(ew:List{name:"Expanded Wars"})
CREATE (d)-[:COVERS]->(eiw:List{name:"Expanded Interstate Wars"})
CREATE (f)-[:CONTRIBUTES]->(ewf:Fact{
  name:"Expanded Interstate War",
  began:date({year:toInteger(row.syear), month:toInteger(row.smon), day:toInteger(row.sday)}),
  end:date({year:toInteger(row.eyear), month:toInteger(row.emon), day:toInteger(row.eday)})
  })-[:ONE_OF]->(ew)
CREATE (f)-[:CONTRIBUTES]->(eiwf:Fact{
  name:"Expanded Interstate War",
  began:date({year:toInteger(row.syear), month:toInteger(row.smon), day:toInteger(row.sday)}),
  end:date({year:toInteger(row.eyear), month:toInteger(row.emon), day:toInteger(row.eday)})
  })-[:ONE_OF]->(eiw)
CREATE (war:War{
  gwid:row.warid,
  name:row.warname,
  cowcode:split(row.newcow,  ";"),
  cow94:row.cow94, 
  cow00:row.cow00, 
  oldwarId:row.oldwid
  })-[:IS_ONE]->(ewf)
CREATE (war)-[:IS_ONE]->(eiwf);
RETURN "Successfully loaded the 16th file, Gleditsch's expanded interstate wars";

//warid,statenum,syr,smon,sday,eyr,emon,eday,side,deaths,outcome,initiate,newcow,cow94,cow00,oldwid,continuation
MATCH (g:Dataset{filename:"exp_iwpart_modified.csv"})
LOAD CSV WITH HEADERS FROM "file:///exp_iwpart_modified.csv" AS row
MATCH (state:State{cowcode:row.statenum}),(war:War{gwid:row.warid})
FOREACH (cont in CASE WHEN row.continuation = 'F' THEN [1] ELSE [] END | 
  CREATE (g)-[:CONTRIBUTES]->(f:Fact{
    from:date({year:toInteger(row.syr), month:toInteger(row.smon), day:toInteger(row.sday)}),
    until:date({year:toInteger(row.eyr), month:toInteger(row.emon), day:toInteger(row.eday)}),
    magnitude:toFloat(row.deaths),
    continuation:toBoolean(row.continuation),
    name:"Expanded Interstate War Paricipation"})-[:PARTICIPATED_IN]->(war)
  CREATE (state)-[:PARTICIPATED]->(f) );

//warid,statenum,syr,smon,sday,eyr,emon,eday,side,deaths,outcome,initiate,newcow,cow94,cow00,oldwid,continuation
MATCH (g:Dataset{filename:"exp_iwpart_modified.csv"})
LOAD CSV WITH HEADERS FROM "file:///exp_iwpart_modified.csv" AS row
MATCH (state:State{cowcode:row.statenum}),(war:War{gwid:row.warid})
FOREACH (cont in CASE WHEN row.continuation = 'T' THEN [1] ELSE [] END |
  CREATE (g)-[:CONTRIBUTES]->(f:Fact{
    from:date({year:toInteger(row.syr), month:toInteger(row.smon), day:toInteger(row.sday)}),
    until:date({year:toInteger(row.eyr), month:toInteger(row.emon), day:toInteger(row.eday)}),
    magnitude:toFloat(row.deaths),
    continuation:toBoolean(row.continuation),
    name:"Expanded Interstate War Paricipation"})-[:CONTINUED_IN]->(war)
  CREATE (state)-[:CONTINUED]->(f) );

LOAD CSV WITH HEADERS FROM "file:///exp_iwpart_modified.csv" AS row
MATCH (state:State{cowcode:row.statenum})-[:PARTICIPATED]->(f:Fact)-[:PARTICIPATED_IN]->(war:War{gwid:row.warid})
FOREACH (
  i in CASE WHEN row.initiate = "1" THEN [1] ELSE [] END | MERGE (state)-[:INITIATOR_OF]->(f)-[:INITIATED]->(war) 
  )
WITH *,
CASE row.outcome 
  WHEN "1" THEN "Victory"
  WHEN "2" THEN "Defeat"
  WHEN "3" THEN "Compromise"
  WHEN "4" THEN "Tranfomed into Another War Type"
  WHEN "5" THEN "Ongoing as of 31-12-2010"
  WHEN "6" THEN "Stalemate"
  WHEN "7" THEN "Continuing conflict below war level"
  WHEN "8" THEN "Changed Sides" 
  ELSE "Data parse error"
  END AS verdict
CREATE (f)-[:RESULTED]->(r:Result{outcome:verdict})-[:RESULT_FOR]->(state)
CREATE (r)-[:RESULT_OF]->(war);
RETURN "Successfully loaded the 12th file, Gleditsch's expanded interstate war paricipation, part 2 of 2"; 
// End Interstate War participation
// Beyond this point the dbms.memory.heap.max_size must be greater than 1G.


// COW Alliance Dataset
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Formal Alliances", 
  version:toFloat(4.1),
  published:date({year:2013, month:4, day:11}),  
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2012, month:12, day:31}),
  citation:"Gibler, Douglas M. 2009. International military alliances, 1648-2008. CQ Press.",
  host:"Douglas Gibler (University of Alabama)",
  poc:"Douglas Gibler (dmgibler@bama.ua.edu)",
  url:"http://correlatesofwar.org/data-sets/formal-alliances",
  overview:"The Correlates of War Formal Alliance data set seeks to identify each formal alliance between at least two states that fall into the classes of defense pact, neutrality or non-aggression treaty, or entente agreement. A defense pact (Type I) is the highest level of military commitment, requiring alliance members to come to each other’s aid militarily if attacked by a third party. As the labels imply, neutrality and non-aggression pacts (Type II) pledge signatories to either remain neutral in case of conflict or to not use or otherwise support the use of force against the other alliance members. Finally, ententes (Type III) provide for the least commitment and obligate members to consult in times of crisis or armed attack. Each alliance classifies the highest level of military support that an alliance member pledges to another alliance member. The data set provides the type, members, and appropriate dates of activity of each identified alliance. \nVersion 4.1 of the alliance data expands the original Singer and Small (1966) deffinitions of alliance types to include neutrality and non-aggression pacts separately. Neutrality pacts are now labeled as Type IIa alliances, and Non-Aggression pacts are labeled as Type IIb alliances. Alliance terms also distinguish between neutrality and non-aggression in the dyadic data. \nIn addition, the fourth version now differentiates between the overall alliance type and the terms of the alliance by specific member. In the alliance member list of data, for example, both the Singer and Small (1966) alliance type and the specific terms by alliance member are included. Only the terms operational for the specific dyad are included in the dyadic and direct-dyad data.",
  purpose:"This data set records all formal alliances among states between 1816 and 2012, including mutual defense pacts, non-aggression treaties, and ententes. This data set is hosted by Douglas Gibler, University of Alabama."
  })
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Alliances by Member",
  version:toFloat(4.1),
  published:date({year:2013, month:4, day:11}),  
  note:"Note that, if a member exits an alliance and then reenters the same alliance later, then that member will be included in the alliance twice, with the appropriate dates of membership included for each observation. ",
  purpose:"The file named < alliance v4.1 by member.* > contains the alliance dataset distributed by member, with one observation for each alliance member initiation.",
  url:"http://correlatesofwar.org/data-sets/formal-alliances/alliances-data-csv-zip/at_download/file",
  filename:"alliance_v4.1_by_member.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Yearly Alliances by Member",
  version:toFloat(4.1),
  published:date({year:2013, month:4, day:11}),  
  purpose:"The file named < alliance v4.1 by member yearly.* > includes an observation for each alliance member year.",
  url:"http://correlatesofwar.org/data-sets/formal-alliances/alliances-data-csv-zip/at_download/file",
  filename:"alliance_v4.1_by_member_yearly.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Alliances Release Notes",
  version:toFloat(4.1),
  published:date({year:2013, month:4, day:11}),  
  note:"On April 11, 2013 version 4.1 was released; it updates the alliance data by including two Israeli treaties that were not in the original data. On March 19, 2013, we released version 4.0 of the alliance data set. V4.0 extends the data coverage and adds other substantive changes as outlined below.",
  purpose:"",
  url:"http://correlatesofwar.org/data-sets/formal-alliances/alliances-data-csv-zip/at_download/file",
  filename:"Alliance_v4.1_ReleaseNotes.pdf"
});

MATCH (d:Dataset{filename:"alliance_v4.1_by_member.csv"})
LOAD CSV WITH HEADERS FROM "file:///alliance_v4.1_by_member.csv" AS row
MERGE (s:State{cowcode:row.ccode})
WITH *,
CASE row.left_censor 
  WHEN "1" THEN toBoolean(true)
  ELSE toBoolean(false)
  END AS prior,
CASE row.right_censor
  WHEN "1" THEN toBoolean(true)
  ELSE toBoolean(false)
  END AS beyond
MERGE (a:Alliance{
  cowcode:row.version4id,
  ssType:row.ss_type,
  version:row.version,
  began:date({year:toInteger(row.all_st_year), month:toInteger(row.all_st_month), day:toInteger(row.all_st_day) } )
  })
CREATE (d)-[:CONTRIBUTES]->(f:Fact{
  from:date({year:toInteger(row.mem_st_year), month:toInteger(row.mem_st_month), day:toInteger(row.mem_st_day)}),
  priorTo1816:prior,
  beyond2012:beyond
  })-[e:ENTERED_INTO]->(a)
CREATE (s)-[:ENTERED]->(a)
WITH f, a, row
FOREACH (specific IN CASE WHEN trim(row.all_end_year) <> "" THEN [1] ELSE [] END | SET a.ended = date({year:toInteger(row.all_end_year)}))
FOREACH (specific IN CASE WHEN trim(row.all_end_month) <> "" THEN [1] ELSE [] END | SET a.ended = date({year:toInteger(row.all_end_year),
  month:toInteger(row.all_end_month)}))
FOREACH (specific IN CASE WHEN trim(row.all_end_day) <> "" THEN [1] ELSE [] END | SET a.ended = date({year:toInteger(row.all_end_year),
  month:toInteger(row.all_end_month), day:toInteger(row.all_end_day)}))
FOREACH (specific IN CASE WHEN trim(row.mem_end_year) <> "" THEN [1] ELSE [] END | SET f.until = date({year:toInteger(row.mem_end_year)}))
FOREACH (specific IN CASE WHEN trim(row.mem_end_month) <> "" THEN [1] ELSE [] END | SET f.until = date({year:toInteger(row.mem_end_year),
  month:toInteger(row.mem_end_month)}))
FOREACH (specific IN CASE WHEN trim(row.mem_end_day) <> "" THEN [1] ELSE [] END | SET f.until = date({year:toInteger(row.mem_end_year),
  month:toInteger(row.mem_end_month), day:toInteger(row.mem_end_day)}));

LOAD CSV WITH HEADERS FROM "file:///alliance_v4.1_by_member.csv" AS row
MATCH (a:Alliance{cowcode:row.version4id})
FOREACH (datum IN CASE WHEN row.defense="1" THEN [1] ELSE [] END | SET a:DefenseAgreement )
FOREACH (datum IN CASE WHEN row.neutrality="1" THEN [1] ELSE [] END | SET a:NeutralityAgreement )
FOREACH (datum IN CASE WHEN row.nonaggression="1" THEN [1] ELSE [] END | SET a:NonaggressionAgreement )
FOREACH (datum IN CASE WHEN row.entente="1" THEN [1] ELSE [] END | SET a:Entente );
RETURN "Successfully loaded the 18th file, alliance_v4.1_by_member";
// End of Alliances data


// Intergovernmental Organizations
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Intergovernmental Organizations", 
  version:toFloat(2.3),
  published:date({year:2010, month:6, day:30}),
  validFrom:date({year:1815, month:1, day:1}),
  falidUntil:date({year:2005, month:12, day:31}),
  citation:"Pevehouse, Jon C., Timothy Nordstrom, and Kevin Warnke. 2004. 'The COW-2 International Organizations Dataset Version 2.0,' Conflict Management and Peace Science 21:101-119.",
  host:["Timothy Nordstrom (University of Mississippi)", "Jon Pevehouse (University of Wisconsin)","Megan Shannon (University of Colorado-Boulder)"],
  poc:["Timothy Nordstrom (tnordstr@olemiss.edu)", "Jon Pevehouse (pevehous@polisci.wisc.edu)","Megan Shannon (megan.l.shannon@colorado.edu)"],
  url:"http://correlatesofwar.org/data-sets/IGOs",
  overview:"The IGO data sets contain information about intergovernmental organizations (international organizations that have at least 3 nation-states as their members) from 1815-2005. The IGO data are collected at 5-year intervals from 1815-1965, and annually thereafter. The data are presented in three forms with distinct units of analysis. Form 1 is organized by IGO, listing all IGOs with the IGO-year as the unit of analysis, and identifying all state members of the IGO in that year. Form 2 is organized by state, listing all states with the country-year as the unit of analysis, and identifying all IGO memberships of the state in that year. Form 3 combines individual country memberships into joint dyadic memberships in each IGO, marking joint membership in each IGO for each pair of states. The expanded version 2.3 updates the original Wallace and Singer (1970) data set to provide membership information from 1964-2005, along with recoding some earlier IGOs.",
  purpose:"Although the number of intergovernmental organizations (IGOs) grew dramatically during the late 20th century, they have been part of the world scene for much longer. This data set tracks the status and membership of such organizations from 1815-2005. Access information about this data here. This data set is hosted by Timothy Nordstrom, University of Mississippi, Jon Pevehouse, University of Wisconsin and Megan Shannon, Colorado-Boulder."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"IGO Unit Data",
  version:toFloat(2.3),
  published:date({year:2010, month:6, day:30}),
  note:"Contains one record per IGO-year (with years listed at 5 year intervals through 1965, and annually thereafter).",
  purpose:"Data on IGOs from 1815-2005, at the IGO-year level.",
  url:"http://correlatesofwar.org/data-sets/IGOs/IGO_igounit_v2.3.zip/at_download/file",
  filename:"IGO_igounit_v2.3.zip",
  bytesize:toInteger(275445)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"IGO State Unit Data",
  version:toFloat(2.3),
  published:date({year:2010, month:6, day:30}),
  note:"Contains one record per country-year (with years listed at 5 year intervals through 1965, and annually thereafter).",
  purpose:"Data on IGOs from 1815-2005, at the country-year level.",
  url:"http://correlatesofwar.org/data-sets/IGOs/igo_dyadunit_csv_v2-3.zip/at_download/file",
  filename:"IGO_stateunit_v2.3.zip",
  bytesize:toInteger(563211)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"IGO Dyad Unit Data",
  version:toFloat(2.3),
  published:date({year:2010, month:6, day:30}),
  note:"Contains one record per dyad-year (with years listed at 5 year intervals through 1965, and annually thereafter).",
  purpose:"Data on IGOs from 1815-2005, at the dyad-year level.",
  url:"http://correlatesofwar.org/data-sets/IGOs/igo_dyadunit_csv_v2-3.zip/at_download/file",
  filename:"IGO_dyadunit_csv_v2.3.zip",
  bytesize:toInteger(41515002)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"IGO Codebook",
  version:toFloat(2.1),
  published:date({year:2003, month:12, day:9}),
  note:"Version 2.3 of the IGO data replaced version 2.1 on June 30, 2010. It expands the data from v2.1 until 2005.",
  purpose:"Main codebook for the IGO data set, describing file formats, variable values, and listing variables contained in the component data files.",
  url:"http://correlatesofwar.org/data-sets/IGOs/IGO_codebook_v2.1.pdf/at_download/file",
  filename:"IGO_codebook_v2.1.pdf",
  bytesize:toInteger(296017)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"IGO Overview of Changes in v2.3",
  version:toFloat(2.3),
  published:date({year:2010, month:6, day:30}),
  purpose:"A .pdf file that provides a unit specific explanation of the changes made in v2.3.",
  url:"http://correlatesofwar.org/data-sets/IGOs/IGO_overview_of_changes_in_v2.3.pdf/at_download/file",
  filename:"IGO_overview_of_changes_in_v2.3.pdf",
  bytesize:toInteger(62916)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"IGO Descriptions",
  version:toFloat(2.1),
  published:date({year:2003, month:12, day:9}),
  note:"The graph database author's extraction of IGO descriptions from version 2.1 Codebook; not part of the published data and not original work.",
  purpose:"Enhanced descriptions of the IGO unit-level data.",
  filename:"igo_descriptions_cwd.csv",
  bytesize:toInteger(41515002)
});

//id,name,formed,terminated,inactive,cowcode,notes,missingdata
MATCH (d:Dataset{filename:"igo_descriptions_cwd.csv"}), (y:System{name:"COW State System"})
LOAD CSV WITH HEADERS FROM "file:///igo_descriptions_cwd.csv" AS row
CREATE (d)-[:CONTRIBUTES{asOf:d.published}]->(f:Fact{
  name:"IGO Formation", 
  formed:date({year:toInteger(row.formed)})
  })-[:PART_OF]->(y)
CREATE (i:IGO{cowcode:row.id, updated:"F"})-[:PART]->(f)
FOREACH (var IN CASE WHEN row.notes <> "" THEN [1] ELSE [] END | SET i.notes = row.notes )
FOREACH (var IN CASE WHEN row.inactive <> "" THEN [1] ELSE [] END | SET f.active = toBoolean(FALSE) )
FOREACH (var IN CASE WHEN row.missingdata <> "" THEN [1] ELSE [] END | SET i.missingData = row.missingdata )
FOREACH (var IN CASE WHEN row.terminated<> "" THEN [1] ELSE [] END | SET f.terminated = date({year:toInteger(row.terminated)}) )

// ioname+,orgname-,year-,dead+,deaddate+,integrated,replaced,igocode,ionum,longorgname+,sdate+,version,Sources,Sources2
LOAD CSV WITH HEADERS FROM "file:///igounit_v2.3.csv" AS row
MERGE (i:IGO{cowcode:row.ionum})
ON CREATE 
  SET i.name = row.ioname, i.longname = row.longorgname, i.from = date({year:toInteger(row.sdate)}), i.updated = "T"
  FOREACH (var IN CASE WHEN row.igocode <> "" THEN [1] ELSE [] END | SET i.oldCOW = row.igocode )
  FOREACH (var IN CASE WHEN row.deaddate<> "" THEN [1] ELSE [] END | SET i.until = date({year:toInteger(row.deaddate)}))

LOAD CSV WITH HEADERS FROM "file:///igounit_v2.3.csv" AS row
MERGE (i:IGO{cowcode:row.ionum, updated:"F"})
ON MATCH 
  SET i.name = row.ioname, i.longname = row.longorgname, i.from = date({year:toInteger(row.sdate)}), i.updated = "T"
  FOREACH (var IN CASE WHEN row.igocode <> "" THEN [1] ELSE [] END | SET i.oldCOW = row.igocode )
  FOREACH (var IN CASE WHEN row.deaddate<> "" THEN [1] ELSE [] END | SET i.until = date({year:toInteger(row.deaddate)}))

// World Religions Project publication metada
CREATE (d:Source{
  project:"Correlates of War", 
  name:"WRP", 
  version:toFloat(1.1),
  published:date({year:2013, month:7, day:1}),
//  validFrom:date({year:1816, month:1, day:1}),
//  falidUntil:date({year:2016, month:12, day:31}),
  citation:" Zeev Maoz and Errol A. Henderson. 2013. 'The World Religion Dataset, 1945-2010: Logic, Estimates, and Trends.' International Interactions, 39: 265-291.",
  url:"http://correlatesofwar.org/data-sets/world-religion-data",
  overview:"The World Religion Project (WRP) aims to provide detailed information about religious adherence worldwide from 1945 to 2010. It contains data about the number of adherents by religion in each of the states in the international system. These numbers are given for every half-decade period (1945, 1950,..., 2010). The data record percentages of the state's population that practice a given religion. Some of the religions (as detailed in the Codebook) are divided into religious families. To the extent data are available, the breakdown of adherents within a given religion into religious families is also specified in the Codebook. \nThe project was developed in three stages. The first stage consisted of the formation of a religions tree. A religion tree is a systematic classification of major religions and of religious families within those major religions. The second stage consisted of the identification of major data sources of religious adherence and the collection of data from these sources according to the religion tree classification. The third stage consisted of cleaning the data, reconciling discrepancies of information from different sources, and imputing data for the missing cases.",
  purpose:"This data set aims to provide detailed information about religious adherence worldwide since 1945. This data set is hosted by Zeev Maoz, University of California-Davis, and Errol A. Henderson, Pennsylvania State University."
  })
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"WRP National Data",
  version:toFloat(1.1),
  published:date({year:2017, month:2, day:1}),  
  purpose:"The National Dataset.",
  url:"http://correlatesofwar.org/data-sets/world-religion-data/wrp-national-data-1/at_download/file",
  filename:"WRP_national.csv",
  bytesize:toInteger(870713)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"WRP Regional Data",
  version:toFloat(1.1),
  published:date({year:2017, month:2, day:1}),  
  purpose:"The Regional Dataset.",
  url:"http://correlatesofwar.org/data-sets/world-religion-data/wrp-regional-data/at_download/file",
  filename:"WRP_regional.csv",
  bytesize:toInteger(39472)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"WRP Global Data",
  version:toFloat(1.1),
  published:date({year:2017, month:2, day:1}),  
  purpose:"The Global Dataset.",
  url:"http://correlatesofwar.org/data-sets/world-religion-data/wrp-global-data/at_download/file",
  filename:"WRP_global.csv",
  bytesize:toInteger(10921)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"WRP codebook",
  version:toFloat(1.1),
  published:date({year:2017, month:2, day:1}),  
  purpose:"Main codebook for the WRP data set, describing the data and listing variables contained in the component data files. Includes bibliography and source codes for the WRP data set.",
  url:"http://correlatesofwar.org/data-sets/world-religion-data/wrp-codebook/at_download/file",
  filename:"codebook+bibliography.pdf",
  bytesize:toInteger(863250)
});

// World religions graph (from the documentation)
CREATE (:Religion{symbol:"zorogen", name:"Zoroastrian"})
CREATE (:Religion{symbol:"hindgen", name:"Hindu"})
CREATE (:Religion{symbol:"sikhgen", name:"Sikh"})
CREATE (:Religion{symbol:"shntgen", name:"Shinto"})
CREATE (:Religion{symbol:"bahgen", name:"Baha’i"})
CREATE (:Religion{symbol:"taogen", name:"Taoism"})
CREATE (:Religion{symbol:"jaingen", name:"Jain"})
CREATE (:Religion{symbol:"confgen", name:"Confucianism"})
CREATE (:Religion{symbol:"anmgen", name:"Animist Religions"})
CREATE (:Religion{symbol:"syncgen", name:"Syncretic Religions"})
CREATE (:Religion{symbol:"nonrelig", name:"Non-Religious"})
CREATE (:Religion{symbol:"othrgen", name:"Other Religions"})
CREATE (:Religion{symbol:"budgen", name:"Buddhism"})
CREATE (:Religion{symbol:"islmgen", name:"Islam"})
CREATE (:Religion{symbol:"judgen", name:"Judaism"})
CREATE (:Religion{symbol:"chrstgen", name:"Christianity"})
CREATE (:Denomination:Religion{symbol:"chrstprot", majorReligion:"Christianity", denomination:"Protestants"})
CREATE (:Denomination:Religion{symbol:"chrstcat", majorReligion:"Christianity", denomination:"Roman Catholics"})
CREATE (:Denomination:Religion{symbol:"chrstorth", majorReligion:"Christianity", denomination:"Eastern Orthodox"})
CREATE (:Denomination:Religion{symbol:"chrstang", majorReligion:"Christianity", denomination:"Anglican"})
CREATE (:Denomination:Religion{symbol:"chrstothr", majorReligion:"Christianity", denomination:"Others"})
CREATE (:Denomination:Religion{symbol:"judorth", majorReligion:"Judaism", denomination:"Orthodox"})
CREATE (:Denomination:Religion{symbol:"jdcons", majorReligion:"Judaism", denomination:"Conservatives"})
CREATE (:Denomination:Religion{symbol:"judref", majorReligion:"Judaism", denomination:"Reform"})
CREATE (:Denomination:Religion{symbol:"judothr", majorReligion:"Judaism", denomination:"Others"})
CREATE (:Denomination:Religion{symbol:"islmsun", majorReligion:"Islam", denomination:"Sunni"})
CREATE (:Denomination:Religion{symbol:"islmshi", majorReligion:"Islam", denomination:"Shi’a"})
CREATE (:Denomination:Religion{symbol:"islmibd", majorReligion:"Islam", denomination:"Ibadhi"})
CREATE (:Denomination:Religion{symbol:"islmnat", majorReligion:"Islam", denomination:"Nation of Islam"})
CREATE (:Denomination:Religion{symbol:"islmalw", majorReligion:"Islam", denomination:"Alawite"})
CREATE (:Denomination:Religion{symbol:"islmahm", majorReligion:"Islam", denomination:"Ahmadiyya"})
CREATE (:Denomination:Religion{symbol:"islmothr", majorReligion:"Islam", denomination:"Other"})
CREATE (:Denomination:Religion{symbol:"budmah", majorReligion:"Buddhism", denomination:"Mahayana"})
CREATE (:Denomination:Religion{symbol:"budthr", majorReligion:"Buddhism", denomination:"Theravada"})
CREATE (:Denomination:Religion{symbol:"budothr", majorReligion:"Buddhism", denomination:"Other"})

MATCH (d:Denomination), (r:Religion) 
WHERE d.majorReligion = r.name
CREATE (d)-[:PART_OF]->(r);

// WRP National Data 
MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstprot"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.chrstprot),percentage:toFloat(row.chrstprotpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstcat"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.chrstcat),percentage:toFloat(row.chrstcatpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstorth"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.chrstorth),percentage:toFloat(row.chrstorthpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstang"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.chrstang),percentage:toFloat(row.chrstangpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstothr"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.chrstothr),percentage:toFloat(row.chrstothrpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.chrstgen),percentage:toFloat(row.chrstgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"judorth"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.judorth),percentage:toFloat(row.judorthpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"judcons"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.jdcons),percentage:toFloat(row.judconspct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"judref"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.judref),percentage:toFloat(row.judrefpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"judothr"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.judothr),percentage:toFloat(row.judothrpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"judgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.judgen),percentage:toFloat(row.judgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmsun"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmsun),percentage:toFloat(row.islmsunpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmshi"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmshi),percentage:toFloat(row.islmshipct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmibd"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmibd),percentage:toFloat(row.islmibdpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmnat"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmnat),percentage:toFloat(row.islmnatpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmalw"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmalw),percentage:toFloat(row.islmalwpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmahm"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmahm),percentage:toFloat(row.islmahmpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmothr"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmothr),percentage:toFloat(row.islmothrpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"islmgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.islmgen),percentage:toFloat(row.islmgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"budmah"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.budmah),percentage:toFloat(row.budmahpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"budthr"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.budthr),percentage:toFloat(row.budthrpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"budothr"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.budothr),percentage:toFloat(row.budothrpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"budgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.budgen),percentage:toFloat(row.budgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"zorogen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.zorogen),percentage:toFloat(row.zorogenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"hindgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.hindgen),percentage:toFloat(row.hindgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"sikhgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.sikhgen),percentage:toFloat(row.sikhgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"shntgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.shntgen),percentage:toFloat(row.shntgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"bahgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.bahgen),percentage:toFloat(row.bahgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"taogen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.taogen),percentage:toFloat(row.taogenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"jaingen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.jaingen),percentage:toFloat(row.jaingenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"confgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.confgen),percentage:toFloat(row.confgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"syncgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.syncgen),percentage:toFloat(row.syncgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"anmgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.anmgen),percentage:toFloat(row.anmgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"nonrelig"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.nonrelig),percentage:toFloat(row.nonreligpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"othrgen"})
WITH *
MERGE (d)-[:CONTRIBUTES]->(f:Fact{population:toInteger(row.othrgen),percentage:toFloat(row.othrgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"Totals"})
MERGE (d)-[:CONTRIBUTES]->(f:Fact{
  sum:toInteger(row.sumrelig),
  sumPercent:toFloat(row.sumreligpct),
  totalPopulation:toInteger(row.pop),
  totalPercentage:toFloat(row.total)
  })-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode, 
  f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab), 
  f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel, 
  f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig="1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));
// Done with religion

// Begin MIDs
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Militarized Interstate Disputes", 
  version:toFloat(4.1),
  published:date({year:2015, month:1, day:9}),
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2016, month:12, day:31}),
  citation:"Palmer, Glenn, Vito D'Orazio, Michael Kenwick, and Matthew Lane.  2015.  'The MID4 Data Set: Procedures, Coding Rules, and Description.'  Conflict Management and Peace Science.",
  url:"http://correlatesofwar.org/data-sets/MIDs",
  host:"Glenn Palmer (Penn State)",
  poc:"Glenn Palmer (gpalmer@psu.edu)",
  overview:"This data set contains the list of states in the international system as updated and distributed by the Correlates of War Project. These data sets identify states, their standard Correlates of War 'country code' or state number (used throughout the Correlates of War project data sets), state abbreviations, and dates of membership as states and major powers in the international system. Version 2016 extends the temporal domain of the collection through December 2016. \nThe Correlates of War project includes a state in the international system from 1816-2016 for the following criteria. Prior to 1920, the entity must have had a population greater than 500,000 and have had diplomatic missions at or above the rank of charge d’affaires with Britain and France. After 1920, the entity must be a member of the League of Nations or the United Nations, or have a population greater than 500,000 and receive diplomatic missions from two major powers.",
  purpose:"This data set records the fluctuating composition of the state system since 1816. It also identifies countries corresponding to the standard Correlates of War country codes."
  })
// MID-level data and documents
CREATE (d)-[:PROVIDES]->(:File{
  name:"MID4 Codebook",
  version:toFloat(4.0),
  published:date({year:2013, month:12, day:13}),
  purpose:"Main codebook for the MID 4.0 data set, describing file formats and listing variables contained in the MIDA and MIDB data files.",
  url:"http://correlatesofwar.org/data-sets/MIDs/mid-level/at_download/file",
  filename:"MID_v4.0_Codebook.pdf"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"MID Disputes Data",
  published:date({year:2015, month:1, day:9}),
  purpose:"Data on MIDs from 1816-2010, at the dispute level. Contains one record per militarized dispute.",
  url:"http://correlatesofwar.org/data-sets/MIDs/mid-level/at_download/file",
  filename:"MIDA_4.2.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"MID Participants Data",
  published:date({year:2015, month:1, day:9}),
  purpose:"Data on MIDs from 1816-2010, at the participant level. Contains one record per militarized dispute participant.",
  url:"http://correlatesofwar.org/data-sets/MIDs/mid-level/at_download/file",
  filename:"MIDB_4.2.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"MID Narratives, 1993-2001",
  published:date({year:2015, month:1, day:9}),
  purpose:"Narratives for 1993-2001 MIDs containing a brief prose summary of key actors and actions.",
  url:"http://correlatesofwar.org/data-sets/MIDs/mid-level/at_download/file",
  filename:"MID_Narratives_1993-2001.pdf"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"MID Narratives, 2002-2010",
  published:date({year:2015, month:1, day:9}),
  purpose:" Narratives for 2002-2010 MIDs containing a brief prose summary of key actors and actions.",
  url:"http://correlatesofwar.org/data-sets/MIDs/mid-level/at_download/file",
  filename:"MID_Narratives_2002-2010.pdf"
})
// Incident-level data and documents
CREATE (d)-[:PROVIDES]->(:File{
  name:"MII Codebook",
  version:toFloat(4.0),
  published:date({year:2013, month:12, day:13}),
  purpose:"Main codebook for the MID 4.0 incident data sets, describing file formats and listing variables contained in the MIDI and MIDIP data files.",
  url:"http://correlatesofwar.org/data-sets/MIDs/incident-level/at_download/file",
  filename:"MII_v4.0_Codebook.pdf"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"MII Incidents Data",
  version:toFloat(4.01),
  published:date({year:2013, month:12, day:13}),
  updated:date({year:2014, month:3, day:31}),
  purpose:"Data on incidents within MIDs from 1993-2010 (along with disputes ongoing as of 12/31/1992), at the incident level. Contains one record per militarized incident.",
  url:"http://correlatesofwar.org/data-sets/MIDs/incident-level/at_download/file",
  filename:"MIDI_4.01.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"MII participants Data",
  version:toFloat(4.01),
  published:date({year:2013, month:12, day:13}),
  updated:date({year:2014, month:3, day:31}),
  purpose:"Data on incidents within MIDs from 1993-2010 (along with disputes ongoing as of 12/31/1992), at the incident-participant level. Contains one record per participant in each incident.",
  url:"http://correlatesofwar.org/data-sets/MIDs/incident-level/at_download/file",
  filename:"MIDIP_4.01.csv"
});

// NOTE: Remove the "W" from the end of link1/link2/link3 fields in the data. It's irrelevant to the dataset in this
// format and is too complicated to parse/manipulate on the fly.
// Step 1: link dataset and create facts about disputes...
MATCH (d:Dataset{filename:"MIDA_4.2.csv"})
LOAD CSV WITH HEADERS FROM "file:///MIDA_4.2.csv" AS row
CREATE (d)-[c:CONTRIBUTES{asOf:d.updated, version:row.version}]->(f:Fact{
  name:"Dispute",
  from:date({year:toInteger(row.styear), month:toInteger(row.stmon)}),
  until:date({year:toInteger(row.endyear), month:toInteger(row.endmon)}),
  durationMax:duration('P'+row.maxdur+'D'),
  durationMin:duration('P'+row.mindur+'D'),
  reciprocalDispute:toBoolean(False),
  sideAcount:toInteger(row.numa),
  sideBcount:toInteger(row.numb),
  ongoingAfter2010:toBoolean(False)
  })-[a:ABOUT]->(i:Dispute{numberV3:row.dispnum3})
FOREACH (v in CASE WHEN row.dispnum4<>"-9" THEN [1] ELSE [] END | SET i.numberV4 = row.dispnum4) ;

// Step 2: expand the facts with more data
MATCH (d:Dataset{filename:"MIDA_4.2.csv"})
LOAD CSV WITH HEADERS FROM "file:///MIDA_4.2.csv" AS row
MATCH (d)-[:CONTRIBUTES]-(f:Fact)-[:ABOUT]-(i:Dispute{numberV3:row.dispnum3})
WITH *,
CASE row.outcome 
  WHEN "1" THEN "Victory for side A"
  WHEN "2" THEN "Victory for side B"
  WHEN "3" THEN "Yield by side A"
  WHEN "4" THEN "Yield by side B"
  WHEN "5" THEN "Stalemate"
  WHEN "6" THEN "Compromise"
  WHEN "7" THEN "Released"
  WHEN "8" THEN "Unclear"
  WHEN "9" THEN "Joins ongoing war"
  ELSE "Missing"
  END AS out,
CASE row.settle
  WHEN "1" THEN "Negotiated"
  WHEN "2" THEN "Imposed"
  WHEN "3" THEN "None"
  WHEN "4" THEN "Unclear"
  ELSE "Missing"
  END AS sett,
CASE row.fatality
  WHEN "0" THEN "None"
  WHEN "1" THEN "1-25 deaths"
  WHEN "2" THEN "26-100 deaths"
  WHEN "3" THEN "101-250 deaths"
  WHEN "4" THEN "251-500 deaths"
  WHEN "5" THEN "501-999 deaths"
  WHEN "6" THEN "> 999 deaths"
  ELSE "Missing"
  END AS fat,
CASE row.hiact
  WHEN "0"  THEN "No militarized action"
  WHEN "1"  THEN "Threat to use force"
  WHEN "2"  THEN "Threat to blockade"
  WHEN "3"  THEN "Threat to occupy territory"
  WHEN "4"  THEN "Threat to declare war"
  WHEN "5"  THEN "Threat to use CBR weapons"
  WHEN "6"  THEN "Threat to join"
  WHEN "7"  THEN "Show of force"
  WHEN "8"  THEN "Alert"
  WHEN "9"  THEN "Nuclear alert"
  WHEN "10" THEN "Mobilization"
  WHEN "11" THEN "Fortify border"
  WHEN "12" THEN "Border violation"
  WHEN "13" THEN "Blockade"
  WHEN "14" THEN "Occupation of territory"
  WHEN "15" THEN "Seizure"
  WHEN "16" THEN "Attack"
  WHEN "17" THEN "Clash"
  WHEN "18" THEN "Declaration of war"
  WHEN "19" THEN "Use of CBR weapons"
  WHEN "20" THEN "Begin interstate war"
  WHEN "21" THEN "Join interstate war"
  ELSE "Missing"
END AS hia,
CASE row.hostlev
  WHEN "1" THEN "No militarized action"
  WHEN "2" THEN "Threat to use force"
  WHEN "3" THEN "Display of force"
  WHEN "4" THEN "Use of force"
  WHEN "5" THEN "War"
  ELSE "Missing"
END AS hos
FOREACH (var IN CASE WHEN row.outcome<>"-9" THEN [1] ELSE [] END | SET f.outcome = out )
FOREACH (var IN CASE WHEN row.settle<>"-9" THEN [1] ELSE [] END | SET f.settlement = sett )
FOREACH (var IN CASE WHEN row.fatality<>"-9" THEN [1] ELSE [] END | SET f.fatalityLevel = fat )
FOREACH (var IN CASE WHEN row.hiact<>"-9" THEN [1] ELSE [] END | SET f.highestAction = hia )
FOREACH (var IN CASE WHEN row.hostlev<>"-9" THEN [1] ELSE [] END | SET f.hostilityLevel = hos )
FOREACH (var IN CASE WHEN row.stday<>"-9" THEN [1] ELSE [] END | SET f.from = date({
  year:toInteger(row.styear), month:toInteger(row.stmon), day:toInteger(row.stday)}) )
FOREACH (var IN CASE WHEN row.endday<>"-9" THEN [1] ELSE [] END | SET f.until = date({
  year:toInteger(row.endyear), month:toInteger(row.endmon), day:toInteger(row.endday)}) )
FOREACH (var IN CASE WHEN row.recip='1' THEN [1] ELSE [] END | SET f.reciprocalDispute = toBoolean(True) )
FOREACH (var IN CASE WHEN row.ongo2010='1' THEN [1] ELSE [] END | SET f.ongoingAfter2010 = toBoolean(True) )
FOREACH (var IN CASE WHEN row.fatalpre<>"-9" THEN [1] ELSE [] END | SET f.preciseFatalities = row.fatalpre )

// Finally, link disputes by the link1/link2/link3 values
MATCH (d:Dataset{filename:"MIDA_4.2.csv"})
LOAD CSV WITH HEADERS FROM "file:///MIDA_4.2.csv" AS row
MATCH (d)-[:CONTRIBUTES]-(f:Fact)-[:ABOUT]-(i:Dispute{numberV3:row.dispnum3})
MATCH (i1:Dispute{numberV3:row.link1}), (i2:Dispute{numberV3:row.link2}), (i3:Dispute{numberV3:row.link3})
FOREACH (var IN CASE WHEN row.link1<>'0' THEN [1] ELSE [] END | CREATE (d)-[c:CONTRIBUTES{
  asOf:d.updated, version:row.version}]->(f1:Fact{linkTo:row.link1}) 
  CREATE (i)-[:LINKED]->(f1)-[:LINKED_TO]->(i1) )
FOREACH (var IN CASE WHEN row.link2<>'0' THEN [1] ELSE [] END | CREATE (d)-[c:CONTRIBUTES{
  asOf:d.updated, version:row.version}]->(f2:Fact{linkTo:row.link2}) 
  CREATE (i)-[:LINKED]->(f2)-[:LINKED_TO]->(i2) )
FOREACH (var IN CASE WHEN row.link3<>'0' THEN [1] ELSE [] END | CREATE (d)-[c:CONTRIBUTES{
  asOf:d.updated, version:row.version}]->(f3:Fact{linkTo:row.link3}) 
  CREATE (i)-[:LINKED]->(f3)-[:LINKED_TO]->(i3) )

// MIDB, link states to MIDs
MATCH (d:Dataset{filename:"MIDB_4.2.csv"})
LOAD CSV WITH HEADERS FROM "file:///MIDB_4.2.csv" AS row
MATCH (s:State{cowcode:row.ccode}), (i:Dispute{numberV3:row.dispnum3})
CREATE (d)-[:CONTRIBUTES{asOf:d.updated, version:row.version}]->(f:Fact{
  name:"Dispute Participation",
  from:date({year:toInteger(row.styear), month:toInteger(row.stmon)}),
  until:date({year:toInteger(row.endyear), month:toInteger(row.endmon)})
  })-[:PARTICIPATED_IN]->(i)
CREATE (s)-[:PARTICIPATED]->(f)
WITH *,
CASE row.fatality
  WHEN "0" THEN "None"
  WHEN "1" THEN "1-25 deaths"
  WHEN "2" THEN "26-100 deaths"
  WHEN "3" THEN "101-250 deaths"
  WHEN "4" THEN "251-500 deaths"
  WHEN "5" THEN "501-999 deaths"
  WHEN "6" THEN "> 999 deaths"
  ELSE "Missing"
END AS fat,
CASE row.hiact
  WHEN "0"  THEN "No militarized action"
  WHEN "1"  THEN "Threat to use force"
  WHEN "2"  THEN "Threat to blockade"
  WHEN "3"  THEN "Threat to occupy territory"
  WHEN "4"  THEN "Threat to declare war"
  WHEN "5"  THEN "Threat to use CBR weapons"
  WHEN "6"  THEN "Threat to join"
  WHEN "7"  THEN "Show of force"
  WHEN "8"  THEN "Alert"
  WHEN "9"  THEN "Nuclear alert"
  WHEN "10" THEN "Mobilization"
  WHEN "11" THEN "Fortify border"
  WHEN "12" THEN "Border violation"
  WHEN "13" THEN "Blockade"
  WHEN "14" THEN "Occupation of territory"
  WHEN "15" THEN "Seizure"
  WHEN "16" THEN "Attack"
  WHEN "17" THEN "Clash"
  WHEN "18" THEN "Declaration of war"
  WHEN "19" THEN "Use of CBR weapons"
  WHEN "20" THEN "Begin interstate war"
  WHEN "21" THEN "Join interstate war"
  ELSE "Missing"
END AS hia,
CASE row.hostlev
  WHEN "1" THEN "No militarized action"
  WHEN "2" THEN "Threat to use force"
  WHEN "3" THEN "Display of force"
  WHEN "4" THEN "Use of force"
  WHEN "5" THEN "War"
  ELSE "Missing"
END AS hos,
CASE row.revtype1
  WHEN "0" THEN "Not Applicable"
  WHEN "1" THEN "Territory"
  WHEN "2" THEN "Policy"
  WHEN "3" THEN "Regime/Government"
  WHEN "4" THEN "Other"
  ELSE "Missing"
END AS rev1,
CASE row.revtype2
  WHEN "0" THEN "Not Applicable"
  WHEN "1" THEN "Territory"
  WHEN "2" THEN "Policy"
  WHEN "3" THEN "Regime/Government"
  WHEN "4" THEN "Other"
  ELSE "Missing"
END AS rev2
FOREACH (var IN CASE WHEN row.fatality<>"-9" THEN [1] ELSE [] END | SET f.fatalityLevel = fat )
FOREACH (var IN CASE WHEN row.hiact<>"-9" THEN [1] ELSE [] END | SET f.highestAction = hia )
FOREACH (var IN CASE WHEN row.hostlev<>"-9" THEN [1] ELSE [] END | SET f.hostilityLevel = hos )
FOREACH (var IN CASE WHEN row.stday<>"-9" THEN [1] ELSE [] END | SET f.from = date({
  year:toInteger(row.styear), month:toInteger(row.stmon), day:toInteger(row.stday)}) )
FOREACH (var IN CASE WHEN row.endday<>"-9" THEN [1] ELSE [] END | SET f.until = date({
  year:toInteger(row.endyear), month:toInteger(row.endmon), day:toInteger(row.endday)}) )
FOREACH (var IN CASE WHEN row.fatalpre<>"-9" THEN [1] ELSE [] END | SET f.preciseFatalities = row.fatalpre )
FOREACH (var IN CASE WHEN row.sidea="1" THEN [1] ELSE [] END | SET f.sideA = toBoolean(True) )
FOREACH (var IN CASE WHEN row.revstate="1" THEN [1] ELSE [] END | SET f.revisionistState = toBoolean(True) )
FOREACH (var IN CASE WHEN row.orig="1" THEN [1] ELSE [] END | SET f.originatedDistpute = toBoolean(True) )
FOREACH (var IN CASE WHEN row.revtype1<>"-9" AND row.revtype1<>"0" THEN [1] ELSE [] END | SET f.revisionTypeOne = rev1 )
FOREACH (var IN CASE WHEN row.revtype2<>"-9" AND row.revtype2<>"0" THEN [1] ELSE [] END | SET f.revisionTypeTwo = rev2 );

// TODO: MID Incidents, 2130

// TODO: MID Incident Participation 2132

// TODO: MID Locations, 2134

// TODO: COW War Data, 2136

// TODO: Territorial Change, 2138

// TODO: Colonial and Dependency Contiguity, 2384

// TODO: Direct Contiguity, 2336

// TODO: Territorial Change, 2297

  ////////////////////////////////////////////////////
 //               TESTED, COMPLETE                 //
////////////////////////////////////////////////////


// MID Locations
CREATE (d:Source{
  project:"Correlates of War", 
  name:"MIDLOC", 
  version:toFloat(1.1),
  published:date({year:2010, month:1}),
//  validFrom:date({year:1816, month:1, day:1}),
//  falidUntil:date({year:2016, month:12, day:31}),
  citation:"Braithwaite, Alex. 2010. 'MIDLOC: Introducing the Militarized Interstate Dispute (MID) Location Dataset.' Journal of Peace Research 47: 91-98.",
  url:"http://correlatesofwar.org/data-sets/MIDLOC",
  host:"Alex Braithwaite (University of Arizona)",
  poc:"Alex Braithwaite (abraith@arizona.edu)",
  overview:"The Militarized Interstate Dispute Location (MIDLOC) dataset details the precise geographic onset location of Militarized Interstate Disputes (MIDs) in the post-Napoleonic era (from 1816-2001).  The MIDLOC data offer a single point location to represent the onset of each individual MID between 1816 and 1992.  For the period 1993-2001, the data are more detailed, identifying a single point location for individual incidents within each MID.  Following common convention, latitude and longitude point coordinates are recorded for each observation.  Latitude is measured as the angular distance, in decimalized degrees (DD), of a point north or south of the equator.  Similarly, longitude is measured as the angular distance, in decimalized degrees (DD), of a point east or west of the Prime (Greenwich) Meridian. \nThere are a total of 3865 individual MIDLOC records. This is comprised of recorded onset locations for 2240 of 2332 independent MIDs from the MID 3.0 dataset—96% data coverage. 1939 of these 2240 took place between 1816 and 1992 and 301 between 1993 and 2001.  In addition to the MID-level data, this dataset also includes incident-level location data for the period 1993-2001.  There are 2122 incident-level records that comprise the 301 MIDs during this period.  196 of these 2122 records currently contain missing values.  Of these, however, only 3 are missing locations for the onset incident within the MID.",
  purpose:"This data set records the geographic locations of MIDs in latitude/longitude coordinates. Version 1.1 covers the 1816-2001 period."
  })
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"MIDLOC Data",
  version:toFloat(1.1),
  published:date({year:2010, month:1}),
  purpose:"Data on the Militarized Interstate Dispute Location, 1816-2001",
  note:"values of -9 or -9999 designate missing values, and must be treated as such for appropriate analysis.",
  url:"http://correlatesofwar.org/data-sets/MIDLOC/midloc-1.1/at_download/file",
  filename:"MIDLOC_1.1.csv",
  bytesize:toInteger(327366)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"MIDLOC Codebook",
  version:toFloat(1.1),
  published:date({year:2010, month:1}),
  purpose:"Documentation for the data set",
  note:"values of -9 or -9999 designate missing values, and must be treated as such for appropriate analysis.",
  url:"http://correlatesofwar.org/data-sets/MIDLOC/midloc-v1-1-codebook/at_download/file",
  filename:"MIDLOC_v1.1_codebook.pdf",
  bytesize:toInteger(95951)
});

// TODO: COW War Data
// COW War Data
CREATE (d:Source{
  project:"Correlates of War", 
  name:"War Data v4.0",
  version:toFloat(4.0),
  published:date({year:2010, month:3}),
  //validFrom:date({year:1816, month:1, day:1}),
  //falidUntil:date({year:2016, month:12, day:31}),
  citation:"Sarkees, Meredith Reid and Frank Wayman (2010). Resort to War: 1816 - 2007. Washington DC: CQ Press.",
  url:"http://correlatesofwar.org/data-sets/COW-war",
  host:["Meredith Sarkees (Global Women's Leadership in International Security)", "Frank Wayman (University of Michigan-Dearborn)"],
  poc:["sarkees@sbcglobal.net","fwayman@umich.edu"],
  overview:"The COW Project introduced COW Wars v4.0, 1816-2007 in 2010. The paper 'The COW Typology of War: Defining and Categorizing Wars (Version 4 of the Data)' by Meredith Reid Sarkees gives an overview of the COW war typology, the descriptions of the basic variables, coding rules and some of the changes since 'Resort to Arms.' In March 2010, the New COW War List was released. On June 30, 2010, the Non-State War Data (v4.0) became available. On October 28, 2010, the Intra-State War Data (v4.0) was released. On March 1, 2011, the Inter-State War Data (v4.0) became available online. Finally, we released the Extra-State War Data (v4.0) on December 8, 2011."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Non-State War Data",
  version:toFloat(4.0),
  published:date({year:2010, month:6, day:30}),
  purpose:"Previously, the Correlates of War (COW) Project has examined only wars that involved the government of a member of the interstate system (a state) in one form or another. The inclusion of non-state wars in the data presented here represents an attempt to broaden our understanding of war by including wars between or among non-state entities. Such entities include governments of other types of geopolitical units (GPUs), such as dependencies or non-state autonomous entities, that do not meet the criteria of system membership. They also might involve nonterritorial entities (NTEs) or non-state armed groups (NSAs) that have no defined territorial base.",
  note:"Please note the distinction between the “-8” and “-9” codes as specified in the codebook.",
  url:"http://correlatesofwar.org/data-sets/COW-war/non-state-war-data-1/at_download/file",
  filename:"Non-StateWarData_v4.0.csv",
  bytesize:toInteger(7267)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Non-State Wars List",
  version:toFloat(4.0),
  published:date({year:2010, month:6, day:30}),
  purpose:"The list of Non-State Wars.",
  url:"http://correlatesofwar.org/data-sets/COW-war/non-state-wars-list-1/at_download/file",
  filename:"Non-StateWarsList.pdf",
  bytesize:toInteger(95054)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Non-State Wars Codebook",
  version:toFloat(4.0),
  published:date({year:2010, month:6, day:30}),
  purpose:"The codebook v4.0 for the Non-State War Data set.",
  url:"http://correlatesofwar.org/data-sets/COW-war/non-state-wars-codebook-1/at_download/file",
  filename:"Non-StateWars_Codebook.pdf",
  bytesize:toInteger(85691)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Intra-State Wars Data",
  version:toFloat(4.1),
  published:date({year:2010, month:10, day:28}),
  note:"Please note the distinction between the “-8” and “-9” codes as specified in the codebook.",
  purpose:"The Correlates of War (COW) Project has utilized a classification of wars that is based upon the status of territorial entities, in particular focusing on those that are classified as members of the inter-state system (referred to as “states”). This dataset encompasses wars that predominantly take place within the recognized territory of a state, or intra-state wars.",
  url:"http://correlatesofwar.org/data-sets/COW-war/intra-state-war-data-v4-1/at_download/file",
  filename:"Intra-StateWarData_v4.1.csv",
  bytesize:toInteger(54987)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Intra-State Wars Codebook",
  verion:toFloat(4.0),
  published:date({year:2010, month:10, day:28}),
  purpose:"The codebook v4.0 for the Intra-State War Data set.",
  url:"Intra-StateWars_Codebook.pdf",
  filename:"http://correlatesofwar.org/data-sets/COW-war/intra-state-war-data-codebook/at_download/file",
  bytesize:toInteger(99231)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Inter-State Wars Data",
  version:toFloat(4.0),
  published:date({year:2011, month:3, day:1}),
  purpose:"The Correlates of War (COW) Project has utilized a classification of wars that is based upon the status of territorial entities, in particular focusing on those that are classified as members of the inter-state system (referred to as “states”). This dataset encompasses wars that take place between or among the recognized states, or inter-state wars.",
  note:"Please note the distinction between the “-8” and “-9” codes as specified in the codebook.",
  url:"http://correlatesofwar.org/data-sets/COW-war/inter-state-war-data/at_download/file",
  filename:"Inter-StateWarData_v4.0.csv",
  bytesize:toInteger(31698)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Inter-State Wars List",
  version:toFloat(4.0),
  published:date({year:2011, month:3, day:1}),
  purpose:"The list of Inter-State Wars.",
  url:"http://correlatesofwar.org/data-sets/COW-war/inter-state-wars-list/at_download/file",
  filename:"Inter-StateWarsList.pdf",
  bytesize:toInteger(136717)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Inter-State Wars Codebook",
  purpose:"The codebook v4.0 for the Inter-State War Data set.",
  version:toFloat(4.0),
  published:date({year:2011, month:3, day:1}),
  url:"http://correlatesofwar.org/data-sets/COW-war/inter-state-wars-codebook/at_download/file",
  filename:"Inter-StateWars_Codebook.pdf",
  bytesize:toInteger(82241)
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Extra-State Wars Data",
  version:toFloat(4.0),
  published:date({year:2011, month:12, day:8}),
  note:"Please note the distinction between the “-8” and “-9” codes as specified in the codebook.",
  purpose:"The Correlates of War (COW) Project has utilized a classification of wars that is based upon the status of territorial entities, in particular focusing on those that are classified as members of the inter-state system (referred to as “states”). This dataset encompasses wars in the middle category - wars that take place between a state(s) and a nonstate entity outside the borders of the state, or extra-state wars.",
  url:"http://correlatesofwar.org/data-sets/COW-war/extra-state-war-data/at_download/file",
  filename:"Extra-StateWarData_v4.0.csv",
  bytesize:toInteger(23068)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Extra-State Wars Codebook",
  version:toFloat(4.0),
  published:date({year:2011, month:12, day:8}),
  purpose:"The codebook v4.0 for the Extra-State War Data set.",
  url:"http://correlatesofwar.org/data-sets/COW-war/extra-state-wars-codebook/at_download/file",
  filename:"Extra-StateWars_Codebook.pdf",
  bytesize:toInteger(106163)
});

// TODO: Territorial Change
// Territorial Change
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Territorial Change", 
  version:toFloat(5.0),
  published:date({year:2015, month:3, day:21}),  
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2014, month:12, day:31}),
  citation:"Tir, Jaroslav, Philip Schafer, Paul Diehl, and Gary Goertz. 1998. 'Territorial Changes, 1816-1996: Procedures and Data' Conflict Management and Peace Science 16:89-97.",
  host:["Paul Diehl (University of Illinois)", "Jaroslav Tir (University of Colorado-Boulder)"],
  poc:["Paul Diehl (pdiehl@uiuc.edu)", "Jaroslav Tir (jtir@colorado.edu)"],
  url:"http://correlatesofwar.org/data-sets/territorial-change",
  overview:"The territorial change dataset is the result of the effort to identify and code all territorial changes involving at least one nation-state (as defined by the Correlates of War project) for the period 1816-2014. The data are restricted to territorial changes that involve at least one recognized (by COW) nation-state. Both the nation states and the non-nation states involved in territorial changes are regarded as political entities. This dataset contains information on the entities involved, the gaining side, the losing side, the territory exchanged, as well as the type and date of the exchange. \nOn March 21, 2015, we released the fifth version of this data set (that covers 1816-2014). This is an update of the earlier territorial change data set that ended in 2008. In version 5, three new cases were added",
  purpose:"This data set records all peaceful and violent changes of territory from 1816-2014. This data set is hosted by Paul Diehl, University of Illinois and Jaroslav Tir, Colorado-Boulder."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Territorial Change Data",
  version:toFloat(5.0),
  published:date({year:2015, month:3, day:21}),  
  purpose:"The data in comma-separated variable ASCII format",
  url:"http://correlatesofwar.org/data-sets/territorial-change/territorial-change-data/at_download/file",
  filename:"tc2014.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Territorial Change Coding Manual",
  version:toFloat(5.0),
  published:date({year:2015, month:3, day:21}),  
  purpose:"The main territorial change coding manual. Appendixes A, B and C give details on changes introduced in v3.0, v4.0 and v4.01 respectively.",
  url:"http://correlatesofwar.org/data-sets/territorial-change/territorial-change-data/at_download/file",
  filename:"tcmanual.pdf"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Political Entities",
  version:toFloat(5.0),
  published:date({year:2009, month:6, day:23}),
  purpose:"The list of political entities (colonies, dependencies, and possessions)",
  url:"http://correlatesofwar.org/data-sets/territorial-change/territorial-change-data/at_download/file",
  filename:"Entities.pdf"
});

// TODO: Direct Contiguity
// Direct Contiguity
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Direct Contiguity", 
  version:toFloat(3.2),
  published:date({year:2017, month:2, day:13}),
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2016, month:12, day:31}),
  citation:["Correlates of War Project. Direct Contiguity Data, 1816-2016. Version 3.2.", 
    "Stinnett, Douglas M., Jaroslav Tir, Philip Schafer, Paul F. Diehl, and Charles Gochman. 2002. 'The Correlates of War Project Direct Contiguity Data, Version 3.'' Conflict Management and Peace Science 19(2):58-66.", "Charles S. Gochman, 1991, 'Interstate Metrics: Conceptualizing, Operationalizing, and Measuring the Geographic Proximity of States since the Congress of Vienna,' International Interactions 17(1): 93-112. "],
  host:"Paul Hensel (University of North Texas)",
  poc:"Paul Hensel (phensel@unt.edu)",
  url:"http://correlatesofwar.org/data-sets/direct-contiguity",
  overview:"Version 3.2 of the COW Direct Contiguity data identifies all direct contiguity relationships between states in the international system from 1816 through 2016. The classification system for contiguous dyads is comprised of five categories, one for land contiguity and four for water contiguity. Land contiguity is defined as the intersection of the homeland territory of the two states in the dyad, either through a land boundary or a river (such as the Rio Grande in the case of the US-Mexico border). Water contiguity is divided into four categories, based on a separation by water of 12, 24, 150, and 400 miles.",
  purpose:"The Direct Contiguity data set registers the land and sea borders of all states since the Congress of Vienna, and covers 1816-2016. This data set is hosted by Paul Hensel, University of North Texas."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Direct Contiguity Data",
  version:toFloat(3.2),
  published:date({year:2017, month:2, day:13}),
  purpose:"The master data file (with one entry per contiguity relationship)",
  url:"http://correlatesofwar.org/data-sets/direct-contiguity/direct-contiguity-v3-2/at_download/file",
  filename:"contdir.csv"
})
 CREATE (d)-[:PROVIDES]->(:Dataset{
   name:"Direct Contiguity Directed Dyads",
   version:toFloat(3.2),
  published:date({year:2017, month:2, day:13}),
   purpose:"A directed dyad-year-level version of the master data",
   url:"http://correlatesofwar.org/data-sets/direct-contiguity/direct-contiguity-v3-2/at_download/file",
   filename:"contdird.csv"
 })
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"State-Year Direct Contiguity",
  version:toFloat(3.2),
  published:date({year:2017, month:2, day:13}),
  purpose:"A state-year-level data set calculated from the master data",
  url:"http://correlatesofwar.org/data-sets/direct-contiguity/direct-contiguity-v3-2/at_download/file",
  filename:"contdirs.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Direct Contiguity Codebook",
  version:toFloat(3.2),
  published:date({year:2017, month:2, day:13}),
  purpose:"The codebook for Version 3.2 for the Direct Contiguity data.",
  url:"http://correlatesofwar.org/data-sets/direct-contiguity/direct-contiguity-v3-2/at_download/file",
  filename:"Direct Contiguity Codebook.pdf"
});

// Colonial and Dependency Contiguity
CREATE (d:Source{
  project:"Correlates of War", 
  name:"Colonial Dependency Contiguity", 
  version:toFloat(3.1),
  published:date({year:2017, month:2, day:16}),
  validFrom:date({year:1816, month:1, day:1}),
  falidUntil:date({year:2016, month:12, day:31}),
  citation:"Correlates of War Project. Colonial Contiguity Data, 1816-2016. Version 3.1. ",
  host:"Paul Hensel (University of North Texas)",
  poc:"Paul Hensel (phensel@unt.edu)",
  url:"http://correlatesofwar.org/data-sets/colonial-dependency-contiguity",
  overview:"Version 3.1 of the Correlates of War Colonial/Dependency Contiguity data identifies all contiguity relationships between states in the international system from 1816 through 2016 through their colonies or dependencies. That is, if two dependencies of two states are contiguous, or if one state is contiguous to a dependency of another, the data set reports a contiguity relationship between the two main states (with appropriate codes identifying the relevant dependent entity/entities). The classification system for contiguous dyads is comprised of five categories, one for land contiguity and four for water contiguity. Land contiguity is defined as the intersection of the homeland territory of states/colonies/dependencies in the dyad, either through a land boundary or a river. Water contiguity is divided into four categories, based on a separation by water of 12, 24, 150, and 400 miles.",
  purpose:"The Colonial/Dependency Contiguity data set registers contiguity relationships between the colonies/dependencies of states (by land and by sea up to 400 miles) from 1816-2016."
  })
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Colonial Contiguity Data",
  version:toFloat(3.1),
  published:date({year:2017, month:2, day:16}),
  purpose:"The master data file (with one entry per contiguity relationship)",
  url:"http://correlatesofwar.org/data-sets/colonial-dependency-contiguity/colonial-dependency-contiguity-v3-1/at_download/file",
  filename:"ContCol.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"Colonial Contiguity Dyads Data",
  version:toFloat(3.1),
  published:date({year:2017, month:2, day:16}),
  purpose:"A dyad-year-level summary data set for colonial contiguity",
  url:"http://correlatesofwar.org/data-sets/colonial-dependency-contiguity/colonial-dependency-contiguity-v3-1/at_download/file",
  filename:"ContcolD.csv"
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"State-year-level Colonial Contiguity Data",
  version:toFloat(3.1),
  published:date({year:2017, month:2, day:16}),
  purpose:"A state-year-level summary data set for colonial contiguity",
  url:"http://correlatesofwar.org/data-sets/colonial-dependency-contiguity/colonial-dependency-contiguity-v3-1/at_download/file",
  filename:"ContColS.csv"
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"Colonial Contiguity Codebook",
  version:toFloat(3.1),
  published:date({year:2017, month:2, day:16}),
  purpose:"Documentation for the colonial contiguity data set.",
  url:"http://correlatesofwar.org/data-sets/colonial-dependency-contiguity/colonial-dependency-contiguity-v3-1/at_download/file",
  filename:"Colonial Contiguity Codebook.pdf"
})
MATCH (f:File{filename:"Entities.pdf"})
CREATE (d)-[:PROVIDES]->(f);


// ################################################################################################################### //
// ## The script below is for importing the state-to-IGO relationships from the IGO_stateunit data.                 ## //
// ## It's isolated down here because it's nearly 8,000 lines long                                                  ## //
// ## There is a small script for each column of IGO data. It does not create connections for missing or null relations//
// ## There are 529 columns of IGOs, so this script runs 529 times, once for each IGO. ############################### //
//    The data model follows the same pattern as other fact, subject, object year datasets.
//  (PC1)-[c]-(fact1)<-[:MEMBER]-(state)         (fact2)<-[c]-(PC2)
// (year)-[]-/      \-[:MEMBER_OF]-(IGO)-[PART]-/      \-[PART_OF]->(system)
// 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAAID"})
WITH *,
CASE row.AAAID
  WHEN "1" THEN "Full Member"
  WHEN "2" THEN "Associate Member"
  WHEN "3" THEN "Observer"
  WHEN "0" THEN "Not a Member"
  WHEN "-9" THEN "Missing Data"
  END AS membership
FOREACH (datum IN CASE WHEN row.AAAID<>"-1" OR row.AAID<>"-9" THEN [1] ELSE [] END | CREATE (d)-[:CONTRIBUTES]->(f:Fact{
  name:"IGO Membership", 
  membershipCode:row.AAAID, 
  status:membership
  })-[:DURING]->(p) CREATE (s)-[m:MEMBERSHIP]->(f)-[:MEMBER_OF]->(i) )
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAB"})
WITH *,
CASE row.AAB
  WHEN "1" THEN "Full Member"
  WHEN "2" THEN "Associate Member"
  WHEN "3" THEN "Observer"
  WHEN "0" THEN "Not a Member"
  WHEN "-9" THEN "Missing Data"
  END AS membership
FOREACH (datum IN CASE WHEN row.AAB<> "-1" OR row.ABB<>"-9" THEN [1] ELSE [] END | 
  CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", membershipCode:row.AAB, status:membership})-[:DURING]->(p)
  CREATE (s)-[m:MEMBERSHIP]->(f)-[:MEMBER_OF]->(i)
)
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAAID"})
 WITH *,
 CASE row.AAAID
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AAAID<> "-1" OR row.AAAID <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AAAID})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAB"})
 WITH *,
 CASE row.AAB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AAB<> "-1" OR row.AAB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AAB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AACB"})
 WITH *,
 CASE row.AACB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AACB<> "-1" OR row.AACB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AACB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AACarib"})
 WITH *,
 CASE row.AACarib
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AACarib<> "-1" OR row.AACarib <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AACarib})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AALCO"})
 WITH *,
 CASE row.AALCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AALCO<> "-1" OR row.AALCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AALCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AARO"})
 WITH *,
 CASE row.AARO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AARO<> "-1" OR row.AARO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AARO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AATA"})
 WITH *,
 CASE row.AATA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AATA<> "-1" OR row.AATA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AATA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AATPO"})
 WITH *,
 CASE row.AATPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AATPO<> "-1" OR row.AATPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AATPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ABEDA"})
 WITH *,
 CASE row.ABEDA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ABEDA<> "-1" OR row.ABEDA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ABEDA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ABEPSEAC"})
 WITH *,
 CASE row.ABEPSEAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ABEPSEAC<> "-1" OR row.ABEPSEAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ABEPSEAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACC"})
 WITH *,
 CASE row.ACC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACC<> "-1" OR row.ACC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACCT"})
 WITH *,
 CASE row.ACCT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACCT<> "-1" OR row.ACCT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACCT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACDT"})
 WITH *,
 CASE row.ACDT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACDT<> "-1" OR row.ACDT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACDT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACI"})
 WITH *,
 CASE row.ACI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACI<> "-1" OR row.ACI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACML"})
 WITH *,
 CASE row.ACML
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACML<> "-1" OR row.ACML <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACML})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACP"})
 WITH *,
 CASE row.ACP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACP<> "-1" OR row.ACP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACPEU"})
 WITH *,
 CASE row.ACPEU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACPEU<> "-1" OR row.ACPEU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACPEU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACS"})
 WITH *,
 CASE row.ACS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACS<> "-1" OR row.ACS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACSO"})
 WITH *,
 CASE row.ACSO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACSO<> "-1" OR row.ACSO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACSO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACSSRB"})
 WITH *,
 CASE row.ACSSRB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACSSRB<> "-1" OR row.ACSSRB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACSSRB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACU"})
 WITH *,
 CASE row.ACU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACU<> "-1" OR row.ACU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACWL"})
 WITH *,
 CASE row.ACWL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ACWL<> "-1" OR row.ACWL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ACWL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFESD"})
 WITH *,
 CASE row.AFESD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFESD<> "-1" OR row.AFESD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFESD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFEXIMB"})
 WITH *,
 CASE row.AFEXIMB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFEXIMB<> "-1" OR row.AFEXIMB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFEXIMB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFGEC"})
 WITH *,
 CASE row.AFGEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFGEC<> "-1" OR row.AFGEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFGEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFPU"})
 WITH *,
 CASE row.AFPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFPU<> "-1" OR row.AFPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFRAND"})
 WITH *,
 CASE row.AFRAND
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFRAND<> "-1" OR row.AFRAND <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFRAND})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFSPC"})
 WITH *,
 CASE row.AFSPC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFSPC<> "-1" OR row.AFSPC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFSPC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFTE"})
 WITH *,
 CASE row.AFTE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AFTE<> "-1" OR row.AFTE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AFTE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AGC"})
 WITH *,
 CASE row.AGC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AGC<> "-1" OR row.AGC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AGC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AGPUNDO"})
 WITH *,
 CASE row.AGPUNDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AGPUNDO<> "-1" OR row.AGPUNDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AGPUNDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIC"})
 WITH *,
 CASE row.AIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AIC<> "-1" OR row.AIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIDC"})
 WITH *,
 CASE row.AIDC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AIDC<> "-1" OR row.AIDC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AIDC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIDO"})
 WITH *,
 CASE row.AIDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AIDO<> "-1" OR row.AIDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AIDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIOEC"})
 WITH *,
 CASE row.AIOEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AIOEC<> "-1" OR row.AIOEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AIOEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIPO"})
 WITH *,
 CASE row.AIPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AIPO<> "-1" OR row.AIPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AIPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AITIC"})
 WITH *,
 CASE row.AITIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AITIC<> "-1" OR row.AITIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AITIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ALO"})
 WITH *,
 CASE row.ALO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ALO<> "-1" OR row.ALO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ALO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMCO"})
 WITH *,
 CASE row.AMCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMCO<> "-1" OR row.AMCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMCOW"})
 WITH *,
 CASE row.AMCOW
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMCOW<> "-1" OR row.AMCOW <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMCOW})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMF"})
 WITH *,
 CASE row.AMF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMF<> "-1" OR row.AMF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMIPO"})
 WITH *,
 CASE row.AMIPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMIPO<> "-1" OR row.AMIPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMIPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMPTU"})
 WITH *,
 CASE row.AMPTU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMPTU<> "-1" OR row.AMPTU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMPTU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMSC"})
 WITH *,
 CASE row.AMSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMSC<> "-1" OR row.AMSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMU"})
 WITH *,
 CASE row.AMU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AMU<> "-1" OR row.AMU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AMU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ANZUS"})
 WITH *,
 CASE row.ANZUS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ANZUS<> "-1" OR row.ANZUS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ANZUS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOAD"})
 WITH *,
 CASE row.AOAD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AOAD<> "-1" OR row.AOAD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AOAD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOCRS"})
 WITH *,
 CASE row.AOCRS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AOCRS<> "-1" OR row.AOCRS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AOCRS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOMR"})
 WITH *,
 CASE row.AOMR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AOMR<> "-1" OR row.AOMR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AOMR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOPU"})
 WITH *,
 CASE row.AOPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AOPU<> "-1" OR row.AOPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AOPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AP"})
 WITH *,
 CASE row.AP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AP<> "-1" OR row.AP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APCC"})
 WITH *,
 CASE row.APCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APCC<> "-1" OR row.APCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APEC"})
 WITH *,
 CASE row.APEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APEC<> "-1" OR row.APEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APFIC"})
 WITH *,
 CASE row.APFIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APFIC<> "-1" OR row.APFIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APFIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APIBD"})
 WITH *,
 CASE row.APIBD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APIBD<> "-1" OR row.APIBD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APIBD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APO"})
 WITH *,
 CASE row.APO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APO<> "-1" OR row.APO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APPA"})
 WITH *,
 CASE row.APPA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APPA<> "-1" OR row.APPA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APPA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APT"})
 WITH *,
 CASE row.APT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APT<> "-1" OR row.APT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APTU"})
 WITH *,
 CASE row.APTU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.APTU<> "-1" OR row.APTU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.APTU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARC"})
 WITH *,
 CASE row.ARC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ARC<> "-1" OR row.ARC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ARC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARCAL"})
 WITH *,
 CASE row.ARCAL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ARCAL<> "-1" OR row.ARCAL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ARCAL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARIPO"})
 WITH *,
 CASE row.ARIPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ARIPO<> "-1" OR row.ARIPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ARIPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARPU"})
 WITH *,
 CASE row.ARPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ARPU<> "-1" OR row.ARPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ARPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASATP"})
 WITH *,
 CASE row.ASATP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASATP<> "-1" OR row.ASATP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASATP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASBLAC"})
 WITH *,
 CASE row.ASBLAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASBLAC<> "-1" OR row.ASBLAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASBLAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASCBC"})
 WITH *,
 CASE row.ASCBC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASCBC<> "-1" OR row.ASCBC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASCBC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASCRubber"})
 WITH *,
 CASE row.ASCRubber
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASCRubber<> "-1" OR row.ASCRubber <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASCRubber})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASEAN"})
 WITH *,
 CASE row.ASEAN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASEAN<> "-1" OR row.ASEAN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASEAN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASECNA"})
 WITH *,
 CASE row.ASECNA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASECNA<> "-1" OR row.ASECNA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASECNA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASEF"})
 WITH *,
 CASE row.ASEF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASEF<> "-1" OR row.ASEF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASEF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASPAC"})
 WITH *,
 CASE row.ASPAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ASPAC<> "-1" OR row.ASPAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ASPAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ATO"})
 WITH *,
 CASE row.ATO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ATO<> "-1" OR row.ATO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ATO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ATPC"})
 WITH *,
 CASE row.ATPC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ATPC<> "-1" OR row.ATPC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ATPC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AU"})
 WITH *,
 CASE row.AU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AU<> "-1" OR row.AU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AVRDC"})
 WITH *,
 CASE row.AVRDC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AVRDC<> "-1" OR row.AVRDC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AVRDC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AfDB"})
 WITH *,
 CASE row.AfDB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AfDB<> "-1" OR row.AfDB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AfDB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AfrOPDA"})
 WITH *,
 CASE row.AfrOPDA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AfrOPDA<> "-1" OR row.AfrOPDA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AfrOPDA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Africare"})
 WITH *,
 CASE row.Africare
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Africare<> "-1" OR row.Africare <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Africare})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AmCC"})
 WITH *,
 CASE row.AmCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AmCC<> "-1" OR row.AmCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AmCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Andean"})
 WITH *,
 CASE row.Andean
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Andean<> "-1" OR row.Andean <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Andean})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AralSea"})
 WITH *,
 CASE row.AralSea
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AralSea<> "-1" OR row.AralSea <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AralSea})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ArticC"})
 WITH *,
 CASE row.ArticC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ArticC<> "-1" OR row.ArticC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ArticC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AsDB"})
 WITH *,
 CASE row.AsDB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.AsDB<> "-1" OR row.AsDB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.AsDB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BALTBAT"})
 WITH *,
 CASE row.BALTBAT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BALTBAT<> "-1" OR row.BALTBAT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BALTBAT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BC"})
 WITH *,
 CASE row.BC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BC<> "-1" OR row.BC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BCSC"})
 WITH *,
 CASE row.BCSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BCSC<> "-1" OR row.BCSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BCSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BEF"})
 WITH *,
 CASE row.BEF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BEF<> "-1" OR row.BEF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BEF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BEN"})
 WITH *,
 CASE row.BEN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BEN<> "-1" OR row.BEN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BEN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BENELUX"})
 WITH *,
 CASE row.BENELUX
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BENELUX<> "-1" OR row.BENELUX <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BENELUX})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BESCC"})
 WITH *,
 CASE row.BESCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BESCC<> "-1" OR row.BESCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BESCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIISEF"})
 WITH *,
 CASE row.BIISEF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BIISEF<> "-1" OR row.BIISEF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BIISEF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIONET"})
 WITH *,
 CASE row.BIONET
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BIONET<> "-1" OR row.BIONET <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BIONET})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIPM"})
 WITH *,
 CASE row.BIPM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BIPM<> "-1" OR row.BIPM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BIPM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIS"})
 WITH *,
 CASE row.BIS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BIS<> "-1" OR row.BIS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BIS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BNDP"})
 WITH *,
 CASE row.BNDP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BNDP<> "-1" OR row.BNDP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BNDP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BOBP"})
 WITH *,
 CASE row.BOBP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BOBP<> "-1" OR row.BOBP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BOBP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BONN"})
 WITH *,
 CASE row.BONN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BONN<> "-1" OR row.BONN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BONN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BSEC"})
 WITH *,
 CASE row.BSEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.BSEC<> "-1" OR row.BSEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.BSEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAAD"})
 WITH *,
 CASE row.CAAD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAAD<> "-1" OR row.CAAD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAAD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAARC"})
 WITH *,
 CASE row.CAARC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAARC<> "-1" OR row.CAARC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAARC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAB"})
 WITH *,
 CASE row.CAB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAB<> "-1" OR row.CAB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CABI"})
 WITH *,
 CASE row.CABI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CABI<> "-1" OR row.CABI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CABI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CACB"})
 WITH *,
 CASE row.CACB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CACB<> "-1" OR row.CACB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CACB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CACI"})
 WITH *,
 CASE row.CACI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CACI<> "-1" OR row.CACI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CACI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAEC"})
 WITH *,
 CASE row.CAEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAEC<> "-1" OR row.CAEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAECC"})
 WITH *,
 CASE row.CAECC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAECC<> "-1" OR row.CAECC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAECC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAIPA"})
 WITH *,
 CASE row.CAIPA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAIPA<> "-1" OR row.CAIPA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAIPA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAMES"})
 WITH *,
 CASE row.CAMES
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAMES<> "-1" OR row.CAMES <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAMES})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAMRSD"})
 WITH *,
 CASE row.CAMRSD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAMRSD<> "-1" OR row.CAMRSD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAMRSD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAMSF"})
 WITH *,
 CASE row.CAMSF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CAMSF<> "-1" OR row.CAMSF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CAMSF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CARICOM"})
 WITH *,
 CASE row.CARICOM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CARICOM<> "-1" OR row.CARICOM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CARICOM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CARIFTA"})
 WITH *,
 CASE row.CARIFTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CARIFTA<> "-1" OR row.CARIFTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CARIFTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CARII"})
 WITH *,
 CASE row.CARII
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CARII<> "-1" OR row.CARII <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CARII})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CATC"})
 WITH *,
 CASE row.CATC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CATC<> "-1" OR row.CATC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CATC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CBFP"})
 WITH *,
 CASE row.CBFP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CBFP<> "-1" OR row.CBFP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CBFP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CBI"})
 WITH *,
 CASE row.CBI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CBI<> "-1" OR row.CBI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CBI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CBSS"})
 WITH *,
 CASE row.CBSS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CBSS<> "-1" OR row.CBSS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CBSS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CCNR"})
 WITH *,
 CASE row.CCNR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CCNR<> "-1" OR row.CCNR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CCNR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CCOM"})
 WITH *,
 CASE row.CCOM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CCOM<> "-1" OR row.CCOM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CCOM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CCPA"})
 WITH *,
 CASE row.CCPA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CCPA<> "-1" OR row.CCPA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CCPA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CComm"})
 WITH *,
 CASE row.CComm
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CComm<> "-1" OR row.CComm <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CComm})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CDB"})
 WITH *,
 CASE row.CDB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CDB<> "-1" OR row.CDB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CDB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEAO"})
 WITH *,
 CASE row.CEAO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEAO<> "-1" OR row.CEAO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEAO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEC"})
 WITH *,
 CASE row.CEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEC<> "-1" OR row.CEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEEPN"})
 WITH *,
 CASE row.CEEPN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEEPN<> "-1" OR row.CEEPN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEEPN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEFTA"})
 WITH *,
 CASE row.CEFTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEFTA<> "-1" OR row.CEFTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEFTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEI"})
 WITH *,
 CASE row.CEI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEI<> "-1" OR row.CEI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CELC"})
 WITH *,
 CASE row.CELC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CELC<> "-1" OR row.CELC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CELC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEMAC"})
 WITH *,
 CASE row.CEMAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEMAC<> "-1" OR row.CEMAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEMAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CENTO"})
 WITH *,
 CASE row.CENTO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CENTO<> "-1" OR row.CENTO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CENTO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEPGL"})
 WITH *,
 CASE row.CEPGL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CEPGL<> "-1" OR row.CEPGL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CEPGL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CERN"})
 WITH *,
 CASE row.CERN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CERN<> "-1" OR row.CERN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CERN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CFATF"})
 WITH *,
 CASE row.CFATF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CFATF<> "-1" OR row.CFATF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CFATF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CFC"})
 WITH *,
 CASE row.CFC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CFC<> "-1" OR row.CFC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CFC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CHSTEA"})
 WITH *,
 CASE row.CHSTEA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CHSTEA<> "-1" OR row.CHSTEA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CHSTEA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CICA"})
 WITH *,
 CASE row.CICA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CICA<> "-1" OR row.CICA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CICA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CIFC"})
 WITH *,
 CASE row.CIFC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CIFC<> "-1" OR row.CIFC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CIFC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CIMA"})
 WITH *,
 CASE row.CIMA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CIMA<> "-1" OR row.CIMA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CIMA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CIS"})
 WITH *,
 CASE row.CIS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CIS<> "-1" OR row.CIS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CIS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMAEC"})
 WITH *,
 CASE row.CMAEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CMAEC<> "-1" OR row.CMAEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CMAEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMAOC"})
 WITH *,
 CASE row.CMAOC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CMAOC<> "-1" OR row.CMAOC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CMAOC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMEA"})
 WITH *,
 CASE row.CMEA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CMEA<> "-1" OR row.CMEA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CMEA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMHASG"})
 WITH *,
 CASE row.CMHASG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CMHASG<> "-1" OR row.CMHASG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CMHASG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COE"})
 WITH *,
 CASE row.COE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.COE<> "-1" OR row.COE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.COE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COLOMBO"})
 WITH *,
 CASE row.COLOMBO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.COLOMBO<> "-1" OR row.COLOMBO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.COLOMBO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COMESA"})
 WITH *,
 CASE row.COMESA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.COMESA<> "-1" OR row.COMESA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.COMESA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CONFEJES"})
 WITH *,
 CASE row.CONFEJES
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CONFEJES<> "-1" OR row.CONFEJES <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CONFEJES})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COPTAC"})
 WITH *,
 CASE row.COPTAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.COPTAC<> "-1" OR row.COPTAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.COPTAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COSAVE"})
 WITH *,
 CASE row.COSAVE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.COSAVE<> "-1" OR row.COSAVE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.COSAVE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COrg"})
 WITH *,
 CASE row.COrg
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.COrg<> "-1" OR row.COrg <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.COrg})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CP"})
 WITH *,
 CASE row.CP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CP<> "-1" OR row.CP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CPAB"})
 WITH *,
 CASE row.CPAB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CPAB<> "-1" OR row.CPAB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CPAB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CPSC"})
 WITH *,
 CASE row.CPSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CPSC<> "-1" OR row.CPSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CPSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CPU"})
 WITH *,
 CASE row.CPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CPU<> "-1" OR row.CPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CSLF"})
 WITH *,
 CASE row.CSLF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CSLF<> "-1" OR row.CSLF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CSLF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CTCAf"})
 WITH *,
 CASE row.CTCAf
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CTCAf<> "-1" OR row.CTCAf <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CTCAf})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CTO"})
 WITH *,
 CASE row.CTO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CTO<> "-1" OR row.CTO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CTO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CWGC"})
 WITH *,
 CASE row.CWGC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CWGC<> "-1" OR row.CWGC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CWGC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CXC"})
 WITH *,
 CASE row.CXC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CXC<> "-1" OR row.CXC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CXC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CfRN"})
 WITH *,
 CASE row.CfRN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.CfRN<> "-1" OR row.CfRN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.CfRN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ComAB"})
 WITH *,
 CASE row.ComAB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ComAB<> "-1" OR row.ComAB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ComAB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ComSec"})
 WITH *,
 CASE row.ComSec
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ComSec<> "-1" OR row.ComSec <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ComSec})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"DBGLS"})
 WITH *,
 CASE row.DBGLS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.DBGLS<> "-1" OR row.DBGLS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.DBGLS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"DLCOEA"})
 WITH *,
 CASE row.DLCOEA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.DLCOEA<> "-1" OR row.DLCOEA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.DLCOEA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Danube"})
 WITH *,
 CASE row.Danube
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Danube<> "-1" OR row.Danube <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Danube})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EACM"})
 WITH *,
 CASE row.EACM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EACM<> "-1" OR row.EACM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EACM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EACS"})
 WITH *,
 CASE row.EACS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EACS<> "-1" OR row.EACS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EACS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EACSO"})
 WITH *,
 CASE row.EACSO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EACSO<> "-1" OR row.EACSO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EACSO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EADB"})
 WITH *,
 CASE row.EADB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EADB<> "-1" OR row.EADB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EADB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EAPC"})
 WITH *,
 CASE row.EAPC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EAPC<> "-1" OR row.EAPC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EAPC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EAPO"})
 WITH *,
 CASE row.EAPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EAPO<> "-1" OR row.EAPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EAPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EBRD"})
 WITH *,
 CASE row.EBRD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EBRD<> "-1" OR row.EBRD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EBRD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECB"})
 WITH *,
 CASE row.ECB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECB<> "-1" OR row.ECB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCA"})
 WITH *,
 CASE row.ECCA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECCA<> "-1" OR row.ECCA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECCA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCAS"})
 WITH *,
 CASE row.ECCAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECCAS<> "-1" OR row.ECCAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECCAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCB"})
 WITH *,
 CASE row.ECCB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECCB<> "-1" OR row.ECCB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECCB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCD"})
 WITH *,
 CASE row.ECCD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECCD<> "-1" OR row.ECCD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECCD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCM"})
 WITH *,
 CASE row.ECCM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECCM<> "-1" OR row.ECCM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECCM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCPIF"})
 WITH *,
 CASE row.ECCPIF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECCPIF<> "-1" OR row.ECCPIF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECCPIF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECO"})
 WITH *,
 CASE row.ECO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECO<> "-1" OR row.ECO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECOWAS"})
 WITH *,
 CASE row.ECOWAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECOWAS<> "-1" OR row.ECOWAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECOWAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECPTA"})
 WITH *,
 CASE row.ECPTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECPTA<> "-1" OR row.ECPTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECPTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECSC"})
 WITH *,
 CASE row.ECSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ECSC<> "-1" OR row.ECSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ECSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EEC"})
 WITH *,
 CASE row.EEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EEC<> "-1" OR row.EEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EFCC"})
 WITH *,
 CASE row.EFCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EFCC<> "-1" OR row.EFCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EFCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EFILWC"})
 WITH *,
 CASE row.EFILWC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EFILWC<> "-1" OR row.EFILWC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EFILWC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EFTA"})
 WITH *,
 CASE row.EFTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EFTA<> "-1" OR row.EFTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EFTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EIB"})
 WITH *,
 CASE row.EIB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EIB<> "-1" OR row.EIB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EIB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EIPA"})
 WITH *,
 CASE row.EIPA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EIPA<> "-1" OR row.EIPA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EIPA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ELDO"})
 WITH *,
 CASE row.ELDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ELDO<> "-1" OR row.ELDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ELDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMB"})
 WITH *,
 CASE row.EMB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EMB<> "-1" OR row.EMB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EMB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMBC"})
 WITH *,
 CASE row.EMBC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EMBC<> "-1" OR row.EMBC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EMBC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMBL"})
 WITH *,
 CASE row.EMBL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EMBL<> "-1" OR row.EMBL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EMBL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMI"})
 WITH *,
 CASE row.EMI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EMI<> "-1" OR row.EMI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EMI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMPPO"})
 WITH *,
 CASE row.EMPPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EMPPO<> "-1" OR row.EMPPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EMPPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPA"})
 WITH *,
 CASE row.EPA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EPA<> "-1" OR row.EPA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EPA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPFSC"})
 WITH *,
 CASE row.EPFSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EPFSC<> "-1" OR row.EPFSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EPFSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPO"})
 WITH *,
 CASE row.EPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EPO<> "-1" OR row.EPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPU"})
 WITH *,
 CASE row.EPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EPU<> "-1" OR row.EPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ESA"})
 WITH *,
 CASE row.ESA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ESA<> "-1" OR row.ESA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ESA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ESO"})
 WITH *,
 CASE row.ESO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ESO<> "-1" OR row.ESO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ESO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ESRO"})
 WITH *,
 CASE row.ESRO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ESRO<> "-1" OR row.ESRO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ESRO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ETF"})
 WITH *,
 CASE row.ETF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ETF<> "-1" OR row.ETF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ETF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EU"})
 WITH *,
 CASE row.EU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EU<> "-1" OR row.EU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUFMD"})
 WITH *,
 CASE row.EUFMD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EUFMD<> "-1" OR row.EUFMD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EUFMD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EURATOM"})
 WITH *,
 CASE row.EURATOM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EURATOM<> "-1" OR row.EURATOM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EURATOM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUROCONTROL"})
 WITH *,
 CASE row.EUROCONTROL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EUROCONTROL<> "-1" OR row.EUROCONTROL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EUROCONTROL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUROFIMA"})
 WITH *,
 CASE row.EUROFIMA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EUROFIMA<> "-1" OR row.EUROFIMA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EUROFIMA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUROMET"})
 WITH *,
 CASE row.EUROMET
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.EUROMET<> "-1" OR row.EUROMET <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.EUROMET})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Entente"})
 WITH *,
 CASE row.Entente
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Entente<> "-1" OR row.Entente <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Entente})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FAO"})
 WITH *,
 CASE row.FAO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.FAO<> "-1" OR row.FAO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.FAO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FAPED"})
 WITH *,
 CASE row.FAPED
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.FAPED<> "-1" OR row.FAPED <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.FAPED})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FDIPLAC"})
 WITH *,
 CASE row.FDIPLAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.FDIPLAC<> "-1" OR row.FDIPLAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.FDIPLAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FEC"})
 WITH *,
 CASE row.FEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.FEC<> "-1" OR row.FEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.FEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"G15"})
 WITH *,
 CASE row.G15
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.G15<> "-1" OR row.G15 <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.G15})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"G24"})
 WITH *,
 CASE row.G24
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.G24<> "-1" OR row.G24 <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.G24})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"G3"})
 WITH *,
 CASE row.G3
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.G3<> "-1" OR row.G3 <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.G3})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GATT"})
 WITH *,
 CASE row.GATT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GATT<> "-1" OR row.GATT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GATT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GBACT"})
 WITH *,
 CASE row.GBACT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GBACT<> "-1" OR row.GBACT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GBACT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GCC"})
 WITH *,
 CASE row.GCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GCC<> "-1" OR row.GCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GCRSNC"})
 WITH *,
 CASE row.GCRSNC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GCRSNC<> "-1" OR row.GCRSNC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GCRSNC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GEF"})
 WITH *,
 CASE row.GEF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GEF<> "-1" OR row.GEF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GEF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GEO"})
 WITH *,
 CASE row.GEO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GEO<> "-1" OR row.GEO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GEO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GHSI"})
 WITH *,
 CASE row.GHSI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GHSI<> "-1" OR row.GHSI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GHSI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GLACSEC"})
 WITH *,
 CASE row.GLACSEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GLACSEC<> "-1" OR row.GLACSEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GLACSEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GOIC"})
 WITH *,
 CASE row.GOIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GOIC<> "-1" OR row.GOIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GOIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GRBDO"})
 WITH *,
 CASE row.GRBDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.GRBDO<> "-1" OR row.GRBDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.GRBDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"HCPIL"})
 WITH *,
 CASE row.HCPIL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.HCPIL<> "-1" OR row.HCPIL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.HCPIL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IABE"})
 WITH *,
 CASE row.IABE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IABE<> "-1" OR row.IABE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IABE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IABath"})
 WITH *,
 CASE row.IABath
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IABath<> "-1" OR row.IABath <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IABath})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACB"})
 WITH *,
 CASE row.IACB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IACB<> "-1" OR row.IACB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IACB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACI"})
 WITH *,
 CASE row.IACI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IACI<> "-1" OR row.IACI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IACI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACS"})
 WITH *,
 CASE row.IACS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IACS<> "-1" OR row.IACS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IACS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACSS"})
 WITH *,
 CASE row.IACSS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IACSS<> "-1" OR row.IACSS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IACSS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACW"})
 WITH *,
 CASE row.IACW
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IACW<> "-1" OR row.IACW <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IACW})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IADB"})
 WITH *,
 CASE row.IADB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IADB<> "-1" OR row.IADB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IADB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IADefB"})
 WITH *,
 CASE row.IADefB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IADefB<> "-1" OR row.IADefB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IADefB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAEA"})
 WITH *,
 CASE row.IAEA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAEA<> "-1" OR row.IAEA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAEA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAFC"})
 WITH *,
 CASE row.IAFC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAFC<> "-1" OR row.IAFC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAFC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAHC"})
 WITH *,
 CASE row.IAHC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAHC<> "-1" OR row.IAHC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAHC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAIAS"})
 WITH *,
 CASE row.IAIAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAIAS<> "-1" OR row.IAIAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAIAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAIC"})
 WITH *,
 CASE row.IAIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAIC<> "-1" OR row.IAIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAIGC"})
 WITH *,
 CASE row.IAIGC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAIGC<> "-1" OR row.IAIGC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAIGC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAII"})
 WITH *,
 CASE row.IAII
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAII<> "-1" OR row.IAII <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAII})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IALong"})
 WITH *,
 CASE row.IALong
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IALong<> "-1" OR row.IALong <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IALong})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAMLO"})
 WITH *,
 CASE row.IAMLO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAMLO<> "-1" OR row.IAMLO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAMLO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAPhy"})
 WITH *,
 CASE row.IAPhy
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAPhy<> "-1" OR row.IAPhy <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAPhy})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARA"})
 WITH *,
 CASE row.IARA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IARA<> "-1" OR row.IARA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IARA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARHC"})
 WITH *,
 CASE row.IARHC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IARHC<> "-1" OR row.IARHC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IARHC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARadiO"})
 WITH *,
 CASE row.IARadiO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IARadiO<> "-1" OR row.IARadiO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IARadiO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARuhr"})
 WITH *,
 CASE row.IARuhr
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IARuhr<> "-1" OR row.IARuhr <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IARuhr})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAS"})
 WITH *,
 CASE row.IAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IAS<> "-1" OR row.IAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IASAJ"})
 WITH *,
 CASE row.IASAJ
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IASAJ<> "-1" OR row.IASAJ <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IASAJ})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IATB"})
 WITH *,
 CASE row.IATB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IATB<> "-1" OR row.IATB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IATB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IATSJ"})
 WITH *,
 CASE row.IATSJ
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IATSJ<> "-1" OR row.IATSJ <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IATSJ})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IATTC"})
 WITH *,
 CASE row.IATTC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IATTC<> "-1" OR row.IATTC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IATTC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBA"})
 WITH *,
 CASE row.IBA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBA<> "-1" OR row.IBA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBCS"})
 WITH *,
 CASE row.IBCS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBCS<> "-1" OR row.IBCS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBCS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBE"})
 WITH *,
 CASE row.IBE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBE<> "-1" OR row.IBE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBEC"})
 WITH *,
 CASE row.IBEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBEC<> "-1" OR row.IBEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBI"})
 WITH *,
 CASE row.IBI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBI<> "-1" OR row.IBI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBIER"})
 WITH *,
 CASE row.IBIER
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBIER<> "-1" OR row.IBIER <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBIER})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBPMP"})
 WITH *,
 CASE row.IBPMP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBPMP<> "-1" OR row.IBPMP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBPMP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBRD"})
 WITH *,
 CASE row.IBRD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IBRD<> "-1" OR row.IBRD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IBRD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAC"})
 WITH *,
 CASE row.ICAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICAC<> "-1" OR row.ICAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAI"})
 WITH *,
 CASE row.ICAI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICAI<> "-1" OR row.ICAI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICAI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAO"})
 WITH *,
 CASE row.ICAO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICAO<> "-1" OR row.ICAO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICAO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAmO"})
 WITH *,
 CASE row.ICAmO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICAmO<> "-1" OR row.ICAmO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICAmO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICC"})
 WITH *,
 CASE row.ICC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICC<> "-1" OR row.ICC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCEC"})
 WITH *,
 CASE row.ICCEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICCEC<> "-1" OR row.ICCEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICCEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCILMB"})
 WITH *,
 CASE row.ICCILMB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICCILMB<> "-1" OR row.ICCILMB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICCILMB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCO"})
 WITH *,
 CASE row.ICCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICCO<> "-1" OR row.ICCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCROM"})
 WITH *,
 CASE row.ICCROM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICCROM<> "-1" OR row.ICCROM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICCROM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCS"})
 WITH *,
 CASE row.ICCS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICCS<> "-1" OR row.ICCS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICCS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCSLT"})
 WITH *,
 CASE row.ICCSLT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICCSLT<> "-1" OR row.ICCSLT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICCSLT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICDR"})
 WITH *,
 CASE row.ICDR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICDR<> "-1" OR row.ICDR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICDR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICES"})
 WITH *,
 CASE row.ICES
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICES<> "-1" OR row.ICES <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICES})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICFAM"})
 WITH *,
 CASE row.ICFAM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICFAM<> "-1" OR row.ICFAM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICFAM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICHRB"})
 WITH *,
 CASE row.ICHRB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICHRB<> "-1" OR row.ICHRB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICHRB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICMMP"})
 WITH *,
 CASE row.ICMMP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICMMP<> "-1" OR row.ICMMP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICMMP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICNC"})
 WITH *,
 CASE row.ICNC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICNC<> "-1" OR row.ICNC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICNC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICNWAF"})
 WITH *,
 CASE row.ICNWAF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICNWAF<> "-1" OR row.ICNWAF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICNWAF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICPRP"})
 WITH *,
 CASE row.ICPRP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICPRP<> "-1" OR row.ICPRP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICPRP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICPTU"})
 WITH *,
 CASE row.ICPTU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICPTU<> "-1" OR row.ICPTU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICPTU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICRI"})
 WITH *,
 CASE row.ICRI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICRI<> "-1" OR row.ICRI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICRI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICRPBC"})
 WITH *,
 CASE row.ICRPBC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICRPBC<> "-1" OR row.ICRPBC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICRPBC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICSE"})
 WITH *,
 CASE row.ICSE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICSE<> "-1" OR row.ICSE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICSE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICSEAF"})
 WITH *,
 CASE row.ICSEAF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICSEAF<> "-1" OR row.ICSEAF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICSEAF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICSG"})
 WITH *,
 CASE row.ICSG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICSG<> "-1" OR row.ICSG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICSG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICTM"})
 WITH *,
 CASE row.ICTM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICTM<> "-1" OR row.ICTM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICTM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICWMD"})
 WITH *,
 CASE row.ICWMD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICWMD<> "-1" OR row.ICWMD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICWMD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICfO"})
 WITH *,
 CASE row.ICfO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICfO<> "-1" OR row.ICfO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICfO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IChemO"})
 WITH *,
 CASE row.IChemO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IChemO<> "-1" OR row.IChemO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IChemO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICivDO"})
 WITH *,
 CASE row.ICivDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ICivDO<> "-1" OR row.ICivDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ICivDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IComO"})
 WITH *,
 CASE row.IComO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IComO<> "-1" OR row.IComO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IComO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IDC"})
 WITH *,
 CASE row.IDC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IDC<> "-1" OR row.IDC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IDC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IEA"})
 WITH *,
 CASE row.IEA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IEA<> "-1" OR row.IEA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IEA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IEC"})
 WITH *,
 CASE row.IEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IEC<> "-1" OR row.IEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IES"})
 WITH *,
 CASE row.IES
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IES<> "-1" OR row.IES <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IES})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IEXB"})
 WITH *,
 CASE row.IEXB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IEXB<> "-1" OR row.IEXB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IEXB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IFAD"})
 WITH *,
 CASE row.IFAD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IFAD<> "-1" OR row.IFAD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IFAD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IFC"})
 WITH *,
 CASE row.IFC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IFC<> "-1" OR row.IFC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IFC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IFCA"})
 WITH *,
 CASE row.IFCA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IFCA<> "-1" OR row.IFCA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IFCA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IGAD"})
 WITH *,
 CASE row.IGAD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IGAD<> "-1" OR row.IGAD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IGAD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IGC"})
 WITH *,
 CASE row.IGC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IGC<> "-1" OR row.IGC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IGC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IGCC"})
 WITH *,
 CASE row.IGCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IGCC<> "-1" OR row.IGCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IGCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IHO"})
 WITH *,
 CASE row.IHO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IHO<> "-1" OR row.IHO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IHO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIA"})
 WITH *,
 CASE row.IIA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IIA<> "-1" OR row.IIA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IIA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IICom"})
 WITH *,
 CASE row.IICom
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IICom<> "-1" OR row.IICom <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IICom})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIE"})
 WITH *,
 CASE row.IIE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IIE<> "-1" OR row.IIE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IIE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIF"})
 WITH *,
 CASE row.IIF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IIF<> "-1" OR row.IIF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IIF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIWEE"})
 WITH *,
 CASE row.IIWEE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IIWEE<> "-1" OR row.IIWEE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IIWEE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IJO"})
 WITH *,
 CASE row.IJO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IJO<> "-1" OR row.IJO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IJO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ILO"})
 WITH *,
 CASE row.ILO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ILO<> "-1" OR row.ILO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ILO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ILZSG"})
 WITH *,
 CASE row.ILZSG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ILZSG<> "-1" OR row.ILZSG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ILZSG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMBSlav"})
 WITH *,
 CASE row.IMBSlav
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IMBSlav<> "-1" OR row.IMBSlav <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IMBSlav})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMC"})
 WITH *,
 CASE row.IMC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IMC<> "-1" OR row.IMC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IMC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMF"})
 WITH *,
 CASE row.IMF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IMF<> "-1" OR row.IMF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IMF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMI"})
 WITH *,
 CASE row.IMI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IMI<> "-1" OR row.IMI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IMI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMO"})
 WITH *,
 CASE row.IMO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IMO<> "-1" OR row.IMO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IMO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMSO"})
 WITH *,
 CASE row.IMSO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IMSO<> "-1" OR row.IMSO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IMSO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INCAP"})
 WITH *,
 CASE row.INCAP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INCAP<> "-1" OR row.INCAP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INCAP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INFOFISH"})
 WITH *,
 CASE row.INFOFISH
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INFOFISH<> "-1" OR row.INFOFISH <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INFOFISH})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INFSMK"})
 WITH *,
 CASE row.INFSMK
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INFSMK<> "-1" OR row.INFSMK <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INFSMK})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INRO"})
 WITH *,
 CASE row.INRO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INRO<> "-1" OR row.INRO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INRO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INSG"})
 WITH *,
 CASE row.INSG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INSG<> "-1" OR row.INSG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INSG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INTELSAT"})
 WITH *,
 CASE row.INTELSAT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INTELSAT<> "-1" OR row.INTELSAT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INTELSAT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INTERPOL"})
 WITH *,
 CASE row.INTERPOL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.INTERPOL<> "-1" OR row.INTERPOL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.INTERPOL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOATHRE"})
 WITH *,
 CASE row.IOATHRE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOATHRE<> "-1" OR row.IOATHRE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOATHRE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOCom"})
 WITH *,
 CASE row.IOCom
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOCom<> "-1" OR row.IOCom <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOCom})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOEz"})
 WITH *,
 CASE row.IOEz
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOEz<> "-1" OR row.IOEz <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOEz})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOLM"})
 WITH *,
 CASE row.IOLM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOLM<> "-1" OR row.IOLM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOLM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOMig"})
 WITH *,
 CASE row.IOMig
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOMig<> "-1" OR row.IOMig <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOMig})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOOC"})
 WITH *,
 CASE row.IOOC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOOC<> "-1" OR row.IOOC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOOC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOPCF"})
 WITH *,
 CASE row.IOPCF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOPCF<> "-1" OR row.IOPCF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOPCF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOPH"})
 WITH *,
 CASE row.IOPH
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOPH<> "-1" OR row.IOPH <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOPH})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOcC"})
 WITH *,
 CASE row.IOcC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IOcC<> "-1" OR row.IOcC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IOcC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPC"})
 WITH *,
 CASE row.IPC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPC<> "-1" OR row.IPC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPGRI"})
 WITH *,
 CASE row.IPGRI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPGRI<> "-1" OR row.IPGRI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPGRI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPI"})
 WITH *,
 CASE row.IPI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPI<> "-1" OR row.IPI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPedI"})
 WITH *,
 CASE row.IPedI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPedI<> "-1" OR row.IPedI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPedI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPentC"})
 WITH *,
 CASE row.IPentC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPentC<> "-1" OR row.IPentC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPentC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPhyL"})
 WITH *,
 CASE row.IPhyL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPhyL<> "-1" OR row.IPhyL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPhyL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPrizeC"})
 WITH *,
 CASE row.IPrizeC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IPrizeC<> "-1" OR row.IPrizeC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IPrizeC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRC"})
 WITH *,
 CASE row.IRC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IRC<> "-1" OR row.IRC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IRC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRLCS"})
 WITH *,
 CASE row.IRLCS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IRLCS<> "-1" OR row.IRLCS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IRLCS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRO"})
 WITH *,
 CASE row.IRO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IRO<> "-1" OR row.IRO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IRO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRSG"})
 WITH *,
 CASE row.IRSG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IRSG<> "-1" OR row.IRSG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IRSG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRU"})
 WITH *,
 CASE row.IRU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IRU<> "-1" OR row.IRU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IRU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISA"})
 WITH *,
 CASE row.ISA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISA<> "-1" OR row.ISA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISB"})
 WITH *,
 CASE row.ISB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISB<> "-1" OR row.ISB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISDB"})
 WITH *,
 CASE row.ISDB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISDB<> "-1" OR row.ISDB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISDB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISHREST"})
 WITH *,
 CASE row.ISHREST
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISHREST<> "-1" OR row.ISHREST <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISHREST})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISRBC"})
 WITH *,
 CASE row.ISRBC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISRBC<> "-1" OR row.ISRBC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISRBC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISUPT"})
 WITH *,
 CASE row.ISUPT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISUPT<> "-1" OR row.ISUPT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISUPT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISuC"})
 WITH *,
 CASE row.ISuC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ISuC<> "-1" OR row.ISuC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ISuC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITC"})
 WITH *,
 CASE row.ITC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITC<> "-1" OR row.ITC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITCC"})
 WITH *,
 CASE row.ITCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITCC<> "-1" OR row.ITCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITCLE"})
 WITH *,
 CASE row.ITCLE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITCLE<> "-1" OR row.ITCLE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITCLE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITPA"})
 WITH *,
 CASE row.ITPA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITPA<> "-1" OR row.ITPA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITPA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITRO"})
 WITH *,
 CASE row.ITRO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITRO<> "-1" OR row.ITRO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITRO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITTO"})
 WITH *,
 CASE row.ITTO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITTO<> "-1" OR row.ITTO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITTO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITU"})
 WITH *,
 CASE row.ITU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITU<> "-1" OR row.ITU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITVRC"})
 WITH *,
 CASE row.ITVRC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.ITVRC<> "-1" OR row.ITVRC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.ITVRC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUIC"})
 WITH *,
 CASE row.IUIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IUIC<> "-1" OR row.IUIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IUIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPCT"})
 WITH *,
 CASE row.IUPCT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IUPCT<> "-1" OR row.IUPCT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IUPCT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPIP"})
 WITH *,
 CASE row.IUPIP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IUPIP<> "-1" OR row.IUPIP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IUPIP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPLAW"})
 WITH *,
 CASE row.IUPLAW
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IUPLAW<> "-1" OR row.IUPLAW <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IUPLAW})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPNVP"})
 WITH *,
 CASE row.IUPNVP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IUPNVP<> "-1" OR row.IUPNVP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IUPNVP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPR"})
 WITH *,
 CASE row.IUPR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IUPR<> "-1" OR row.IUPR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IUPR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IVWO"})
 WITH *,
 CASE row.IVWO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IVWO<> "-1" OR row.IVWO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IVWO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IWSG"})
 WITH *,
 CASE row.IWSG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IWSG<> "-1" OR row.IWSG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IWSG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IWhale"})
 WITH *,
 CASE row.IWhale
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.IWhale<> "-1" OR row.IWhale <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.IWhale})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Iocean"})
 WITH *,
 CASE row.Iocean
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Iocean<> "-1" OR row.Iocean <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Iocean})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"JALAAO"})
 WITH *,
 CASE row.JALAAO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.JALAAO<> "-1" OR row.JALAAO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.JALAAO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"JINR"})
 WITH *,
 CASE row.JINR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.JINR<> "-1" OR row.JINR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.JINR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"JNOLCRH"})
 WITH *,
 CASE row.JNOLCRH
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.JNOLCRH<> "-1" OR row.JNOLCRH <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.JNOLCRH})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LACAC"})
 WITH *,
 CASE row.LACAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LACAC<> "-1" OR row.LACAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LACAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LACP"})
 WITH *,
 CASE row.LACP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LACP<> "-1" OR row.LACP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LACP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAEO"})
 WITH *,
 CASE row.LAEO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LAEO<> "-1" OR row.LAEO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LAEO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAFDO"})
 WITH *,
 CASE row.LAFDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LAFDO<> "-1" OR row.LAFDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LAFDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAFTA"})
 WITH *,
 CASE row.LAFTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LAFTA<> "-1" OR row.LAFTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LAFTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAIA"})
 WITH *,
 CASE row.LAIA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LAIA<> "-1" OR row.LAIA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LAIA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAIEC"})
 WITH *,
 CASE row.LAIEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LAIEC<> "-1" OR row.LAIEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LAIEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LATIN"})
 WITH *,
 CASE row.LATIN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LATIN<> "-1" OR row.LATIN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LATIN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LCBC"})
 WITH *,
 CASE row.LCBC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LCBC<> "-1" OR row.LCBC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LCBC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LGIDA"})
 WITH *,
 CASE row.LGIDA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LGIDA<> "-1" OR row.LGIDA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LGIDA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LOAS"})
 WITH *,
 CASE row.LOAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LOAS<> "-1" OR row.LOAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LOAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LoN"})
 WITH *,
 CASE row.LoN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.LoN<> "-1" OR row.LoN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.LoN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MARRI"})
 WITH *,
 CASE row.MARRI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MARRI<> "-1" OR row.MARRI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MARRI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MCPTTC"})
 WITH *,
 CASE row.MCPTTC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MCPTTC<> "-1" OR row.MCPTTC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MCPTTC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MCWCASM"})
 WITH *,
 CASE row.MCWCASM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MCWCASM<> "-1" OR row.MCWCASM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MCWCASM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MEMTTA"})
 WITH *,
 CASE row.MEMTTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MEMTTA<> "-1" OR row.MEMTTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MEMTTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MFO"})
 WITH *,
 CASE row.MFO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MFO<> "-1" OR row.MFO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MFO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MIGA"})
 WITH *,
 CASE row.MIGA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MIGA<> "-1" OR row.MIGA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MIGA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MOPAN"})
 WITH *,
 CASE row.MOPAN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MOPAN<> "-1" OR row.MOPAN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MOPAN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MRU"})
 WITH *,
 CASE row.MRU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MRU<> "-1" OR row.MRU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MRU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MWN"})
 WITH *,
 CASE row.MWN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.MWN<> "-1" OR row.MWN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.MWN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Mercosur"})
 WITH *,
 CASE row.Mercosur
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Mercosur<> "-1" OR row.Mercosur <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Mercosur})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Montreal"})
 WITH *,
 CASE row.Montreal
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Montreal<> "-1" OR row.Montreal <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Montreal})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NACAP"})
 WITH *,
 CASE row.NACAP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NACAP<> "-1" OR row.NACAP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NACAP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAFO"})
 WITH *,
 CASE row.NAFO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NAFO<> "-1" OR row.NAFO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NAFO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAFTA"})
 WITH *,
 CASE row.NAFTA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NAFTA<> "-1" OR row.NAFTA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NAFTA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAM"})
 WITH *,
 CASE row.NAM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NAM<> "-1" OR row.NAM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NAM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAPPO"})
 WITH *,
 CASE row.NAPPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NAPPO<> "-1" OR row.NAPPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NAPPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NASCO"})
 WITH *,
 CASE row.NASCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NASCO<> "-1" OR row.NASCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NASCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NATO"})
 WITH *,
 CASE row.NATO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NATO<> "-1" OR row.NATO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NATO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NCM"})
 WITH *,
 CASE row.NCM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NCM<> "-1" OR row.NCM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NCM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NCRR"})
 WITH *,
 CASE row.NCRR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NCRR<> "-1" OR row.NCRR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NCRR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NCTR"})
 WITH *,
 CASE row.NCTR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NCTR<> "-1" OR row.NCTR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NCTR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NDF"})
 WITH *,
 CASE row.NDF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NDF<> "-1" OR row.NDF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NDF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NEAFC"})
 WITH *,
 CASE row.NEAFC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NEAFC<> "-1" OR row.NEAFC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NEAFC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NERC"})
 WITH *,
 CASE row.NERC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NERC<> "-1" OR row.NERC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NERC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NIB"})
 WITH *,
 CASE row.NIB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NIB<> "-1" OR row.NIB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NIB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NPAFC"})
 WITH *,
 CASE row.NPAFC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NPAFC<> "-1" OR row.NPAFC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NPAFC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NPFSC"})
 WITH *,
 CASE row.NPFSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NPFSC<> "-1" OR row.NPFSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NPFSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NRC"})
 WITH *,
 CASE row.NRC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NRC<> "-1" OR row.NRC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NRC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NTSC"})
 WITH *,
 CASE row.NTSC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NTSC<> "-1" OR row.NTSC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NTSC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NWHF"})
 WITH *,
 CASE row.NWHF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NWHF<> "-1" OR row.NWHF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NWHF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NordC"})
 WITH *,
 CASE row.NordC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.NordC<> "-1" OR row.NordC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.NordC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OAPEC"})
 WITH *,
 CASE row.OAPEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OAPEC<> "-1" OR row.OAPEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OAPEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OAS"})
 WITH *,
 CASE row.OAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OAS<> "-1" OR row.OAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OAU"})
 WITH *,
 CASE row.OAU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OAU<> "-1" OR row.OAU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OAU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCAM"})
 WITH *,
 CASE row.OCAM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OCAM<> "-1" OR row.OCAM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OCAM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCAS"})
 WITH *,
 CASE row.OCAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OCAS<> "-1" OR row.OCAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OCAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCCEDCA"})
 WITH *,
 CASE row.OCCEDCA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OCCEDCA<> "-1" OR row.OCCEDCA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OCCEDCA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCR"})
 WITH *,
 CASE row.OCR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OCR<> "-1" OR row.OCR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OCR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OECD"})
 WITH *,
 CASE row.OECD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OECD<> "-1" OR row.OECD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OECD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OECS"})
 WITH *,
 CASE row.OECS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OECS<> "-1" OR row.OECS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OECS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OEEC"})
 WITH *,
 CASE row.OEEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OEEC<> "-1" OR row.OEEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OEEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OESAS"})
 WITH *,
 CASE row.OESAS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OESAS<> "-1" OR row.OESAS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OESAS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OIC"})
 WITH *,
 CASE row.OIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OIC<> "-1" OR row.OIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OIV"})
 WITH *,
 CASE row.OIV
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OIV<> "-1" OR row.OIV <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OIV})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OMDKR"})
 WITH *,
 CASE row.OMDKR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OMDKR<> "-1" OR row.OMDKR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OMDKR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OPANAL"})
 WITH *,
 CASE row.OPANAL
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OPANAL<> "-1" OR row.OPANAL <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OPANAL})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OPEC"})
 WITH *,
 CASE row.OPEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OPEC<> "-1" OR row.OPEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OPEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OSCE"})
 WITH *,
 CASE row.OSCE
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OSCE<> "-1" OR row.OSCE <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OSCE})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OSLO"})
 WITH *,
 CASE row.OSLO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OSLO<> "-1" OR row.OSLO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OSLO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OSPAR"})
 WITH *,
 CASE row.OSPAR
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OSPAR<> "-1" OR row.OSPAR <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OSPAR})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OTIF"})
 WITH *,
 CASE row.OTIF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.OTIF<> "-1" OR row.OTIF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.OTIF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAHC"})
 WITH *,
 CASE row.PAHC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PAHC<> "-1" OR row.PAHC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PAHC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAHO"})
 WITH *,
 CASE row.PAHO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PAHO<> "-1" OR row.PAHO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PAHO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAIGH"})
 WITH *,
 CASE row.PAIGH
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PAIGH<> "-1" OR row.PAIGH <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PAIGH})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAP"})
 WITH *,
 CASE row.PAP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PAP<> "-1" OR row.PAP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PAP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PC"})
 WITH *,
 CASE row.PC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PC<> "-1" OR row.PC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PCA"})
 WITH *,
 CASE row.PCA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PCA<> "-1" OR row.PCA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PCA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PCB"})
 WITH *,
 CASE row.PCB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PCB<> "-1" OR row.PCB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PCB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PCSP"})
 WITH *,
 CASE row.PCSP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PCSP<> "-1" OR row.PCSP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PCSP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PED"})
 WITH *,
 CASE row.PED
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PED<> "-1" OR row.PED <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PED})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIARC"})
 WITH *,
 CASE row.PIARC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PIARC<> "-1" OR row.PIARC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PIARC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIBAC"})
 WITH *,
 CASE row.PIBAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PIBAC<> "-1" OR row.PIBAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PIBAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PICDCS"})
 WITH *,
 CASE row.PICDCS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PICDCS<> "-1" OR row.PICDCS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PICDCS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PICES"})
 WITH *,
 CASE row.PICES
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PICES<> "-1" OR row.PICES <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PICES})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PICS"})
 WITH *,
 CASE row.PICS
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PICS<> "-1" OR row.PICS <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PICS})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIF"})
 WITH *,
 CASE row.PIF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PIF<> "-1" OR row.PIF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PIF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIPD"})
 WITH *,
 CASE row.PIPD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PIPD<> "-1" OR row.PIPD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PIPD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PMAESA"})
 WITH *,
 CASE row.PMAESA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PMAESA<> "-1" OR row.PMAESA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PMAESA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PSI"})
 WITH *,
 CASE row.PSI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PSI<> "-1" OR row.PSI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PSI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PSNARCO"})
 WITH *,
 CASE row.PSNARCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PSNARCO<> "-1" OR row.PSNARCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PSNARCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PTASEA"})
 WITH *,
 CASE row.PTASEA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PTASEA<> "-1" OR row.PTASEA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PTASEA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PUASP"})
 WITH *,
 CASE row.PUASP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.PUASP<> "-1" OR row.PUASP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.PUASP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RASCOM"})
 WITH *,
 CASE row.RASCOM
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RASCOM<> "-1" OR row.RASCOM <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RASCOM})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RCAELA"})
 WITH *,
 CASE row.RCAELA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RCAELA<> "-1" OR row.RCAELA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RCAELA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RCC"})
 WITH *,
 CASE row.RCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RCC<> "-1" OR row.RCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RECSA"})
 WITH *,
 CASE row.RECSA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RECSA<> "-1" OR row.RECSA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RECSA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RIMMO"})
 WITH *,
 CASE row.RIMMO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RIMMO<> "-1" OR row.RIMMO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RIMMO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RIOPPAH"})
 WITH *,
 CASE row.RIOPPAH
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RIOPPAH<> "-1" OR row.RIOPPAH <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RIOPPAH})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RIOgroup"})
 WITH *,
 CASE row.RIOgroup
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RIOgroup<> "-1" OR row.RIOgroup <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RIOgroup})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RadioU"})
 WITH *,
 CASE row.RadioU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RadioU<> "-1" OR row.RadioU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RadioU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RepCom"})
 WITH *,
 CASE row.RepCom
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.RepCom<> "-1" OR row.RepCom <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.RepCom})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SAAFA"})
 WITH *,
 CASE row.SAAFA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SAAFA<> "-1" OR row.SAAFA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SAAFA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SAARC"})
 WITH *,
 CASE row.SAARC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SAARC<> "-1" OR row.SAARC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SAARC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SACEP"})
 WITH *,
 CASE row.SACEP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SACEP<> "-1" OR row.SACEP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SACEP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SACU"})
 WITH *,
 CASE row.SACU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SACU<> "-1" OR row.SACU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SACU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SADC"})
 WITH *,
 CASE row.SADC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SADC<> "-1" OR row.SADC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SADC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SADCC"})
 WITH *,
 CASE row.SADCC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SADCC<> "-1" OR row.SADCC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SADCC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SAMI"})
 WITH *,
 CASE row.SAMI
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SAMI<> "-1" OR row.SAMI <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SAMI})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SARTC"})
 WITH *,
 CASE row.SARTC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SARTC<> "-1" OR row.SARTC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SARTC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCA"})
 WITH *,
 CASE row.SCA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SCA<> "-1" OR row.SCA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SCA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCAf"})
 WITH *,
 CASE row.SCAf
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SCAf<> "-1" OR row.SCAf <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SCAf})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCH"})
 WITH *,
 CASE row.SCH
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SCH<> "-1" OR row.SCH <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SCH})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCHENGEN"})
 WITH *,
 CASE row.SCHENGEN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SCHENGEN<> "-1" OR row.SCHENGEN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SCHENGEN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SEAMEO"})
 WITH *,
 CASE row.SEAMEO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SEAMEO<> "-1" OR row.SEAMEO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SEAMEO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SEATO"})
 WITH *,
 CASE row.SEATO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SEATO<> "-1" OR row.SEATO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SEATO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SEGIB"})
 WITH *,
 CASE row.SEGIB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SEGIB<> "-1" OR row.SEGIB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SEGIB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SELA"})
 WITH *,
 CASE row.SELA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SELA<> "-1" OR row.SELA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SELA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SICA"})
 WITH *,
 CASE row.SICA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SICA<> "-1" OR row.SICA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SICA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SIECA"})
 WITH *,
 CASE row.SIECA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SIECA<> "-1" OR row.SIECA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SIECA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SITTDEC"})
 WITH *,
 CASE row.SITTDEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SITTDEC<> "-1" OR row.SITTDEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SITTDEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SPC"})
 WITH *,
 CASE row.SPC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SPC<> "-1" OR row.SPC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SPC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SRDO"})
 WITH *,
 CASE row.SRDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SRDO<> "-1" OR row.SRDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SRDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SWAPU"})
 WITH *,
 CASE row.SWAPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SWAPU<> "-1" OR row.SWAPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SWAPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SWPD"})
 WITH *,
 CASE row.SWPD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SWPD<> "-1" OR row.SWPD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SWPD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SugU"})
 WITH *,
 CASE row.SugU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.SugU<> "-1" OR row.SugU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.SugU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"TARHEC"})
 WITH *,
 CASE row.TARHEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.TARHEC<> "-1" OR row.TARHEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.TARHEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"TCRMG"})
 WITH *,
 CASE row.TCRMG
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.TCRMG<> "-1" OR row.TCRMG <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.TCRMG})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"TIC"})
 WITH *,
 CASE row.TIC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.TIC<> "-1" OR row.TIC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.TIC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Turksoy"})
 WITH *,
 CASE row.Turksoy
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Turksoy<> "-1" OR row.Turksoy <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Turksoy})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UASC"})
 WITH *,
 CASE row.UASC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UASC<> "-1" OR row.UASC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UASC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UBEC"})
 WITH *,
 CASE row.UBEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UBEC<> "-1" OR row.UBEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UBEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UDEAC"})
 WITH *,
 CASE row.UDEAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UDEAC<> "-1" OR row.UDEAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UDEAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UEMOA"})
 WITH *,
 CASE row.UEMOA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UEMOA<> "-1" OR row.UEMOA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UEMOA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UIUCV"})
 WITH *,
 CASE row.UIUCV
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UIUCV<> "-1" OR row.UIUCV <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UIUCV})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UKDWD"})
 WITH *,
 CASE row.UKDWD
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UKDWD<> "-1" OR row.UKDWD <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UKDWD})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UMAC"})
 WITH *,
 CASE row.UMAC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UMAC<> "-1" OR row.UMAC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UMAC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UMOA"})
 WITH *,
 CASE row.UMOA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UMOA<> "-1" OR row.UMOA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UMOA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UN"})
 WITH *,
 CASE row.UN
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UN<> "-1" OR row.UN <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UN})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UNDROIT"})
 WITH *,
 CASE row.UNDROIT
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UNDROIT<> "-1" OR row.UNDROIT <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UNDROIT})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UNESCO"})
 WITH *,
 CASE row.UNESCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UNESCO<> "-1" OR row.UNESCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UNESCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UNIDO"})
 WITH *,
 CASE row.UNIDO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UNIDO<> "-1" OR row.UNIDO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UNIDO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UPU"})
 WITH *,
 CASE row.UPU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.UPU<> "-1" OR row.UPU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.UPU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"USP"})
 WITH *,
 CASE row.USP
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.USP<> "-1" OR row.USP <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.USP})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"VALDIVIA"})
 WITH *,
 CASE row.VALDIVIA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.VALDIVIA<> "-1" OR row.VALDIVIA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.VALDIVIA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"VASAB"})
 WITH *,
 CASE row.VASAB
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.VASAB<> "-1" OR row.VASAB <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.VASAB})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WAEC"})
 WITH *,
 CASE row.WAEC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WAEC<> "-1" OR row.WAEC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WAEC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WAHC"})
 WITH *,
 CASE row.WAHC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WAHC<> "-1" OR row.WAHC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WAHC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WAHO"})
 WITH *,
 CASE row.WAHO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WAHO<> "-1" OR row.WAHO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WAHO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WARDA"})
 WITH *,
 CASE row.WARDA
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WARDA<> "-1" OR row.WARDA <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WARDA})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WCDC"})
 WITH *,
 CASE row.WCDC
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WCDC<> "-1" OR row.WCDC <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WCDC})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WCO"})
 WITH *,
 CASE row.WCO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WCO<> "-1" OR row.WCO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WCO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WEU"})
 WITH *,
 CASE row.WEU
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WEU<> "-1" OR row.WEU <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WEU})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WHO"})
 WITH *,
 CASE row.WHO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WHO<> "-1" OR row.WHO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WHO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WIPO"})
 WITH *,
 CASE row.WIPO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WIPO<> "-1" OR row.WIPO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WIPO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WMO"})
 WITH *,
 CASE row.WMO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WMO<> "-1" OR row.WMO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WMO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WNF"})
 WITH *,
 CASE row.WNF
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WNF<> "-1" OR row.WNF <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WNF})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WPact"})
 WITH *,
 CASE row.WPact
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WPact<> "-1" OR row.WPact <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WPact})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WTO"})
 WITH *,
 CASE row.WTO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WTO<> "-1" OR row.WTO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WTO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WTOURO"})
 WITH *,
 CASE row.WTOURO
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.WTOURO<> "-1" OR row.WTOURO <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.WTOURO})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 ) 
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
 LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
 MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Wassen"})
 WITH *,
 CASE row.Wassen
   WHEN "1" THEN "Full Member"
   WHEN "2" THEN "Associate Member"
   WHEN "3" THEN "Observer"
   WHEN "0" THEN "Not a Member"
   WHEN "-9" THEN "Missing Data"
   END AS membership
 FOREACH (datum IN CASE WHEN row.Wassen<> "-1" OR row.Wassen <> "-9" THEN [1] ELSE [] END | 
   CREATE (d)-[:CONTRIBUTES]->(f:Fact{name:"IGO Membership", status:membership, membershipCode:row.Wassen})-[:DURING]->(p)
   CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
 );