// Reviewed, updated 14 SEP 2018; includes named facts
// ################################################################################################################### //
// ## The script below is for importing the state-to-IGO relationships from the IGO_stateunit data.                 ## //
// ## It's isolated down here because it's nearly 8,000 lines long                                                  ## //
// ## There is a small script for each column of IGO data. It does not create connections for missing or null relations//
// ## There are 529 columns of IGOs, so this script runs 529 times, once for each IGO. ############################### //
//    The data model follows the same pattern as other fact, subject, object year datasets.
//  (PC1)-[c]-(fact1)<-[:MEMBER]-(state)         (fact2)<-[c]-(PC2)
// (year)-[]-/      \-[:MEMBER_OF]-(IGO)-[PART]-/      \-[PART_OF]->(system)
//
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAAID"})
WITH *,
  CASE row.AAAID
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AAAID<>"-1" OR row.AAID<>"-9" THEN [1] ELSE [] END | 
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{
  name:"IGO Membership",
  membershipCode:row.AAAID,
  status:membership
})-[:DURING]->(p) CREATE (s)-[m:MEMBERSHIP]->(f)-[:MEMBER_OF]->(i) );

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAB"})
WITH *,
  CASE row.AAB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AAB<> "-1" OR row.ABB<>"-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", membershipCode:row.AAB, status:membership})-[:DURING]->(p)
  CREATE (s)-[m:MEMBERSHIP]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAAID"})
WITH *,
  CASE row.AAAID
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AAAID<> "-1" OR row.AAAID <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AAAID})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AAB"})
WITH *,
  CASE row.AAB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AAB<> "-1" OR row.AAB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AAB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AACB"})
WITH *,
  CASE row.AACB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AACB<> "-1" OR row.AACB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AACB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AACarib"})
WITH *,
  CASE row.AACarib
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AACarib<> "-1" OR row.AACarib <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AACarib})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AALCO"})
WITH *,
  CASE row.AALCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AALCO<> "-1" OR row.AALCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AALCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AARO"})
WITH *,
  CASE row.AARO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AARO<> "-1" OR row.AARO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AARO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AATA"})
WITH *,
  CASE row.AATA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AATA<> "-1" OR row.AATA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AATA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AATPO"})
WITH *,
  CASE row.AATPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AATPO<> "-1" OR row.AATPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AATPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ABEDA"})
WITH *,
  CASE row.ABEDA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ABEDA<> "-1" OR row.ABEDA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ABEDA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ABEPSEAC"})
WITH *,
  CASE row.ABEPSEAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ABEPSEAC<> "-1" OR row.ABEPSEAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ABEPSEAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACC"})
WITH *,
  CASE row.ACC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACC<> "-1" OR row.ACC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACCT"})
WITH *,
  CASE row.ACCT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACCT<> "-1" OR row.ACCT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACCT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);
MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACDT"})
WITH *,
  CASE row.ACDT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACDT<> "-1" OR row.ACDT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACDT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACI"})
WITH *,
  CASE row.ACI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACI<> "-1" OR row.ACI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACML"})
WITH *,
  CASE row.ACML
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACML<> "-1" OR row.ACML <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACML})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACP"})
WITH *,
  CASE row.ACP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACP<> "-1" OR row.ACP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACPEU"})
WITH *,
  CASE row.ACPEU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACPEU<> "-1" OR row.ACPEU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACPEU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACS"})
WITH *,
  CASE row.ACS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACS<> "-1" OR row.ACS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACSO"})
WITH *,
  CASE row.ACSO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACSO<> "-1" OR row.ACSO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACSO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACSSRB"})
WITH *,
  CASE row.ACSSRB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACSSRB<> "-1" OR row.ACSSRB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACSSRB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACU"})
WITH *,
  CASE row.ACU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACU<> "-1" OR row.ACU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ACWL"})
WITH *,
  CASE row.ACWL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ACWL<> "-1" OR row.ACWL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ACWL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFESD"})
WITH *,
  CASE row.AFESD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFESD<> "-1" OR row.AFESD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFESD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFEXIMB"})
WITH *,
  CASE row.AFEXIMB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFEXIMB<> "-1" OR row.AFEXIMB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFEXIMB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFGEC"})
WITH *,
  CASE row.AFGEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFGEC<> "-1" OR row.AFGEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFGEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFPU"})
WITH *,
  CASE row.AFPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFPU<> "-1" OR row.AFPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFRAND"})
WITH *,
  CASE row.AFRAND
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFRAND<> "-1" OR row.AFRAND <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFRAND})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFSPC"})
WITH *,
  CASE row.AFSPC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFSPC<> "-1" OR row.AFSPC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFSPC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AFTE"})
WITH *,
  CASE row.AFTE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AFTE<> "-1" OR row.AFTE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AFTE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AGC"})
WITH *,
  CASE row.AGC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AGC<> "-1" OR row.AGC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AGC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AGPUNDO"})
WITH *,
  CASE row.AGPUNDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AGPUNDO<> "-1" OR row.AGPUNDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AGPUNDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIC"})
WITH *,
  CASE row.AIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AIC<> "-1" OR row.AIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIDC"})
WITH *,
  CASE row.AIDC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AIDC<> "-1" OR row.AIDC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AIDC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIDO"})
WITH *,
  CASE row.AIDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AIDO<> "-1" OR row.AIDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AIDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIOEC"})
WITH *,
  CASE row.AIOEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AIOEC<> "-1" OR row.AIOEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AIOEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AIPO"})
WITH *,
  CASE row.AIPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AIPO<> "-1" OR row.AIPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AIPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AITIC"})
WITH *,
  CASE row.AITIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AITIC<> "-1" OR row.AITIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AITIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ALO"})
WITH *,
  CASE row.ALO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ALO<> "-1" OR row.ALO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ALO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMCO"})
WITH *,
  CASE row.AMCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMCO<> "-1" OR row.AMCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMCOW"})
WITH *,
  CASE row.AMCOW
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMCOW<> "-1" OR row.AMCOW <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMCOW})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMF"})
WITH *,
  CASE row.AMF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMF<> "-1" OR row.AMF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMIPO"})
WITH *,
  CASE row.AMIPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMIPO<> "-1" OR row.AMIPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMIPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMPTU"})
WITH *,
  CASE row.AMPTU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMPTU<> "-1" OR row.AMPTU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMPTU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMSC"})
WITH *,
  CASE row.AMSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMSC<> "-1" OR row.AMSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AMU"})
WITH *,
  CASE row.AMU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AMU<> "-1" OR row.AMU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AMU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ANZUS"})
WITH *,
  CASE row.ANZUS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ANZUS<> "-1" OR row.ANZUS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ANZUS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOAD"})
WITH *,
  CASE row.AOAD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AOAD<> "-1" OR row.AOAD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AOAD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOCRS"})
WITH *,
  CASE row.AOCRS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AOCRS<> "-1" OR row.AOCRS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AOCRS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOMR"})
WITH *,
  CASE row.AOMR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AOMR<> "-1" OR row.AOMR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AOMR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AOPU"})
WITH *,
  CASE row.AOPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AOPU<> "-1" OR row.AOPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AOPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AP"})
WITH *,
  CASE row.AP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AP<> "-1" OR row.AP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APCC"})
WITH *,
  CASE row.APCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APCC<> "-1" OR row.APCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APEC"})
WITH *,
  CASE row.APEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APEC<> "-1" OR row.APEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APFIC"})
WITH *,
  CASE row.APFIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APFIC<> "-1" OR row.APFIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APFIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APIBD"})
WITH *,
  CASE row.APIBD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APIBD<> "-1" OR row.APIBD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APIBD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APO"})
WITH *,
  CASE row.APO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APO<> "-1" OR row.APO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APPA"})
WITH *,
  CASE row.APPA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APPA<> "-1" OR row.APPA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APPA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APT"})
WITH *,
  CASE row.APT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APT<> "-1" OR row.APT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"APTU"})
WITH *,
  CASE row.APTU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.APTU<> "-1" OR row.APTU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.APTU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARC"})
