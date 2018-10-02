// Reviewed, updated 14 SEP 2018; includes named facts
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
//      /-[:CONTRIBUTES]->(:Fact)<-[:EXPORTED]-(:State)
//     /                         \-[:DURING]
// (PC)         /-------->(:Year)<--------/
//    \        [:DURING]-\
//     \-[:CONTRIBUTES]->(:Fact)<-[:IMPORTED]-(:State)
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
  CREATE (d)-[ic:CONTRIBUTES]->(if:Fact:ImportsFact{name:"Total Imports"})-[:DURING]->(y)
  CREATE (s)-[:IMPORTS]->(if)
  CREATE (d)-[ec:CONTRIBUTES]->(ef:Fact:ExportsFact{name:"Total Exports"})-[:DURING]->(y)
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
  CREATE (d)-[c1:CONTRIBUTES]->(f1:Fact:ImportFromFact{name:"Import", currency:"Millions in 2017 USD"})-[:IMPORTED_FROM]->(s2)
  MERGE (s1)-[:IMPORTED]->(f1)-[:DURING]->(y)
  CREATE (d)-[c2:CONTRIBUTES]->(f2:Fact:ImportFromFact{name:"Import", currency:"Millions in 2017 USD"})-[:IMPORTED_FROM]->(s1)
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