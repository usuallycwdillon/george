// This script provides some metadata for GIS import files. The data here represents the author's best guess in some cases
// and 'good enough' guesses in other places (like the validity dates, which do not correspond to dates of war breakout
// or conclusion with a peace agreement or truce.

CREATE (s:Source {
  name:"ThinkQuest Historical Political Boundaries",
  version:0.9,
  published:date({year:2013, month:07, day:1}),
  validFrom:date({year:1815, month:1, day:1}),
  validUntil:date({year:1994, month:12, day:31}),
  host:"http://web.archive.org/web/20080417214617/http://library.thinkquest.org:80/C006628/index2.html",
  overview:"The GIS data presented in this site was hand-created by students and as such is not guaranteed to be accurate. Many references used in creating the data conflicted with each other, and we were forced to pick one reference as being more accurate. In most cases, the data is only meant to be used on a large scale, so that only the relative position of countries should be trusted. It is estimated that political boundaries have an average error of 40 miles. Since relative positions were used heavily, the most accurate borders are those that run along a major river or touch a coastline. We request that any data found to be inaccurate be reported to Team C006628. Again, as this data is created by students, we hold no responsibility for the use of the data outside of this site."
})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"countries 1815",
  version:0.9,
  published:date({year:2013, month:07, day:1}),
  validFrom:date({year:1815, month:1, day:1}),
  validUntil:date({year:1879, month:12, day:31}),
  filename:"cntry1815.shp"})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"countries 1880",
  version:0.9,
  published:date({year:2013, month:07, day:1}),
  validFrom:date({year:1880, month:1, day:1}),
  validUntil:date({year:1913, month:12, day:31}),
  filename:"cntry1880.shp"})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"countries 1914",
  version:0.9,
  published:date({year:2013, month:07, day:1}),
  validFrom:date({year:1914, month:1, day:1}),
  validUntil:date({year:1944, month:12, day:31}),
  filename:"cntry1914.shp"})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"countries 1945",
  version:0.9,
  published:date({year:2013, month:07, day:1}),
  validFrom:date({year:1945, month:1, day:1}),
  validUntil:date({year:1993, month:12, day:31}),
  filename:"cntry1945.shp"})
CREATE (s)-[:PROVIDES]->(:Dataset{
  name:"countries 1994",
  version:0.9,
  published:date({year:2013, month:07, day:1}),
  validFrom:date({year:1994, month:1, day:1}),
  filename:"cntry1994.shp"});



// Call hexFactory.HexFactory, then Create BORDERS relationships