WITH *,
  CASE row.ARC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ARC<> "-1" OR row.ARC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ARC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARCAL"})
WITH *,
  CASE row.ARCAL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ARCAL<> "-1" OR row.ARCAL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ARCAL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARIPO"})
WITH *,
  CASE row.ARIPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ARIPO<> "-1" OR row.ARIPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ARIPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ARPU"})
WITH *,
  CASE row.ARPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ARPU<> "-1" OR row.ARPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ARPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASATP"})
WITH *,
  CASE row.ASATP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASATP<> "-1" OR row.ASATP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASATP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASBLAC"})
WITH *,
  CASE row.ASBLAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASBLAC<> "-1" OR row.ASBLAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASBLAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASCBC"})
WITH *,
  CASE row.ASCBC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASCBC<> "-1" OR row.ASCBC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASCBC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASCRubber"})
WITH *,
  CASE row.ASCRubber
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASCRubber<> "-1" OR row.ASCRubber <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASCRubber})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASEAN"})
WITH *,
  CASE row.ASEAN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASEAN<> "-1" OR row.ASEAN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASEAN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASECNA"})
WITH *,
  CASE row.ASECNA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASECNA<> "-1" OR row.ASECNA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASECNA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASEF"})
WITH *,
  CASE row.ASEF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASEF<> "-1" OR row.ASEF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASEF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ASPAC"})
WITH *,
  CASE row.ASPAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ASPAC<> "-1" OR row.ASPAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ASPAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ATO"})
WITH *,
  CASE row.ATO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ATO<> "-1" OR row.ATO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ATO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ATPC"})
WITH *,
  CASE row.ATPC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ATPC<> "-1" OR row.ATPC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ATPC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AU"})
WITH *,
  CASE row.AU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AU<> "-1" OR row.AU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AVRDC"})
WITH *,
  CASE row.AVRDC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AVRDC<> "-1" OR row.AVRDC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AVRDC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AfDB"})
WITH *,
  CASE row.AfDB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AfDB<> "-1" OR row.AfDB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AfDB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AfrOPDA"})
WITH *,
  CASE row.AfrOPDA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AfrOPDA<> "-1" OR row.AfrOPDA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AfrOPDA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Africare"})
WITH *,
  CASE row.Africare
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Africare<> "-1" OR row.Africare <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Africare})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AmCC"})
WITH *,
  CASE row.AmCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AmCC<> "-1" OR row.AmCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AmCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Andean"})
WITH *,
  CASE row.Andean
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Andean<> "-1" OR row.Andean <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Andean})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AralSea"})
WITH *,
  CASE row.AralSea
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AralSea<> "-1" OR row.AralSea <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AralSea})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ArticC"})
WITH *,
  CASE row.ArticC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ArticC<> "-1" OR row.ArticC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ArticC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"AsDB"})
WITH *,
  CASE row.AsDB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.AsDB<> "-1" OR row.AsDB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.AsDB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BALTBAT"})
WITH *,
  CASE row.BALTBAT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BALTBAT<> "-1" OR row.BALTBAT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BALTBAT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BC"})
WITH *,
  CASE row.BC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BC<> "-1" OR row.BC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BCSC"})
WITH *,
  CASE row.BCSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BCSC<> "-1" OR row.BCSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BCSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BEF"})
WITH *,
  CASE row.BEF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BEF<> "-1" OR row.BEF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BEF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BEN"})
WITH *,
  CASE row.BEN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BEN<> "-1" OR row.BEN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BEN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BENELUX"})
WITH *,
  CASE row.BENELUX
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BENELUX<> "-1" OR row.BENELUX <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BENELUX})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BESCC"})
WITH *,
  CASE row.BESCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BESCC<> "-1" OR row.BESCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BESCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIISEF"})
WITH *,
  CASE row.BIISEF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BIISEF<> "-1" OR row.BIISEF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BIISEF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIONET"})
WITH *,
  CASE row.BIONET
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BIONET<> "-1" OR row.BIONET <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BIONET})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIPM"})
WITH *,
  CASE row.BIPM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BIPM<> "-1" OR row.BIPM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BIPM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BIS"})
WITH *,
  CASE row.BIS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BIS<> "-1" OR row.BIS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BIS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BNDP"})
WITH *,
  CASE row.BNDP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BNDP<> "-1" OR row.BNDP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BNDP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BOBP"})
WITH *,
  CASE row.BOBP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BOBP<> "-1" OR row.BOBP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BOBP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BONN"})
WITH *,
  CASE row.BONN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BONN<> "-1" OR row.BONN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BONN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"BSEC"})
WITH *,
  CASE row.BSEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.BSEC<> "-1" OR row.BSEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.BSEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAAD"})
WITH *,
  CASE row.CAAD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAAD<> "-1" OR row.CAAD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAAD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAARC"})
WITH *,
  CASE row.CAARC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAARC<> "-1" OR row.CAARC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAARC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAB"})
WITH *,
  CASE row.CAB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAB<> "-1" OR row.CAB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CABI"})
WITH *,
  CASE row.CABI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CABI<> "-1" OR row.CABI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CABI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CACB"})
WITH *,
  CASE row.CACB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CACB<> "-1" OR row.CACB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CACB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CACI"})
WITH *,
  CASE row.CACI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CACI<> "-1" OR row.CACI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CACI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAEC"})
WITH *,
  CASE row.CAEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAEC<> "-1" OR row.CAEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAECC"})
WITH *,
  CASE row.CAECC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAECC<> "-1" OR row.CAECC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAECC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAIPA"})
WITH *,
  CASE row.CAIPA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAIPA<> "-1" OR row.CAIPA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAIPA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAMES"})
WITH *,
  CASE row.CAMES
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAMES<> "-1" OR row.CAMES <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAMES})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAMRSD"})
WITH *,
  CASE row.CAMRSD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAMRSD<> "-1" OR row.CAMRSD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAMRSD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CAMSF"})
WITH *,
  CASE row.CAMSF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CAMSF<> "-1" OR row.CAMSF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CAMSF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CARICOM"})
WITH *,
  CASE row.CARICOM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CARICOM<> "-1" OR row.CARICOM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CARICOM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CARIFTA"})
WITH *,
  CASE row.CARIFTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CARIFTA<> "-1" OR row.CARIFTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CARIFTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CARII"})
WITH *,
  CASE row.CARII
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CARII<> "-1" OR row.CARII <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CARII})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CATC"})
WITH *,
  CASE row.CATC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CATC<> "-1" OR row.CATC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CATC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CBFP"})
WITH *,
  CASE row.CBFP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CBFP<> "-1" OR row.CBFP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CBFP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CBI"})
WITH *,
  CASE row.CBI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CBI<> "-1" OR row.CBI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CBI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CBSS"})
WITH *,
  CASE row.CBSS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CBSS<> "-1" OR row.CBSS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CBSS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CCNR"})
WITH *,
  CASE row.CCNR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CCNR<> "-1" OR row.CCNR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CCNR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CCOM"})
WITH *,
  CASE row.CCOM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CCOM<> "-1" OR row.CCOM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CCOM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CCPA"})
WITH *,
  CASE row.CCPA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CCPA<> "-1" OR row.CCPA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CCPA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CComm"})
WITH *,
  CASE row.CComm
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CComm<> "-1" OR row.CComm <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CComm})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CDB"})
WITH *,
  CASE row.CDB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CDB<> "-1" OR row.CDB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CDB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEAO"})
WITH *,
  CASE row.CEAO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEAO<> "-1" OR row.CEAO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEAO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEC"})
WITH *,
  CASE row.CEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEC<> "-1" OR row.CEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEEPN"})
WITH *,
  CASE row.CEEPN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEEPN<> "-1" OR row.CEEPN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEEPN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEFTA"})
WITH *,
  CASE row.CEFTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEFTA<> "-1" OR row.CEFTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEFTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEI"})
WITH *,
  CASE row.CEI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEI<> "-1" OR row.CEI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CELC"})
WITH *,
  CASE row.CELC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CELC<> "-1" OR row.CELC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CELC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEMAC"})
