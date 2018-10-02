// MID Locations
CREATE (d:Source{
  project:"Correlates of War",
  name:"MIDLOC",
  version:toFloat(1.1),
  published:date({year:2010, month:1}),
//  validFrom:date({year:1816, month:1, day:1}),
//  falidUntil:date({year:2016, month:12, day:31}),
  citation:"Braithwaite, Alex. 2010. 'MIDLOC: Introducing the Militarized Interstate Dispute (MID) Location Dataset.' Journal of Peace Research 47: 91-98.",
  url:"http://correlatesofwar.org/data-sets/MIDLOC",
  host:"Alex Braithwaite (University of Arizona)",
  poc:"Alex Braithwaite (abraith@arizona.edu)",
  overview:"The Militarized Interstate Dispute Location (MIDLOC) dataset details the precise geographic onset location of Militarized Interstate Disputes (MIDs) in the post-Napoleonic era (from 1816-2001).  The MIDLOC data offer a single point location to represent the onset of each individual MID between 1816 and 1992.  For the period 1993-2001, the data are more detailed, identifying a single point location for individual incidents within each MID.  Following common convention, latitude and longitude point coordinates are recorded for each observation.  Latitude is measured as the angular distance, in decimalized degrees (DD), of a point north or south of the equator.  Similarly, longitude is measured as the angular distance, in decimalized degrees (DD), of a point east or west of the Prime (Greenwich) Meridian. \nThere are a total of 3865 individual MIDLOC records. This is comprised of recorded onset locations for 2240 of 2332 independent MIDs from the MID 3.0 dataset—96% data coverage. 1939 of these 2240 took place between 1816 and 1992 and 301 between 1993 and 2001.  In addition to the MID-level data, this dataset also includes incident-level location data for the period 1993-2001.  There are 2122 incident-level records that comprise the 301 MIDs during this period.  196 of these 2122 records currently contain missing values.  Of these, however, only 3 are missing locations for the onset incident within the MID.",
  purpose:"This data set records the geographic locations of MIDs in latitude/longitude coordinates. Version 1.1 covers the 1816-2001 period."
})
CREATE (d)-[:PROVIDES]->(:Dataset{
  name:"MIDLOC Data",
  version:toFloat(1.1),
  published:date({year:2010, month:1}),
  purpose:"Data on the Militarized Interstate Dispute Location, 1816-2001",
  note:"values of -9 or -9999 designate missing values, and must be treated as such for appropriate analysis.",
  url:"http://correlatesofwar.org/data-sets/MIDLOC/midloc-1.1/at_download/file",
  filename:"MIDLOC_1.1.csv",
  bytesize:toInteger(327366)
})
CREATE (d)-[:PROVIDES]->(:File{
  name:"MIDLOC Codebook",
  version:toFloat(1.1),
  published:date({year:2010, month:1}),
  purpose:"Documentation for the data set",
  note:"values of -9 or -9999 designate missing values, and must be treated as such for appropriate analysis.",
  url:"http://correlatesofwar.org/data-sets/MIDLOC/midloc-v1-1-codebook/at_download/file",
  filename:"MIDLOC_v1.1_codebook.pdf",
  bytesize:toInteger(95951)
});

