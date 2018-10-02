Most importantly and before I forget...

`username: neo4j`
`password: george`

To use this script, you can invoke Neo4j's cypher-shell from the command line at the root of your Neo4j instance:
`cat allTheCows.cql | bin/cypher-shell -u neo4j -p <password> --format plain`
...of course, replacing <password> with your actual Neo4j password.

This Cypher Query Language (CQL) script will import several key peace science data sets into a Neo4j graph database
for grounding and/or validating agent-based simulation models of world politics and International Relations.

@author {Clarence Dillon, cdillon2@gmu.edu}
Department of Computational and Data Sciences, George Mason University College of Science


Project Notes: A great deal of the difficulty in developing grounded and validated agent-based simulations is munging
the numerous (but seemingly never numerous enough) datasets in such a way that records are object-oriented (instead
of 'flattened') and are temporally consistent with the temporal domain of the simulation model. The goal of this part 
of my project is to import datasets that I need for my simulation model and several that may be useful in 
future/related research into a schema-free environment that can (1) record the provenance of each datum, including data
from corroborating sources; (2) allow easy comparison and selection between competing/conflicting datasets; (3) be 
easily updatable without putting any requirements on source data providers (other than accessibility); (4) allow 
querying from any agent's perspective; and, (5) be temporally scopable, so that simulations can scale between, e.g., 
days, weeks, months, years, etc. I believe the graph database that results from this script meets those requirements. 
It is additionally temporally versioned (it's possible to compare the state of the world system at different time-
periods; year-to-year). In summary: it includes a 'calendar tree' to represenst time, a data provenance graph as 
described above, and a property graph that represents the ontology of agents, entities and concepts. 

The calendar tree includes only years and weeks, because Neo4j 3.4 introduced a new Date() data type. I have implemented
it as: 
`(:Year{from:date({year:YYYY, month:1, day:1}), until:date({year:YYYY, month:12, day:31})})-[:NEXT]->(:Year)` 
and
`(:Week{from:date({year:YYYY, month:MM, day:DD}), until:date({year:YYYY, month:MM, day:DD+6})})-[:NEXT]->(:Week)`

The provenance meta data model follows this structure:

```
(:Source)-[:PROVIDES]->(:Dataset)-[:CONTRIBUTES]->(:Fact)<-[:PREDICATE_]-(:Subject)
                                                  /       \
                   (:Value)<-[:CLAUSE_OR_PHRASE]-           -[:_PREDICATE]->(:Object)
```
                     
Where: `(:Source)-[:PROVIDES]->(:Dataset)` represents a 'Provenance Chain', or (PC) and (:Fact) represents a complex 
datum. 

I am enforcing a vocabulary convention to describe epochs with 'from:' and 'until:' where not aligned with a specific
period (eg, a Year) and 'during:' to describe anual data, which has an intuitive beginning and ending. I split 
predicates over nodes representing complex data using prepositions relative to the agent/entity. 
For example: (state)-[:MEMBER]->(:Fact)-[:MEMBER_IN]->(system) hoping that labelling relationships this way will be 
a little more descriptive and prevent vague references. 