WITH *,
  CASE row.CEMAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEMAC<> "-1" OR row.CEMAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEMAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CENTO"})
WITH *,
  CASE row.CENTO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CENTO<> "-1" OR row.CENTO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CENTO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CEPGL"})
WITH *,
  CASE row.CEPGL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CEPGL<> "-1" OR row.CEPGL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CEPGL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CERN"})
WITH *,
  CASE row.CERN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CERN<> "-1" OR row.CERN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CERN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CFATF"})
WITH *,
  CASE row.CFATF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CFATF<> "-1" OR row.CFATF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CFATF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CFC"})
WITH *,
  CASE row.CFC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CFC<> "-1" OR row.CFC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CFC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CHSTEA"})
WITH *,
  CASE row.CHSTEA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CHSTEA<> "-1" OR row.CHSTEA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CHSTEA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CICA"})
WITH *,
  CASE row.CICA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CICA<> "-1" OR row.CICA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CICA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CIFC"})
WITH *,
  CASE row.CIFC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CIFC<> "-1" OR row.CIFC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CIFC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CIMA"})
WITH *,
  CASE row.CIMA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CIMA<> "-1" OR row.CIMA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CIMA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CIS"})
WITH *,
  CASE row.CIS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CIS<> "-1" OR row.CIS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CIS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMAEC"})
WITH *,
  CASE row.CMAEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CMAEC<> "-1" OR row.CMAEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CMAEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMAOC"})
WITH *,
  CASE row.CMAOC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CMAOC<> "-1" OR row.CMAOC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CMAOC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMEA"})
WITH *,
  CASE row.CMEA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CMEA<> "-1" OR row.CMEA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CMEA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CMHASG"})
WITH *,
  CASE row.CMHASG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CMHASG<> "-1" OR row.CMHASG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CMHASG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COE"})
WITH *,
  CASE row.COE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.COE<> "-1" OR row.COE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.COE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COLOMBO"})
WITH *,
  CASE row.COLOMBO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.COLOMBO<> "-1" OR row.COLOMBO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.COLOMBO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COMESA"})
WITH *,
  CASE row.COMESA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.COMESA<> "-1" OR row.COMESA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.COMESA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CONFEJES"})
WITH *,
  CASE row.CONFEJES
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CONFEJES<> "-1" OR row.CONFEJES <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CONFEJES})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COPTAC"})
WITH *,
  CASE row.COPTAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.COPTAC<> "-1" OR row.COPTAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.COPTAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COSAVE"})
WITH *,
  CASE row.COSAVE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.COSAVE<> "-1" OR row.COSAVE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.COSAVE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"COrg"})
WITH *,
  CASE row.COrg
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.COrg<> "-1" OR row.COrg <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.COrg})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CP"})
WITH *,
  CASE row.CP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CP<> "-1" OR row.CP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CPAB"})
WITH *,
  CASE row.CPAB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CPAB<> "-1" OR row.CPAB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CPAB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CPSC"})
WITH *,
  CASE row.CPSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CPSC<> "-1" OR row.CPSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CPSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CPU"})
WITH *,
  CASE row.CPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CPU<> "-1" OR row.CPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CSLF"})
WITH *,
  CASE row.CSLF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CSLF<> "-1" OR row.CSLF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CSLF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CTCAf"})
WITH *,
  CASE row.CTCAf
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CTCAf<> "-1" OR row.CTCAf <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CTCAf})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CTO"})
WITH *,
  CASE row.CTO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CTO<> "-1" OR row.CTO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CTO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CWGC"})
WITH *,
  CASE row.CWGC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CWGC<> "-1" OR row.CWGC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CWGC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CXC"})
WITH *,
  CASE row.CXC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CXC<> "-1" OR row.CXC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CXC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"CfRN"})
WITH *,
  CASE row.CfRN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.CfRN<> "-1" OR row.CfRN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.CfRN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ComAB"})
WITH *,
  CASE row.ComAB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ComAB<> "-1" OR row.ComAB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ComAB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ComSec"})
WITH *,
  CASE row.ComSec
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ComSec<> "-1" OR row.ComSec <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ComSec})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"DBGLS"})
WITH *,
  CASE row.DBGLS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.DBGLS<> "-1" OR row.DBGLS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.DBGLS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"DLCOEA"})
WITH *,
  CASE row.DLCOEA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.DLCOEA<> "-1" OR row.DLCOEA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.DLCOEA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Danube"})
WITH *,
  CASE row.Danube
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Danube<> "-1" OR row.Danube <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Danube})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EACM"})
WITH *,
  CASE row.EACM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EACM<> "-1" OR row.EACM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EACM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EACS"})
WITH *,
  CASE row.EACS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EACS<> "-1" OR row.EACS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EACS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EACSO"})
WITH *,
  CASE row.EACSO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EACSO<> "-1" OR row.EACSO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EACSO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EADB"})
WITH *,
  CASE row.EADB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EADB<> "-1" OR row.EADB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EADB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EAPC"})
WITH *,
  CASE row.EAPC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EAPC<> "-1" OR row.EAPC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EAPC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EAPO"})
WITH *,
  CASE row.EAPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EAPO<> "-1" OR row.EAPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EAPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EBRD"})
WITH *,
  CASE row.EBRD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EBRD<> "-1" OR row.EBRD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EBRD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECB"})
WITH *,
  CASE row.ECB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECB<> "-1" OR row.ECB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCA"})
WITH *,
  CASE row.ECCA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECCA<> "-1" OR row.ECCA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECCA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCAS"})
WITH *,
  CASE row.ECCAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECCAS<> "-1" OR row.ECCAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECCAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCB"})
WITH *,
  CASE row.ECCB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECCB<> "-1" OR row.ECCB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECCB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCD"})
WITH *,
  CASE row.ECCD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECCD<> "-1" OR row.ECCD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECCD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCM"})
WITH *,
  CASE row.ECCM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECCM<> "-1" OR row.ECCM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECCM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECCPIF"})
WITH *,
  CASE row.ECCPIF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECCPIF<> "-1" OR row.ECCPIF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECCPIF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECO"})
WITH *,
  CASE row.ECO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECO<> "-1" OR row.ECO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECOWAS"})
WITH *,
  CASE row.ECOWAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECOWAS<> "-1" OR row.ECOWAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECOWAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECPTA"})
WITH *,
  CASE row.ECPTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECPTA<> "-1" OR row.ECPTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECPTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ECSC"})
WITH *,
  CASE row.ECSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ECSC<> "-1" OR row.ECSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ECSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EEC"})
WITH *,
  CASE row.EEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EEC<> "-1" OR row.EEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EFCC"})
WITH *,
  CASE row.EFCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EFCC<> "-1" OR row.EFCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EFCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EFILWC"})
WITH *,
  CASE row.EFILWC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EFILWC<> "-1" OR row.EFILWC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EFILWC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EFTA"})
WITH *,
  CASE row.EFTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EFTA<> "-1" OR row.EFTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EFTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EIB"})
WITH *,
  CASE row.EIB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EIB<> "-1" OR row.EIB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EIB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EIPA"})
WITH *,
  CASE row.EIPA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EIPA<> "-1" OR row.EIPA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EIPA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ELDO"})
WITH *,
  CASE row.ELDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ELDO<> "-1" OR row.ELDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ELDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMB"})
WITH *,
  CASE row.EMB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EMB<> "-1" OR row.EMB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EMB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMBC"})
WITH *,
  CASE row.EMBC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EMBC<> "-1" OR row.EMBC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EMBC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMBL"})
WITH *,
  CASE row.EMBL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EMBL<> "-1" OR row.EMBL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EMBL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMI"})
WITH *,
  CASE row.EMI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EMI<> "-1" OR row.EMI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EMI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EMPPO"})
WITH *,
  CASE row.EMPPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EMPPO<> "-1" OR row.EMPPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EMPPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPA"})
WITH *,
  CASE row.EPA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EPA<> "-1" OR row.EPA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EPA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPFSC"})
WITH *,
  CASE row.EPFSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EPFSC<> "-1" OR row.EPFSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EPFSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPO"})
