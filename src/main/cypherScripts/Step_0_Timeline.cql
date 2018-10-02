// This Cypher Query Language (CQL) script will import several key peace science data sets into a Neo4j graph database
// for grounding and/or validating agent-based simulation models of world politics and International Relations.
//
// @author {Clarence Dillon, cdillon2@gmu.edu}
// Department of Computational and Data Sciences, George Mason University College of Science
//
//  See the README.md for project notes and a few instructions about using this file and the imported data.

// Before I get started, I want to add nodes in the graph to represent years, since some data is about
// years as much as it about the state. e.g., (state)-[:HAS_MILEX_IN]->(1818{began:date({year:1818, month:1, day:1})})
// I am trying to follow ISO 8601, which specifies that the first week of the year begins on the first Thursday of the
// year (even though there was no ISO when the bulk of the data begins, in 1815. The last week of the year always
// includes 28 December. The last day of the year, 31 December could occur on the first week of the following year.)
// Assert uniqueness of beginning dates and create index for faster date querying
CREATE CONSTRAINT ON (y:Year) ASSERT y.began IS UNIQUE;
CREATE CONSTRAINT ON (y:Year) ASSERT y.name IS UNIQUE;
CREATE CONSTRAINT ON (w:Week) ASSERT w.began IS UNIQUE;
CREATE CONSTRAINT ON (w:Week) ASSERT w.name IS UNIQUE;


// Reported on Neo4j Slack on 18June2018, Neo4j has a bug that intermittently reports bad first day of the week when
// given a year and week number. My workaround was to create a spreadsheet of values and read it in.
// ==== update 4 SEP 2018 =====
// This seems have been corrected in Neo4j v3.4.6.
//
// WITH range(1815, 2020) AS years
// FOREACH (yr IN years |
//   MERGE (y:Year{name:toString(yr), began:date({year:yr, month:1, day:1}), ended:date({year:yr, month:12, day:31}),
//   last:date({year:yr, month:12, day:28}) })
//   SET y.weeksThisYear = y.last.week );
//
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
//
//begany,beganm,begand,endedy,endedm,endedd,weeknum,year
//LOAD CSV WITH HEADERS FROM "file:///weeksNums.csv" AS row
//MATCH (y:Year{began:date({year:toInteger(row.year)})})
//CREATE (w:Week{began:date({year:toInteger(row.begany), month:toInteger(row.beganm), day:toInteger(row.begand)}),
// ended:date({year:toInteger(row.endedy), month:toInteger(row.endedm), day:toInteger(row.endedd)}),
// weekOfYear:toInteger(row.weeknum), name:toString((toInteger(row.year) * 100) + row.weeknum)-[:PART_OF{
//  weekOfYear:toInteger(row.weeknum)}]->(y)


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

