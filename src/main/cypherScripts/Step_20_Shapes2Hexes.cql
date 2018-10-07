// This script provides some metadata for GIS import files. The data here represents the author's best guess in some cases
// and 'good enough' guesses in other places (like the validity dates, which do not correspond to dates of war breakout
// or conclusion with a peace agreement or truce.

CREATE (s:Source{
name:"Historical Base Maps",
version:0.9,
published:date({year:2018, month:05, day:18}),
validFrom:date({year:1815, month:1, day:1}),
validUntil:date({year:1994, month:12, day:31}),
host:"https://github.com/aourednik/historical-basemaps",
overview:"Collection of georeferenced boundaries of world countries and cultural regions for use in mapping historical data on the world scale."
})
CREATE (s)-[:PROVIDES]->(:Dataset{
name:"world 1815",
version:0.9,
published:date({year:2018, month:05, day:18}),
validFrom:date({year:1815, month:1, day:1}),
validUntil:date({year:1879, month:12, day:31}),
filename:"world_1815.geojson"})
CREATE (s)-[:PROVIDES]->(:Dataset{
name:"world 1880",
version:0.9,
published:date({year:2018, month:05, day:18}),
validFrom:date({year:1880, month:1, day:1}),
validUntil:date({year:1913, month:12, day:31}),
filename:"world_1880.geojson"})
CREATE (s)-[:PROVIDES]->(:Dataset{
name:"world 1914",
version:0.9,
published:date({year:2018, month:05, day:18}),
validFrom:date({year:1914, month:1, day:1}),
validUntil:date({year:1944, month:12, day:31}),
filename:"world_1914.geojson"})
CREATE (s)-[:PROVIDES]->(:Dataset{
name:"world 1945",
version:0.9,
published:date({year:2018, month:05, day:18}),
validFrom:date({year:1945, month:1, day:1}),
validUntil:date({year:1993, month:12, day:31}),
filename:"world_1945.geojson"})
CREATE (s)-[:PROVIDES]->(:Dataset{
name:"world 1994",
version:0.9,
published:date({year:2018, month:05, day:18}),
validFrom:date({year:1994, month:1, day:1}),
filename:"world_1994.geojson"});



// Call hexFactory.HexFactory, then Create BORDERS relationships