WITH *,
  CASE row.EPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EPO<> "-1" OR row.EPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EPU"})
WITH *,
  CASE row.EPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EPU<> "-1" OR row.EPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ESA"})
WITH *,
  CASE row.ESA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ESA<> "-1" OR row.ESA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ESA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ESO"})
WITH *,
  CASE row.ESO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ESO<> "-1" OR row.ESO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ESO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ESRO"})
WITH *,
  CASE row.ESRO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ESRO<> "-1" OR row.ESRO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ESRO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ETF"})
WITH *,
  CASE row.ETF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ETF<> "-1" OR row.ETF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ETF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EU"})
WITH *,
  CASE row.EU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EU<> "-1" OR row.EU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUFMD"})
WITH *,
  CASE row.EUFMD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EUFMD<> "-1" OR row.EUFMD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EUFMD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EURATOM"})
WITH *,
  CASE row.EURATOM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EURATOM<> "-1" OR row.EURATOM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EURATOM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUROCONTROL"})
WITH *,
  CASE row.EUROCONTROL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EUROCONTROL<> "-1" OR row.EUROCONTROL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EUROCONTROL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUROFIMA"})
WITH *,
  CASE row.EUROFIMA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EUROFIMA<> "-1" OR row.EUROFIMA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EUROFIMA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"EUROMET"})
WITH *,
  CASE row.EUROMET
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.EUROMET<> "-1" OR row.EUROMET <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.EUROMET})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Entente"})
WITH *,
  CASE row.Entente
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Entente<> "-1" OR row.Entente <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Entente})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FAO"})
WITH *,
  CASE row.FAO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.FAO<> "-1" OR row.FAO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.FAO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FAPED"})
WITH *,
  CASE row.FAPED
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.FAPED<> "-1" OR row.FAPED <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.FAPED})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FDIPLAC"})
WITH *,
  CASE row.FDIPLAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.FDIPLAC<> "-1" OR row.FDIPLAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.FDIPLAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"FEC"})
WITH *,
  CASE row.FEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.FEC<> "-1" OR row.FEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.FEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"G15"})
WITH *,
  CASE row.G15
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.G15<> "-1" OR row.G15 <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.G15})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"G24"})
WITH *,
  CASE row.G24
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.G24<> "-1" OR row.G24 <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.G24})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"G3"})
WITH *,
  CASE row.G3
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.G3<> "-1" OR row.G3 <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.G3})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GATT"})
WITH *,
  CASE row.GATT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GATT<> "-1" OR row.GATT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GATT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GBACT"})
WITH *,
  CASE row.GBACT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GBACT<> "-1" OR row.GBACT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GBACT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GCC"})
WITH *,
  CASE row.GCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GCC<> "-1" OR row.GCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GCRSNC"})
WITH *,
  CASE row.GCRSNC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GCRSNC<> "-1" OR row.GCRSNC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GCRSNC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GEF"})
WITH *,
  CASE row.GEF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GEF<> "-1" OR row.GEF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GEF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GEO"})
WITH *,
  CASE row.GEO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GEO<> "-1" OR row.GEO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GEO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GHSI"})
WITH *,
  CASE row.GHSI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GHSI<> "-1" OR row.GHSI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GHSI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GLACSEC"})
WITH *,
  CASE row.GLACSEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GLACSEC<> "-1" OR row.GLACSEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GLACSEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GOIC"})
WITH *,
  CASE row.GOIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GOIC<> "-1" OR row.GOIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GOIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"GRBDO"})
WITH *,
  CASE row.GRBDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.GRBDO<> "-1" OR row.GRBDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.GRBDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"HCPIL"})
WITH *,
  CASE row.HCPIL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.HCPIL<> "-1" OR row.HCPIL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.HCPIL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IABE"})
WITH *,
  CASE row.IABE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IABE<> "-1" OR row.IABE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IABE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IABath"})
WITH *,
  CASE row.IABath
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IABath<> "-1" OR row.IABath <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IABath})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACB"})
WITH *,
  CASE row.IACB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IACB<> "-1" OR row.IACB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IACB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACI"})
WITH *,
  CASE row.IACI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IACI<> "-1" OR row.IACI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IACI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACS"})
WITH *,
  CASE row.IACS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IACS<> "-1" OR row.IACS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IACS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACSS"})
WITH *,
  CASE row.IACSS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IACSS<> "-1" OR row.IACSS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IACSS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IACW"})
WITH *,
  CASE row.IACW
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IACW<> "-1" OR row.IACW <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IACW})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IADB"})
WITH *,
  CASE row.IADB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IADB<> "-1" OR row.IADB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IADB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IADefB"})
WITH *,
  CASE row.IADefB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IADefB<> "-1" OR row.IADefB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IADefB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAEA"})
WITH *,
  CASE row.IAEA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAEA<> "-1" OR row.IAEA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAEA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAFC"})
WITH *,
  CASE row.IAFC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAFC<> "-1" OR row.IAFC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAFC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAHC"})
WITH *,
  CASE row.IAHC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAHC<> "-1" OR row.IAHC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAHC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAIAS"})
WITH *,
  CASE row.IAIAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAIAS<> "-1" OR row.IAIAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAIAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAIC"})
WITH *,
  CASE row.IAIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAIC<> "-1" OR row.IAIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAIGC"})
WITH *,
  CASE row.IAIGC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAIGC<> "-1" OR row.IAIGC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAIGC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAII"})
WITH *,
  CASE row.IAII
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAII<> "-1" OR row.IAII <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAII})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IALong"})
WITH *,
  CASE row.IALong
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IALong<> "-1" OR row.IALong <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IALong})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAMLO"})
WITH *,
  CASE row.IAMLO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAMLO<> "-1" OR row.IAMLO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAMLO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAPhy"})
WITH *,
  CASE row.IAPhy
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAPhy<> "-1" OR row.IAPhy <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAPhy})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARA"})
WITH *,
  CASE row.IARA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IARA<> "-1" OR row.IARA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IARA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARHC"})
WITH *,
  CASE row.IARHC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IARHC<> "-1" OR row.IARHC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IARHC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARadiO"})
WITH *,
  CASE row.IARadiO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IARadiO<> "-1" OR row.IARadiO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IARadiO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IARuhr"})
WITH *,
  CASE row.IARuhr
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IARuhr<> "-1" OR row.IARuhr <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IARuhr})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IAS"})
WITH *,
  CASE row.IAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IAS<> "-1" OR row.IAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IASAJ"})
WITH *,
  CASE row.IASAJ
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IASAJ<> "-1" OR row.IASAJ <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IASAJ})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IATB"})
WITH *,
  CASE row.IATB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IATB<> "-1" OR row.IATB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IATB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IATSJ"})
WITH *,
  CASE row.IATSJ
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IATSJ<> "-1" OR row.IATSJ <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IATSJ})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IATTC"})
WITH *,
  CASE row.IATTC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IATTC<> "-1" OR row.IATTC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IATTC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBA"})
WITH *,
  CASE row.IBA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBA<> "-1" OR row.IBA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBCS"})
WITH *,
  CASE row.IBCS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBCS<> "-1" OR row.IBCS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBCS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBE"})
WITH *,
  CASE row.IBE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBE<> "-1" OR row.IBE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBEC"})
WITH *,
  CASE row.IBEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBEC<> "-1" OR row.IBEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBI"})
WITH *,
  CASE row.IBI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBI<> "-1" OR row.IBI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBIER"})
WITH *,
  CASE row.IBIER
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBIER<> "-1" OR row.IBIER <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBIER})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBPMP"})
WITH *,
  CASE row.IBPMP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBPMP<> "-1" OR row.IBPMP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBPMP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IBRD"})
WITH *,
  CASE row.IBRD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IBRD<> "-1" OR row.IBRD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IBRD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAC"})
WITH *,
  CASE row.ICAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICAC<> "-1" OR row.ICAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAI"})
WITH *,
  CASE row.ICAI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICAI<> "-1" OR row.ICAI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICAI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAO"})
WITH *,
  CASE row.ICAO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICAO<> "-1" OR row.ICAO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICAO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICAmO"})
