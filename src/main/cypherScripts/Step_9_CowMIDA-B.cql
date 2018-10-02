// Reviewed, updated 14 SEP 2018; includes named facts
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
CREATE (d)-[c:CONTRIBUTES{asOf:d.updated, version:row.version}]->(f:Fact:DisputeFact{
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
FOREACH (v in CASE WHEN row.dispnum4<>"-9" THEN [1] ELSE [] END | SET i.numberV4 = row.dispnum4);

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
FOREACH (var IN CASE WHEN row.fatalpre<>"-9" THEN [1] ELSE [] END | SET f.preciseFatalities = row.fatalpre );

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
  CREATE (i)-[:LINKED]->(f3)-[:LINKED_TO]->(i3) );

// MIDB, link states to MIDs
MATCH (d:Dataset{filename:"MIDB_4.2.csv"})
LOAD CSV WITH HEADERS FROM "file:///MIDB_4.2.csv" AS row
MATCH (s:State{cowcode:row.ccode}), (i:Dispute{numberV3:row.dispnum3})
CREATE (d)-[:CONTRIBUTES{asOf:d.updated, version:row.version}]->(f:Fact:DisputeFact{
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