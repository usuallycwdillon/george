// Reviewed, updated 14 SEP 2018; includes named facts
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
}]->(f:Fact:MilExFact{
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
CREATE (state)-[:MILPER{definition:"Thousands of military personnel."}]->(f:Fact:MilPerFact{
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
CREATE (state)-[:IRON_STEEL_PRODUCTION{definition:"Iron and Steel Production"}]->(f:Fact:ProductionFact{
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
CREATE (state)-[:PETROL_CONSUMPTION{definition:"Primary Energy Consumption"}]->(f:Fact:EnergyConsumptionFact{
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
CREATE (state)-[:POPULATION {definition:"Total Population"}]->(f:Fact:PopulationFact{
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
CREATE (state)-[:URBAN_POPULATION{definition:def}]->(f:Fact:UrbanPopulationFact{
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
CREATE (state)-[:CINC_SCORE{definition:"Composite Index of National Capability (CINC) score"}]->(f:Fact:CINCFact{
  name:"CINC Score",
  value:toFloat(row.cinc)
})-[:DURING]->(y)
CREATE (d)-[:CONTRIBUTES]->(f);
RETURN "Successfully imported the 7th (fourth COW) file, NMC_5_0-wsupplementary.csv, part 7 of 7";