WITH *,
  CASE row.ICAmO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICAmO<> "-1" OR row.ICAmO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICAmO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICC"})
WITH *,
  CASE row.ICC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICC<> "-1" OR row.ICC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCEC"})
WITH *,
  CASE row.ICCEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICCEC<> "-1" OR row.ICCEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICCEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCILMB"})
WITH *,
  CASE row.ICCILMB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICCILMB<> "-1" OR row.ICCILMB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICCILMB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCO"})
WITH *,
  CASE row.ICCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICCO<> "-1" OR row.ICCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCROM"})
WITH *,
  CASE row.ICCROM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICCROM<> "-1" OR row.ICCROM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICCROM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCS"})
WITH *,
  CASE row.ICCS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICCS<> "-1" OR row.ICCS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICCS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICCSLT"})
WITH *,
  CASE row.ICCSLT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICCSLT<> "-1" OR row.ICCSLT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICCSLT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICDR"})
WITH *,
  CASE row.ICDR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICDR<> "-1" OR row.ICDR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICDR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICES"})
WITH *,
  CASE row.ICES
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICES<> "-1" OR row.ICES <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICES})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICFAM"})
WITH *,
  CASE row.ICFAM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICFAM<> "-1" OR row.ICFAM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICFAM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICHRB"})
WITH *,
  CASE row.ICHRB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICHRB<> "-1" OR row.ICHRB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICHRB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICMMP"})
WITH *,
  CASE row.ICMMP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICMMP<> "-1" OR row.ICMMP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICMMP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICNC"})
WITH *,
  CASE row.ICNC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICNC<> "-1" OR row.ICNC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICNC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICNWAF"})
WITH *,
  CASE row.ICNWAF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICNWAF<> "-1" OR row.ICNWAF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICNWAF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICPRP"})
WITH *,
  CASE row.ICPRP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICPRP<> "-1" OR row.ICPRP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICPRP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICPTU"})
WITH *,
  CASE row.ICPTU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICPTU<> "-1" OR row.ICPTU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICPTU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICRI"})
WITH *,
  CASE row.ICRI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICRI<> "-1" OR row.ICRI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICRI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICRPBC"})
WITH *,
  CASE row.ICRPBC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICRPBC<> "-1" OR row.ICRPBC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICRPBC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICSE"})
WITH *,
  CASE row.ICSE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICSE<> "-1" OR row.ICSE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICSE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICSEAF"})
WITH *,
  CASE row.ICSEAF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICSEAF<> "-1" OR row.ICSEAF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICSEAF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICSG"})
WITH *,
  CASE row.ICSG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICSG<> "-1" OR row.ICSG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICSG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICTM"})
WITH *,
  CASE row.ICTM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICTM<> "-1" OR row.ICTM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICTM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICWMD"})
WITH *,
  CASE row.ICWMD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICWMD<> "-1" OR row.ICWMD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICWMD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICfO"})
WITH *,
  CASE row.ICfO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICfO<> "-1" OR row.ICfO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICfO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IChemO"})
WITH *,
  CASE row.IChemO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IChemO<> "-1" OR row.IChemO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IChemO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ICivDO"})
WITH *,
  CASE row.ICivDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ICivDO<> "-1" OR row.ICivDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ICivDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IComO"})
WITH *,
  CASE row.IComO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IComO<> "-1" OR row.IComO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IComO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IDC"})
WITH *,
  CASE row.IDC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IDC<> "-1" OR row.IDC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IDC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IEA"})
WITH *,
  CASE row.IEA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IEA<> "-1" OR row.IEA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IEA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IEC"})
WITH *,
  CASE row.IEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IEC<> "-1" OR row.IEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IES"})
WITH *,
  CASE row.IES
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IES<> "-1" OR row.IES <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IES})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IEXB"})
WITH *,
  CASE row.IEXB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IEXB<> "-1" OR row.IEXB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IEXB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IFAD"})
WITH *,
  CASE row.IFAD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IFAD<> "-1" OR row.IFAD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IFAD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IFC"})
WITH *,
  CASE row.IFC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IFC<> "-1" OR row.IFC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IFC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IFCA"})
WITH *,
  CASE row.IFCA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IFCA<> "-1" OR row.IFCA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IFCA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IGAD"})
WITH *,
  CASE row.IGAD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IGAD<> "-1" OR row.IGAD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IGAD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IGC"})
WITH *,
  CASE row.IGC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IGC<> "-1" OR row.IGC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IGC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IGCC"})
WITH *,
  CASE row.IGCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IGCC<> "-1" OR row.IGCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IGCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IHO"})
WITH *,
  CASE row.IHO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IHO<> "-1" OR row.IHO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IHO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIA"})
WITH *,
  CASE row.IIA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IIA<> "-1" OR row.IIA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IIA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IICom"})
WITH *,
  CASE row.IICom
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IICom<> "-1" OR row.IICom <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IICom})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIE"})
WITH *,
  CASE row.IIE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IIE<> "-1" OR row.IIE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IIE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIF"})
WITH *,
  CASE row.IIF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IIF<> "-1" OR row.IIF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IIF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IIWEE"})
WITH *,
  CASE row.IIWEE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IIWEE<> "-1" OR row.IIWEE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IIWEE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IJO"})
WITH *,
  CASE row.IJO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IJO<> "-1" OR row.IJO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IJO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ILO"})
WITH *,
  CASE row.ILO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ILO<> "-1" OR row.ILO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ILO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ILZSG"})
WITH *,
  CASE row.ILZSG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ILZSG<> "-1" OR row.ILZSG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ILZSG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMBSlav"})
WITH *,
  CASE row.IMBSlav
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IMBSlav<> "-1" OR row.IMBSlav <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IMBSlav})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMC"})
WITH *,
  CASE row.IMC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IMC<> "-1" OR row.IMC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IMC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMF"})
WITH *,
  CASE row.IMF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IMF<> "-1" OR row.IMF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IMF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMI"})
WITH *,
  CASE row.IMI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IMI<> "-1" OR row.IMI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IMI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMO"})
WITH *,
  CASE row.IMO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IMO<> "-1" OR row.IMO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IMO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IMSO"})
WITH *,
  CASE row.IMSO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IMSO<> "-1" OR row.IMSO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IMSO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INCAP"})
WITH *,
  CASE row.INCAP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INCAP<> "-1" OR row.INCAP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INCAP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INFOFISH"})
WITH *,
  CASE row.INFOFISH
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INFOFISH<> "-1" OR row.INFOFISH <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INFOFISH})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INFSMK"})
WITH *,
  CASE row.INFSMK
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INFSMK<> "-1" OR row.INFSMK <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INFSMK})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INRO"})
WITH *,
  CASE row.INRO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INRO<> "-1" OR row.INRO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INRO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INSG"})
WITH *,
  CASE row.INSG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INSG<> "-1" OR row.INSG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INSG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INTELSAT"})
WITH *,
  CASE row.INTELSAT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INTELSAT<> "-1" OR row.INTELSAT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INTELSAT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"INTERPOL"})
WITH *,
  CASE row.INTERPOL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.INTERPOL<> "-1" OR row.INTERPOL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.INTERPOL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOATHRE"})
WITH *,
  CASE row.IOATHRE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOATHRE<> "-1" OR row.IOATHRE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOATHRE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOCom"})
WITH *,
  CASE row.IOCom
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOCom<> "-1" OR row.IOCom <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOCom})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOEz"})
WITH *,
  CASE row.IOEz
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOEz<> "-1" OR row.IOEz <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOEz})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOLM"})
WITH *,
  CASE row.IOLM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOLM<> "-1" OR row.IOLM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOLM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOMig"})
WITH *,
  CASE row.IOMig
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOMig<> "-1" OR row.IOMig <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOMig})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOOC"})
WITH *,
  CASE row.IOOC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOOC<> "-1" OR row.IOOC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOOC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOPCF"})
WITH *,
  CASE row.IOPCF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOPCF<> "-1" OR row.IOPCF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOPCF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOPH"})
