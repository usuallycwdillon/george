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

