// Reviewed, updated 14 SEP 2018; includes named facts
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

 World religions graph (from the documentation)
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
CREATE (:Denomination:Religion{symbol:"budothr", majorReligion:"Buddhism", denomination:"Other"});

MATCH (d:Denomination), (r:Religion)
  WHERE d.majorReligion = r.name
CREATE (d)-[:PART_OF]->(r);

// WRP National Data
MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year}), (r:Religion{symbol:"chrstprot"})
WITH *
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.chrstprot),percentage:toFloat(row.chrstprotpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.chrstcat),percentage:toFloat(row.chrstcatpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode,
f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab),
f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel,
f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state})
WITH d, row, s
MATCH (y:Year{name:row.year})
WITH d, row, s, y
MATCH (r:Religion{symbol:"chrstorth"})
WITH *
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.chrstorth),percentage:toFloat(row.chrstorthpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.chrstang),percentage:toFloat(row.chrstangpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.chrstothr),percentage:toFloat(row.chrstothrpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.chrstgen),percentage:toFloat(row.chrstgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.judorth),percentage:toFloat(row.judorthpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.jdcons),percentage:toFloat(row.judconspct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.judref),percentage:toFloat(row.judrefpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.judothr),percentage:toFloat(row.judothrpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.judgen),percentage:toFloat(row.judgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmsun),percentage:toFloat(row.islmsunpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmshi),percentage:toFloat(row.islmshipct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmibd),percentage:toFloat(row.islmibdpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmnat),percentage:toFloat(row.islmnatpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmalw),percentage:toFloat(row.islmalwpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmahm),percentage:toFloat(row.islmahmpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmothr),percentage:toFloat(row.islmothrpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.islmgen),percentage:toFloat(row.islmgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.budmah),percentage:toFloat(row.budmahpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.budthr),percentage:toFloat(row.budthrpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.budothr),percentage:toFloat(row.budothrpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.budgen),percentage:toFloat(row.budgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.zorogen),percentage:toFloat(row.zorogenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.hindgen),percentage:toFloat(row.hindgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.sikhgen),percentage:toFloat(row.sikhgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.shntgen),percentage:toFloat(row.shntgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.bahgen),percentage:toFloat(row.bahgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.taogen),percentage:toFloat(row.taogenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.jaingen),percentage:toFloat(row.jaingenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.confgen),percentage:toFloat(row.confgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.syncgen),percentage:toFloat(row.syncgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.anmgen),percentage:toFloat(row.anmgenpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.nonrelig),percentage:toFloat(row.nonreligpct)})-[:DURING]->(y)
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
  MERGE (d)-[:CONTRIBUTES]->(f:Fact:ReligiousPopulationFact{population:toInteger(row.othrgen),percentage:toFloat(row.othrgenpct)})-[:DURING]->(y)
MERGE (s)-[:RELIGION_POP]->(f)-[:POPULATION_WITH]->(r)
SET f.version = toFloat(row.Version), f.method = row.datatype, f.sourceCode = row.sourcecode,
f.name = "Religion", f.sourceReliability = toInteger(row.sourcereliab),
f.recordReliability = toInteger(row.recreliab), f.reliabilityLevel = row.reliabilevel,
f.dualReligions = toBoolean(FALSE)
FOREACH (var IN CASE WHEN row.dualrelig<>"1" THEN [1] ELSE [] END | SET f.dualReligions = toBoolean(TRUE));

MATCH (d:Dataset{filename:"WRP_national.csv"})
LOAD CSV WITH HEADERS FROM "file:///WRP_national.csv" AS row
MATCH (s:State{cowcode:row.state}), (y:Year{name:row.year})
MERGE (r:Religion{symbol:"Totals"})
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