WITH *,
  CASE row.IOPH
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOPH<> "-1" OR row.IOPH <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOPH})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IOcC"})
WITH *,
  CASE row.IOcC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IOcC<> "-1" OR row.IOcC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IOcC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPC"})
WITH *,
  CASE row.IPC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPC<> "-1" OR row.IPC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPGRI"})
WITH *,
  CASE row.IPGRI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPGRI<> "-1" OR row.IPGRI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPGRI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPI"})
WITH *,
  CASE row.IPI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPI<> "-1" OR row.IPI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPedI"})
WITH *,
  CASE row.IPedI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPedI<> "-1" OR row.IPedI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPedI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPentC"})
WITH *,
  CASE row.IPentC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPentC<> "-1" OR row.IPentC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPentC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPhyL"})
WITH *,
  CASE row.IPhyL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPhyL<> "-1" OR row.IPhyL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPhyL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IPrizeC"})
WITH *,
  CASE row.IPrizeC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IPrizeC<> "-1" OR row.IPrizeC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IPrizeC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRC"})
WITH *,
  CASE row.IRC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IRC<> "-1" OR row.IRC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IRC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRLCS"})
WITH *,
  CASE row.IRLCS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IRLCS<> "-1" OR row.IRLCS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IRLCS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRO"})
WITH *,
  CASE row.IRO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IRO<> "-1" OR row.IRO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IRO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRSG"})
WITH *,
  CASE row.IRSG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IRSG<> "-1" OR row.IRSG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IRSG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IRU"})
WITH *,
  CASE row.IRU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IRU<> "-1" OR row.IRU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IRU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISA"})
WITH *,
  CASE row.ISA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISA<> "-1" OR row.ISA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISB"})
WITH *,
  CASE row.ISB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISB<> "-1" OR row.ISB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISDB"})
WITH *,
  CASE row.ISDB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISDB<> "-1" OR row.ISDB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISDB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISHREST"})
WITH *,
  CASE row.ISHREST
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISHREST<> "-1" OR row.ISHREST <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISHREST})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISRBC"})
WITH *,
  CASE row.ISRBC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISRBC<> "-1" OR row.ISRBC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISRBC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISUPT"})
WITH *,
  CASE row.ISUPT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISUPT<> "-1" OR row.ISUPT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISUPT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ISuC"})
WITH *,
  CASE row.ISuC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ISuC<> "-1" OR row.ISuC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ISuC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITC"})
WITH *,
  CASE row.ITC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITC<> "-1" OR row.ITC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITCC"})
WITH *,
  CASE row.ITCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITCC<> "-1" OR row.ITCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITCLE"})
WITH *,
  CASE row.ITCLE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITCLE<> "-1" OR row.ITCLE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITCLE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITPA"})
WITH *,
  CASE row.ITPA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITPA<> "-1" OR row.ITPA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITPA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITRO"})
WITH *,
  CASE row.ITRO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITRO<> "-1" OR row.ITRO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITRO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITTO"})
WITH *,
  CASE row.ITTO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITTO<> "-1" OR row.ITTO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITTO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITU"})
WITH *,
  CASE row.ITU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITU<> "-1" OR row.ITU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"ITVRC"})
WITH *,
  CASE row.ITVRC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.ITVRC<> "-1" OR row.ITVRC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.ITVRC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUIC"})
WITH *,
  CASE row.IUIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IUIC<> "-1" OR row.IUIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IUIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPCT"})
WITH *,
  CASE row.IUPCT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IUPCT<> "-1" OR row.IUPCT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IUPCT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPIP"})
WITH *,
  CASE row.IUPIP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IUPIP<> "-1" OR row.IUPIP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IUPIP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPLAW"})
WITH *,
  CASE row.IUPLAW
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IUPLAW<> "-1" OR row.IUPLAW <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IUPLAW})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPNVP"})
WITH *,
  CASE row.IUPNVP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IUPNVP<> "-1" OR row.IUPNVP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IUPNVP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IUPR"})
WITH *,
  CASE row.IUPR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IUPR<> "-1" OR row.IUPR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IUPR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IVWO"})
WITH *,
  CASE row.IVWO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IVWO<> "-1" OR row.IVWO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IVWO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IWSG"})
WITH *,
  CASE row.IWSG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IWSG<> "-1" OR row.IWSG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IWSG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"IWhale"})
WITH *,
  CASE row.IWhale
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.IWhale<> "-1" OR row.IWhale <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.IWhale})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Iocean"})
WITH *,
  CASE row.Iocean
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Iocean<> "-1" OR row.Iocean <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Iocean})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"JALAAO"})
WITH *,
  CASE row.JALAAO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.JALAAO<> "-1" OR row.JALAAO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.JALAAO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"JINR"})
WITH *,
  CASE row.JINR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.JINR<> "-1" OR row.JINR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.JINR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"JNOLCRH"})
WITH *,
  CASE row.JNOLCRH
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.JNOLCRH<> "-1" OR row.JNOLCRH <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.JNOLCRH})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LACAC"})
WITH *,
  CASE row.LACAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LACAC<> "-1" OR row.LACAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LACAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LACP"})
WITH *,
  CASE row.LACP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LACP<> "-1" OR row.LACP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LACP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAEO"})
WITH *,
  CASE row.LAEO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LAEO<> "-1" OR row.LAEO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LAEO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAFDO"})
WITH *,
  CASE row.LAFDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LAFDO<> "-1" OR row.LAFDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LAFDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAFTA"})
WITH *,
  CASE row.LAFTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LAFTA<> "-1" OR row.LAFTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LAFTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAIA"})
WITH *,
  CASE row.LAIA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LAIA<> "-1" OR row.LAIA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LAIA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LAIEC"})
WITH *,
  CASE row.LAIEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LAIEC<> "-1" OR row.LAIEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LAIEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LATIN"})
WITH *,
  CASE row.LATIN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LATIN<> "-1" OR row.LATIN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LATIN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LCBC"})
WITH *,
  CASE row.LCBC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LCBC<> "-1" OR row.LCBC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LCBC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LGIDA"})
WITH *,
  CASE row.LGIDA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LGIDA<> "-1" OR row.LGIDA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LGIDA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LOAS"})
WITH *,
  CASE row.LOAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LOAS<> "-1" OR row.LOAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LOAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"LoN"})
WITH *,
  CASE row.LoN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.LoN<> "-1" OR row.LoN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.LoN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MARRI"})
WITH *,
  CASE row.MARRI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MARRI<> "-1" OR row.MARRI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MARRI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MCPTTC"})
WITH *,
  CASE row.MCPTTC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MCPTTC<> "-1" OR row.MCPTTC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MCPTTC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MCWCASM"})
WITH *,
  CASE row.MCWCASM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MCWCASM<> "-1" OR row.MCWCASM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MCWCASM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MEMTTA"})
WITH *,
  CASE row.MEMTTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MEMTTA<> "-1" OR row.MEMTTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MEMTTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MFO"})
WITH *,
  CASE row.MFO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MFO<> "-1" OR row.MFO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MFO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MIGA"})
WITH *,
  CASE row.MIGA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MIGA<> "-1" OR row.MIGA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MIGA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MOPAN"})
WITH *,
  CASE row.MOPAN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MOPAN<> "-1" OR row.MOPAN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MOPAN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MRU"})
WITH *,
  CASE row.MRU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MRU<> "-1" OR row.MRU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MRU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"MWN"})
WITH *,
  CASE row.MWN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.MWN<> "-1" OR row.MWN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.MWN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Mercosur"})
WITH *,
  CASE row.Mercosur
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Mercosur<> "-1" OR row.Mercosur <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Mercosur})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Montreal"})
WITH *,
  CASE row.Montreal
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Montreal<> "-1" OR row.Montreal <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Montreal})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NACAP"})
WITH *,
  CASE row.NACAP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NACAP<> "-1" OR row.NACAP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NACAP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAFO"})
WITH *,
  CASE row.NAFO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NAFO<> "-1" OR row.NAFO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NAFO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAFTA"})
