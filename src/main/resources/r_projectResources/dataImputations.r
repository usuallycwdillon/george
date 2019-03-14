## Author: Clarence Dillon
## Organization: George Mason University
## This script queries the GEORGE database for facts, imputes missing time-series data, and saves the imputed facts back to the databse.
## The first compuation operates on Military Personnel facts and comments describe the process. Subsequent processes are not commented, but
## follow the same process. Exceptions from this first procedure are commented, as required.

library("RNeo4j")
library("naniar")
library("ggplot2")
library("imputeTS")
library("dplyr")
library("tidyr")
library("data.table")


## Configure a connection to the graph database
graph <- startGraph("http://192.168.1.94:7474/db/data",
                    username="neo4j",
                    password="george")

# CREATE (c:Computation{description:'Values imputed in R using package imputeTS', method:'na.interpolation(dataframe[[country]], option = spline)'}) references this computation to maintain provenance metadata
createNode(graph, 'Computation', description = 'Values imputed in R using package imputeTS', method = 'na.interpolation(dataframe[[country]], option = spline)', filename = 'dataImputations.r')

# The following process gets repeated (verbosely) for the following NMC data:
# MILPER
# MILEX
# URBAN_POP



#  Distinct records
rat.all <- "MATCH (n:System{name:'COW State System'})-[:MEMBER_OF]-(sy:MembershipFact)-[:MEMBER]-(s:State)-[:MILPER]-(m:MilPerFact)-[:DURING]-(y:Year) WITH DISTINCT s, m, y, sy  MATCH (n)-[:MEMBER_OF]-(sy)-[:MEMBER]-(s)-[:MILPER]-(m)-[:DURING]-(y) WHERE sy.from.year <= toInteger(y.name) <= sy.until.year RETURN s.abb, s.cowcode, sy.from.year, sy.until.year, y.name, m.value"
df.all <- cypher(graph, rat.all)
colnames(df.all) <- c("abb", "cowcode", "from", "until", "year", "pax")

## Preserve explicit NAs
df.all$pax[df.all$pax == "UNK"] <- "-9"

## Correct colunn data types
df.all$year <- as.integer(df.all$year)
df.all$pax  <- as.integer(df.all$pax)

## Convert df to data table
dt <- data.table(df.all)

## pare down to necessary coluns/purge unnecessary columns
dtm <- dt[, c(1, 5, 6)]

## Reshape and collect colnames (country abbreviations)
dma <- spread(dtm, abb, pax, fill = 0)
dtma <- data.table(dma)
dt.cols <- colnames(dtma)
# dt.cols

## Replace explicit NAs in the faceted table
dtmn <- replace_with_na_all(data=dtma, condition = ~.x == -9)
dtcp <- dtmn

## Interpolate NAs by column (country)
for (i in 2:length(dt.cols)) {
  try (
    dtma[, i] <- na.interpolation(dtcp[[i]], option = 'stine')
  )
}

## Melt data back to 1 row per observation and rename cols before merging old data back in (where appropriate)
dt.long <- melt(dtma, id.vars = "year")
colnames(dt.long) <- c("year", "abb", "newpax")
dt.comb <- merge(dt.long, dt, c("year", "abb"))

## round values back to integers
dt.comb$newpax <- round(dt.comb$newpax)

