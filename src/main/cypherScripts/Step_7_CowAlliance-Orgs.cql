// Reviewed, updated 14 SEP 2018; includes named facts
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
CREATE (d)-[:CONTRIBUTES]->(f:Fact:AllianceFact{
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
CREATE (d)-[:CONTRIBUTES{asOf:d.published}]->(f:Fact:IGOFact{
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