Finally, to the best of my abilities I have written this script to import data prepared by authors who provide it 
openly and freely for academic purposes; presumably or explicitly under an academic free license. I am not the 
author of the data. Where necessary, I have modified their data in order to facilitate its import into the graph
database. In many cases this just means unzipping archived files to extract the relevant comma-separated value (CSV)
data. In some cases, I manipulated/reformatted their data from Stata .dat files, ASCII .asc files, Microsoft .xls/xlsx
files, etc. In the case of Jack Levy's "Great Powers" dataset, I had to extract it from multiple text files, which 
required extensive reformatting. In the case of Jon Pevehouse and Timothy Nordstrom's "International Governmental 
Organizations Data Set" I extracted descriptions of the IGOs from the Codebook .pdf file. Most of the data 
manipulation, aka "munging" I have done has been by hand (or at least using regular expressions, REGEX), resaving
via text editor or LibreOffice Calc, or by converting files programmatically (usually, using John Nelson's Docker 
container with Evan Miller's 'readstat' dataset conversion software, available at https://github.com/jbn/readstat) 
In all cases, I have done my best to maintain the integrity of the authors' data and to cite them duly and properly. 
In those cases where it is not possible to simply read the originating author's files into Neo4j, sharing my modified
data files will need to wait until I (have a chance) to request permission from the authors to reshare their work.

Data gets created/imported in this order, with resources metadata (the provenance chain) preceding each import:
1. Time tree -- an in-graph representation of weeks and months in years in a timeline, beginning 1815
2. Levy Great Powers, Great Power Wars
3. import states2016.csv 
2. (DONE) import major2016
4. (DONE) import NMC_5_0-wsupplementary.csv 
5. (DONE) import Gleditsch extended war data
6. (DONE) import Diplomatic_Exchange_2006v1.csv 
7. import COW_Trade_4.0 and Trade Supplements
8. import cow_alliances
9. import Intergovernmental_Organizations(v2.3)
10. import MIDA_4.csv / 
11.    import MIDB_4.csv / 
11. import MIDLOC_1.1.csv  
12. import Inter-StateWarData_v4.0.csv
13. import Intra-StateWarData_v4.1.csv
14. import Extra-StateWarData_v4.0.csv /
15. import MID Narratives 200
16. revise tasks 1-15 so that data is parsed correctly (regex?) from original sources without modifications.
end of tasks


Before I get started, I want to add nodes in the graph to represent years, since some data is about
years as much as it about the state. e.g., `(state)-[:HAS_MILEX_IN]->(1818{began:date({year:1818, month:1, day:1})})`
I am trying to follow ISO 8601, which specifies that the first week of the year begins on the first Thursday of the 
year (even though there was no ISO when the bulk of the data begins, in 1815. The last week of the year always 
includes 28 December. The last day of the year, 31 December could occur on the first week of the following year.)

```
// Assert uniqueness of begining dates and create index for faster date querying
CREATE CONSTRAINT ON (y:Year) ASSERT y.began IS UNIQUE;
CREATE CONSTRAINT ON (w:Week) ASSERT w.began IS UNIQUE;
```

Discussed and reported on Neo4j's Slack channel on 18 June 2018, Neo4j has a bug that intermittently reports bad first 
day of the week when given a year and week number. My workaround was to create a spreadsheet of values and read it in.

``` 
WITH range(1815, 2020) AS years
FOREACH (yr IN years |
MERGE (y:Year{name:toString(yr), began:date({year:yr, month:1, day:1}), ended:date({year:yr, month:12, day:31}),
  last:date({year:yr, month:12, day:28}) })
SET y.weeksThisYear = y.last.week ) ;
// begany,beganm,begand,endedy,endedm,endedd,weeknum,year
LOAD CSV WITH HEADERS FROM "file:///weeksNums.csv" AS row
MATCH (y:Year{began:date({year:toInteger(row.year)})})
CREATE (w:Week{began:date({year:toInteger(row.begany), month:toInteger(row.beganm), day:toInteger(row.begand)}),
  ended:date({year:toInteger(row.endedy), month:toInteger(row.endedm), day:toInteger(row.endedd)}), 
  weekOfYear:toInteger(row.weeknum), name:toString((toInteger(row.year) * 100) + row.weeknum)-[:PART_OF{
  weekOfYear:toInteger(row.weeknum)}]->(y)
```

Before using the timeline creation script, try this test (which does not commit anything to the database) to see 
if the results are correct:
 
```
UNWIND[date({year:1816,week:1}), date({year:1816,week:52}), date({year:1817,week:1}), date({year:1817,week:10}), 
date({year:1817,week:30}), date({year:1817,week:52}), date({year:1818,week:1}), date({year:1818,week:52}), 
date({year:1819,week:1}), date({year:1819,week:52}) ] AS theFirstDateOfThisWeek RETURN theFirstDateOfThisWeek
```

I get this, which is wrong:
```
theFirstDateOfThisWeek
"1816-01-01" // correct
"1816-12-23" // correct
"1817-12-30" // should be "1816-12-30" year is +1
"1818-03-03" // should be "1817-03-03" year is +1
"1818-07-21" // should be "1817-07-21" year is +1
"1818-12-22" // should be "1817-12-22" year is +1
"1817-12-30" // should be "1817-12-29" mo/day for 1817
"1818-12-22" // should be "1818-12-28" mo/day for 1817
"1819-01-04" // correct
"1819-12-27" // correct 
```

If you get the correct results, you can create the timeline with this script:

```
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
```

For now, I'm using a less crafty method: I wrote all the timeline data into a spreadsheet anc create the timeline by 
importing that data. It's pedestrian, but solves the immediate problem.