WITH *,
  CASE row.NAFTA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NAFTA<> "-1" OR row.NAFTA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NAFTA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAM"})
WITH *,
  CASE row.NAM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NAM<> "-1" OR row.NAM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NAM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NAPPO"})
WITH *,
  CASE row.NAPPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NAPPO<> "-1" OR row.NAPPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NAPPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NASCO"})
WITH *,
  CASE row.NASCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NASCO<> "-1" OR row.NASCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NASCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NATO"})
WITH *,
  CASE row.NATO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NATO<> "-1" OR row.NATO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NATO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NCM"})
WITH *,
  CASE row.NCM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NCM<> "-1" OR row.NCM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NCM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NCRR"})
WITH *,
  CASE row.NCRR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NCRR<> "-1" OR row.NCRR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NCRR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NCTR"})
WITH *,
  CASE row.NCTR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NCTR<> "-1" OR row.NCTR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NCTR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NDF"})
WITH *,
  CASE row.NDF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NDF<> "-1" OR row.NDF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NDF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NEAFC"})
WITH *,
  CASE row.NEAFC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NEAFC<> "-1" OR row.NEAFC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NEAFC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NERC"})
WITH *,
  CASE row.NERC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NERC<> "-1" OR row.NERC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NERC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NIB"})
WITH *,
  CASE row.NIB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NIB<> "-1" OR row.NIB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NIB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NPAFC"})
WITH *,
  CASE row.NPAFC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NPAFC<> "-1" OR row.NPAFC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NPAFC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NPFSC"})
WITH *,
  CASE row.NPFSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NPFSC<> "-1" OR row.NPFSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NPFSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NRC"})
WITH *,
  CASE row.NRC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NRC<> "-1" OR row.NRC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NRC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NTSC"})
WITH *,
  CASE row.NTSC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NTSC<> "-1" OR row.NTSC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NTSC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NWHF"})
WITH *,
  CASE row.NWHF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NWHF<> "-1" OR row.NWHF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NWHF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"NordC"})
WITH *,
  CASE row.NordC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.NordC<> "-1" OR row.NordC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.NordC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OAPEC"})
WITH *,
  CASE row.OAPEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OAPEC<> "-1" OR row.OAPEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OAPEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OAS"})
WITH *,
  CASE row.OAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OAS<> "-1" OR row.OAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OAU"})
WITH *,
  CASE row.OAU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OAU<> "-1" OR row.OAU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OAU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCAM"})
WITH *,
  CASE row.OCAM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OCAM<> "-1" OR row.OCAM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OCAM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCAS"})
WITH *,
  CASE row.OCAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OCAS<> "-1" OR row.OCAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OCAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCCEDCA"})
WITH *,
  CASE row.OCCEDCA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OCCEDCA<> "-1" OR row.OCCEDCA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OCCEDCA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OCR"})
WITH *,
  CASE row.OCR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OCR<> "-1" OR row.OCR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OCR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OECD"})
WITH *,
  CASE row.OECD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OECD<> "-1" OR row.OECD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OECD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OECS"})
WITH *,
  CASE row.OECS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OECS<> "-1" OR row.OECS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OECS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OEEC"})
WITH *,
  CASE row.OEEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OEEC<> "-1" OR row.OEEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OEEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OESAS"})
WITH *,
  CASE row.OESAS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OESAS<> "-1" OR row.OESAS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OESAS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OIC"})
WITH *,
  CASE row.OIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OIC<> "-1" OR row.OIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OIV"})
WITH *,
  CASE row.OIV
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OIV<> "-1" OR row.OIV <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OIV})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OMDKR"})
WITH *,
  CASE row.OMDKR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OMDKR<> "-1" OR row.OMDKR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OMDKR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OPANAL"})
WITH *,
  CASE row.OPANAL
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OPANAL<> "-1" OR row.OPANAL <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OPANAL})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OPEC"})
WITH *,
  CASE row.OPEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OPEC<> "-1" OR row.OPEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OPEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OSCE"})
WITH *,
  CASE row.OSCE
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OSCE<> "-1" OR row.OSCE <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OSCE})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OSLO"})
WITH *,
  CASE row.OSLO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OSLO<> "-1" OR row.OSLO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OSLO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OSPAR"})
WITH *,
  CASE row.OSPAR
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OSPAR<> "-1" OR row.OSPAR <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OSPAR})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"OTIF"})
WITH *,
  CASE row.OTIF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.OTIF<> "-1" OR row.OTIF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.OTIF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAHC"})
WITH *,
  CASE row.PAHC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PAHC<> "-1" OR row.PAHC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PAHC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAHO"})
WITH *,
  CASE row.PAHO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PAHO<> "-1" OR row.PAHO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PAHO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAIGH"})
WITH *,
  CASE row.PAIGH
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PAIGH<> "-1" OR row.PAIGH <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PAIGH})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PAP"})
WITH *,
  CASE row.PAP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PAP<> "-1" OR row.PAP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PAP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PC"})
WITH *,
  CASE row.PC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PC<> "-1" OR row.PC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PCA"})
WITH *,
  CASE row.PCA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PCA<> "-1" OR row.PCA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PCA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PCB"})
WITH *,
  CASE row.PCB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PCB<> "-1" OR row.PCB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PCB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PCSP"})
WITH *,
  CASE row.PCSP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PCSP<> "-1" OR row.PCSP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PCSP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PED"})
WITH *,
  CASE row.PED
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PED<> "-1" OR row.PED <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PED})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIARC"})
WITH *,
  CASE row.PIARC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PIARC<> "-1" OR row.PIARC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PIARC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIBAC"})
WITH *,
  CASE row.PIBAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PIBAC<> "-1" OR row.PIBAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PIBAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PICDCS"})
WITH *,
  CASE row.PICDCS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PICDCS<> "-1" OR row.PICDCS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PICDCS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PICES"})
WITH *,
  CASE row.PICES
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PICES<> "-1" OR row.PICES <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PICES})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PICS"})
WITH *,
  CASE row.PICS
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PICS<> "-1" OR row.PICS <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PICS})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIF"})
WITH *,
  CASE row.PIF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PIF<> "-1" OR row.PIF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PIF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PIPD"})
WITH *,
  CASE row.PIPD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PIPD<> "-1" OR row.PIPD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PIPD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PMAESA"})
WITH *,
  CASE row.PMAESA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PMAESA<> "-1" OR row.PMAESA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PMAESA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PSI"})
WITH *,
  CASE row.PSI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PSI<> "-1" OR row.PSI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PSI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PSNARCO"})
WITH *,
  CASE row.PSNARCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PSNARCO<> "-1" OR row.PSNARCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PSNARCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PTASEA"})
WITH *,
  CASE row.PTASEA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PTASEA<> "-1" OR row.PTASEA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PTASEA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"PUASP"})
WITH *,
  CASE row.PUASP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.PUASP<> "-1" OR row.PUASP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.PUASP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RASCOM"})
WITH *,
  CASE row.RASCOM
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RASCOM<> "-1" OR row.RASCOM <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RASCOM})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RCAELA"})
WITH *,
  CASE row.RCAELA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RCAELA<> "-1" OR row.RCAELA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RCAELA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RCC"})
WITH *,
  CASE row.RCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RCC<> "-1" OR row.RCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RECSA"})
WITH *,
  CASE row.RECSA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RECSA<> "-1" OR row.RECSA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RECSA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RIMMO"})
WITH *,
  CASE row.RIMMO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RIMMO<> "-1" OR row.RIMMO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RIMMO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RIOPPAH"})
WITH *,
  CASE row.RIOPPAH
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RIOPPAH<> "-1" OR row.RIOPPAH <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RIOPPAH})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RIOgroup"})
WITH *,
  CASE row.RIOgroup
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RIOgroup<> "-1" OR row.RIOgroup <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RIOgroup})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RadioU"})
WITH *,
  CASE row.RadioU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RadioU<> "-1" OR row.RadioU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RadioU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"RepCom"})
WITH *,
  CASE row.RepCom
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.RepCom<> "-1" OR row.RepCom <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.RepCom})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SAAFA"})
WITH *,
  CASE row.SAAFA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SAAFA<> "-1" OR row.SAAFA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SAAFA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SAARC"})