## Plot, just to see what it looks like now; not run in production
ggplot(dt.comb, aes(x=factor(year), y=pax, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")
ggplot(dt.comb, aes(x=factor(year), y=newpax, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")

## Collect only those rows with previously missing values (and plot, to see what all this created)
dt.missing <- dt.comb[dt.comb$pax == -9]
dt.missing[, year := as.character(year)]
dt.missing$year
ggplot(dt.missing, aes(x=factor(year), y=newpax, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")


## Save these calculated MilPerFact nodes back to the database, preserving the metadata
query = "
MATCH (s:State{abb:{state_abb}, cowcode:{state_cowcode}})-[:MILPER]->(m:MilPerFact{name:'Military PAX', denomination:'thousand PAX', value:'UNK'})-[:DURING]->(y:Year{name:{year_val}}), (c:Computation{description:'Values imputed in R using package imputeTS', filename:'dataImputations.r'})
SET m.value = {fact_newpax}
MERGE (c)-[:COMPUTED]->(m)
"
t = newTransaction(graph)
for (i in 1:nrow(dt.missing)) {
  state_abb = dt.missing[i, ]$abb
  state_cowcode = dt.missing[i, ]$cowcode
  year_val = dt.missing[i, ]$year
  fact_newpax = dt.missing[i, ]$newpax

  appendCypher(t,
               query,
               state_abb = state_abb,
               state_cowcode = state_cowcode,
               year_val = year_val,
               fact_newpax = fact_newpax
  )
}

commit(t)
## End of Military Personnel Imputations


## Military Expenditures
rat.all <- "MATCH (n:System{name:'COW State System'})-[:MEMBER_OF]-(sy:MembershipFact)-[:MEMBER]-(s:State)-[:MILEX]-(m:MilExFact)-[:DURING]-(y:Year) WITH DISTINCT s, m, y, sy  MATCH (n)-[:MEMBER_OF]-(sy)-[:MEMBER]-(s)-[:MILEX]-(m)-[:DURING]-(y) WHERE sy.from.year <= toInteger(y.name) <= sy.until.year RETURN s.abb, s.cowcode, sy.from.year, sy.until.year, y.name, m.value"
df.all <- cypher(graph, rat.all)
colnames(df.all) <- c("abb", "cowcode", "from", "until", "year", "exp")

df.all$exp[df.all$exp == "UNK"] <- "-9"

df.all$year <- as.integer(df.all$year)
df.all$exp  <- as.integer(df.all$exp)

dt <- data.table(df.all)
dtm <- dt[, c(1, 5, 6)]

dma <- spread(dtm, abb, exp, fill = 0)
dtma <- data.table(dma)
dt.cols <- colnames(dtma)

dtmn <- replace_with_na_all(data=dtma, condition = ~.x == -9)
dtcp <- dtmn

for (i in 2:length(dt.cols)) {
  try (
    dtma[, i] <- na.interpolation(dtcp[[i]], option = 'stine')
  )
}

dt.long <- melt(dtma, id.vars = "year")
colnames(dt.long) <- c("year", "abb", "newexp")
dt.comb <- merge(dt.long, dt, c("year", "abb"))

dt.comb$newexp <- round(dt.comb$newexp)

## Plot, just to see what it looks like now; not run in production
# ggplot(dt.comb, aes(x=factor(year), y=exp, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")
# ggplot(dt.comb, aes(x=factor(year), y=newexp, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")

dt.missing <- dt.comb[dt.comb$exp == -9]
dt.missing[, year := as.character(year)]
# dt.missing$year
# dt.missing


query = "
MATCH (s:State{abb:{state_abb}, cowcode:{state_cowcode}})-[:MILEX]->(m:MilExFact{name:'Military Expenditures', value:-9})-[:DURING]->(y:Year{name:{year_val}}), (c:Computation{description:'Values imputed in R using package imputeTS', filename:'dataImputations.r'})
SET m.value = {fact_newexp}
MERGE (c)-[:COMPUTED]->(m)
"
t = newTransaction(graph)
for (i in 1:nrow(dt.missing)) {
  state_abb = dt.missing[i, ]$abb
  state_cowcode = dt.missing[i, ]$cowcode
  year_val = dt.missing[i, ]$year
  fact_newexp = dt.missing[i, ]$newexp

  appendCypher(t,
               query,
               state_abb = state_abb,
               state_cowcode = state_cowcode,
               year_val = year_val,
               fact_newexp = fact_newexp
  )
}

commit(t)
## End of Military Expenditure Imutations


## Urban Population
rat.all <- "MATCH (n:System{name:'COW State System'})-[:MEMBER_OF]-(sy:MembershipFact)-[:MEMBER]-(s:State)-[:URBAN_POPULATION]-(m:UrbanPopulationFact)-[:DURING]-(y:Year) WITH DISTINCT s, m, y, sy  MATCH (n)-[:MEMBER_OF]-(sy)-[:MEMBER]-(s)-[:URBAN_POPULATION]-(m)-[:DURING]-(y) WHERE sy.from.year <= toInteger(y.name) <= sy.until.year RETURN s.abb, s.cowcode, sy.from.year, sy.until.year, y.name, m.value"
df.all <- cypher(graph, rat.all)
colnames(df.all) <- c("abb", "cowcode", "from", "until", "year", "pop")

df.all$pop[df.all$pop == "UNK"] <- "-9"

df.all$year <- as.integer(df.all$year)
df.all$pop  <- as.integer(df.all$pop)

dt <- data.table(df.all)
dtm <- dt[, c(1, 5, 6)]

dma <- spread(dtm, abb, pop, fill = 0)
dtma <- data.table(dma)
dt.cols <- colnames(dtma)

dtmn <- replace_with_na_all(data=dtma, condition = ~.x == -9)
dtcp <- dtmn

for (i in 2:length(dt.cols)) {
  try (
    dtma[, i] <- na.interpolation(dtcp[[i]], option = 'stine')
  )
}

dt.long <- melt(dtma, id.vars = "year")
colnames(dt.long) <- c("year", "abb", "newpop")
dt.comb <- merge(dt.long, dt, c("year", "abb"))

dt.comb$newpop <- round(dt.comb$newpop)

## Plot, just to see what it looks like now; not run in production
ggplot(dt.comb, aes(x=factor(year), y=pop, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")
ggplot(dt.comb, aes(x=factor(year), y=newpop, color=abb, group=abb)) + geom_line() + theme(legend.position = "none")

dt.missing <- dt.comb[dt.comb$pop == -9]
dt.missing[, year := as.character(year)]
dt.missing$year
dt.missing

query = "
MATCH (s:State{abb:{state_abb}, cowcode:{state_cowcode}})-[:URBAN_POPULATION]->(m:UrbanPopulationFact{name:'Urban Population', value:-9})-[:DURING]->(y:Year{name:{year_val}}), (c:Computation{description:'Values imputed in R using package imputeTS', filename:'dataImputations.r'})
SET m.value = {fact_newpop}
MERGE (c)-[:COMPUTED]->(m)
"
t = newTransaction(graph)
for (i in 1:nrow(dt.missing)) {
  state_abb = dt.missing[i, ]$abb
  state_cowcode = dt.missing[i, ]$cowcode
  year_val = dt.missing[i, ]$year
  fact_newpop = dt.missing[i, ]$newpop

  appendCypher(t,
               query,
               state_abb = state_abb,
               state_cowcode = state_cowcode,
               year_val = year_val,
               fact_newpop = fact_newpop
  )
}

commit(t)
## End of Urban Population Imputations
