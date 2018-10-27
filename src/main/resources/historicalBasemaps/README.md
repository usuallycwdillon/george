# COW-linked, Historical Base Maps in GeoJSON

This repository contains several GeoJSON files of historical political boundaries with reference to the state system defined in the [Correlates of War](http://correlatesofwar.org) (COW) project. More specifically, each depiction of political boundaries in a given year includes references to the COW `ccode` country code, `statename` state name, and `abb` abbreviation for the states that were part of the state system in that year. To make them more widely useful, I linked the reference data to the [Expanded State System] (http://ksgleditsch.com/statelist.html) defined by Kristian Gleditsch. This expanded data includes all of the COW states as well as some others. Refer to Gleditsch's publication documentation for more information. The provenance metadata (which state references derive from COW via Gleditsch and which derive only from Gleditsch) is not included in these files because it's built into a separate, related project. 

These GeoJSON files are an artifact of some of my research on world order. I needed a way to represent conflict data spatially. I also needed my data to be serializable in Java (my target computing environment is distributed) which precluded using the shapefiles produced by the original authors, "ThinkQuest Team C006628". 

This data project started as a fork of André Ourednik's [Historical boundaries](https://github.com/aourednik/historical-basemaps) project. Ourednik converted several of the ThinkQuest Team's ESRI shapefiles into the GeoJSON format. I made no changes to the geographic data (political boundaries) but I _HAVE_ changed the names of several territories, made corrections. (E.g., the original data for the territory that includes current-day Korea and Japan was attributed to Korea. In fact, the Empire of Japan occupied the Korean Peninsula.) I also replaced some empty fields with 'none', labeled unclaimed territory iteratively (e.g., 'Unclaimed 1', 'Unclaimed 2', ...) and added abbreviations where they were lacking. This was a particular problem in the file for 1880, which is noticeably different than the other years. (#TODO: Align 1880 indigenously-derived territorial names with the anglo-centric names used in 1815 and 1914)

## Caveats
This data may be useful, but it has not been validated. In fact, the Internet Archive description of Sun's original ThinkQuest project (an early attempt at collaborative content development over the internet) refers to ThinkQuest teams as "students". Whether the original shapefile were developed by primary school children or graduate students, I do not know. My guess is that the original data was developed by high school or college students. 

## Ontology
In my research, I refer to these boundary units as 'territories' which are _NOT_ synonymous with 'states'. The direct reference to COW country codes is not intended to be a claim that the territory (the GeoJSON 'Feature') represents the whole territory of the referenced state. These files to not include data about colonial holdings or suzerainty. 

## Credits
Gleditsch, Kristian S. & Michael D. Ward. 1999. "Interstate System Membership: A Revised List of the Independent States since 1816." International Interactions 25: 393-413. 

André Ourednik, who shared his GeoJSON file conversions.

I did this work with [qGIS](https://github.com/qgis/QGIS) and appreciate OSS.

ThinkQuest Team C006628, whoever they are.





