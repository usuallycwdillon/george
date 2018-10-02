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