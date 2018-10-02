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