WITH *,
  CASE row.SAARC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SAARC<> "-1" OR row.SAARC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SAARC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SACEP"})
WITH *,
  CASE row.SACEP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SACEP<> "-1" OR row.SACEP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SACEP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SACU"})
WITH *,
  CASE row.SACU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SACU<> "-1" OR row.SACU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SACU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SADC"})
WITH *,
  CASE row.SADC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SADC<> "-1" OR row.SADC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SADC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SADCC"})
WITH *,
  CASE row.SADCC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SADCC<> "-1" OR row.SADCC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SADCC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SAMI"})
WITH *,
  CASE row.SAMI
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SAMI<> "-1" OR row.SAMI <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SAMI})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SARTC"})
WITH *,
  CASE row.SARTC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SARTC<> "-1" OR row.SARTC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SARTC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCA"})
WITH *,
  CASE row.SCA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SCA<> "-1" OR row.SCA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SCA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCAf"})
WITH *,
  CASE row.SCAf
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SCAf<> "-1" OR row.SCAf <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SCAf})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCH"})
WITH *,
  CASE row.SCH
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SCH<> "-1" OR row.SCH <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SCH})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SCHENGEN"})
WITH *,
  CASE row.SCHENGEN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SCHENGEN<> "-1" OR row.SCHENGEN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SCHENGEN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SEAMEO"})
WITH *,
  CASE row.SEAMEO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SEAMEO<> "-1" OR row.SEAMEO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SEAMEO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SEATO"})
WITH *,
  CASE row.SEATO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SEATO<> "-1" OR row.SEATO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SEATO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SEGIB"})
WITH *,
  CASE row.SEGIB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SEGIB<> "-1" OR row.SEGIB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SEGIB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SELA"})
WITH *,
  CASE row.SELA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SELA<> "-1" OR row.SELA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SELA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SICA"})
WITH *,
  CASE row.SICA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SICA<> "-1" OR row.SICA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SICA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SIECA"})
WITH *,
  CASE row.SIECA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SIECA<> "-1" OR row.SIECA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SIECA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SITTDEC"})
WITH *,
  CASE row.SITTDEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SITTDEC<> "-1" OR row.SITTDEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SITTDEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SPC"})
WITH *,
  CASE row.SPC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SPC<> "-1" OR row.SPC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SPC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SRDO"})
WITH *,
  CASE row.SRDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SRDO<> "-1" OR row.SRDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SRDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SWAPU"})
WITH *,
  CASE row.SWAPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SWAPU<> "-1" OR row.SWAPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SWAPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SWPD"})
WITH *,
  CASE row.SWPD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SWPD<> "-1" OR row.SWPD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SWPD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"SugU"})
WITH *,
  CASE row.SugU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.SugU<> "-1" OR row.SugU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.SugU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"TARHEC"})
WITH *,
  CASE row.TARHEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.TARHEC<> "-1" OR row.TARHEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.TARHEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"TCRMG"})
WITH *,
  CASE row.TCRMG
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.TCRMG<> "-1" OR row.TCRMG <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.TCRMG})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"TIC"})
WITH *,
  CASE row.TIC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.TIC<> "-1" OR row.TIC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.TIC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Turksoy"})
WITH *,
  CASE row.Turksoy
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Turksoy<> "-1" OR row.Turksoy <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Turksoy})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UASC"})
WITH *,
  CASE row.UASC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UASC<> "-1" OR row.UASC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UASC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UBEC"})
WITH *,
  CASE row.UBEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UBEC<> "-1" OR row.UBEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UBEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UDEAC"})
WITH *,
  CASE row.UDEAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UDEAC<> "-1" OR row.UDEAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UDEAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UEMOA"})
WITH *,
  CASE row.UEMOA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UEMOA<> "-1" OR row.UEMOA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UEMOA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UIUCV"})
WITH *,
  CASE row.UIUCV
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UIUCV<> "-1" OR row.UIUCV <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UIUCV})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UKDWD"})
WITH *,
  CASE row.UKDWD
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UKDWD<> "-1" OR row.UKDWD <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UKDWD})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UMAC"})
WITH *,
  CASE row.UMAC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UMAC<> "-1" OR row.UMAC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UMAC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UMOA"})
WITH *,
  CASE row.UMOA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UMOA<> "-1" OR row.UMOA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UMOA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UN"})
WITH *,
  CASE row.UN
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UN<> "-1" OR row.UN <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UN})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UNDROIT"})
WITH *,
  CASE row.UNDROIT
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UNDROIT<> "-1" OR row.UNDROIT <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UNDROIT})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UNESCO"})
WITH *,
  CASE row.UNESCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UNESCO<> "-1" OR row.UNESCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UNESCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UNIDO"})
WITH *,
  CASE row.UNIDO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UNIDO<> "-1" OR row.UNIDO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UNIDO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"UPU"})
WITH *,
  CASE row.UPU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.UPU<> "-1" OR row.UPU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.UPU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"USP"})
WITH *,
  CASE row.USP
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.USP<> "-1" OR row.USP <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.USP})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"VALDIVIA"})
WITH *,
  CASE row.VALDIVIA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.VALDIVIA<> "-1" OR row.VALDIVIA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.VALDIVIA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"VASAB"})
WITH *,
  CASE row.VASAB
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.VASAB<> "-1" OR row.VASAB <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.VASAB})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WAEC"})
WITH *,
  CASE row.WAEC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WAEC<> "-1" OR row.WAEC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WAEC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WAHC"})
WITH *,
  CASE row.WAHC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WAHC<> "-1" OR row.WAHC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WAHC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WAHO"})
WITH *,
  CASE row.WAHO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WAHO<> "-1" OR row.WAHO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WAHO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WARDA"})
WITH *,
  CASE row.WARDA
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WARDA<> "-1" OR row.WARDA <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WARDA})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WCDC"})
WITH *,
  CASE row.WCDC
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WCDC<> "-1" OR row.WCDC <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WCDC})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WCO"})
WITH *,
  CASE row.WCO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WCO<> "-1" OR row.WCO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WCO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WEU"})
WITH *,
  CASE row.WEU
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WEU<> "-1" OR row.WEU <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WEU})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WHO"})
WITH *,
  CASE row.WHO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WHO<> "-1" OR row.WHO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WHO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WIPO"})
WITH *,
  CASE row.WIPO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WIPO<> "-1" OR row.WIPO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WIPO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WMO"})
WITH *,
  CASE row.WMO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WMO<> "-1" OR row.WMO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WMO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WNF"})
WITH *,
  CASE row.WNF
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WNF<> "-1" OR row.WNF <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WNF})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WPact"})
WITH *,
  CASE row.WPact
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WPact<> "-1" OR row.WPact <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WPact})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WTO"})
WITH *,
  CASE row.WTO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WTO<> "-1" OR row.WTO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WTO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"WTOURO"})
WITH *,
  CASE row.WTOURO
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.WTOURO<> "-1" OR row.WTOURO <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.WTOURO})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);

MATCH (d:Dataset{filename:"IGO_stateunit_v2.3.zip"})
LOAD CSV WITH HEADERS FROM "file:///IGO_stateunit_v2.3.csv" AS row
MATCH (s:State{cowcode:row.ccode}),(p:Year{name:row.year}),(i:IGO{name:"Wassen"})
WITH *,
  CASE row.Wassen
    WHEN "1" THEN "Full Member"
    WHEN "2" THEN "Associate Member"
    WHEN "3" THEN "Observer"
    WHEN "0" THEN "Not a Member"
    WHEN "-9" THEN "Missing Data"
    END AS membership
FOREACH (datum IN CASE WHEN row.Wassen<> "-1" OR row.Wassen <> "-9" THEN [1] ELSE [] END |
  CREATE (d)-[:CONTRIBUTES]->(f:Fact:IGOMembershipFact{name:"IGO Membership", status:membership, membershipCode:row.Wassen})-[:DURING]->(p)
  CREATE (s)-[:MEMBER]->(f)-[:MEMBER_OF]->(i)
);