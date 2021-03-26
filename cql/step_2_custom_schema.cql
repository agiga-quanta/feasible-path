// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
// CONSTRAINTS AND INDEXES
//
// 1. Create unique constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT n.property IS UNIQUE;
//
// 2. Create a single-property index
// CREATE INDEX ON :Label(property);
//
// 3. Create a composite index
// CREATE INDEX ON :Label(prop1, …​, propN);
//
// 4. Create node property existence constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT EXISTS(n.property);
//
// 5. Create relationship property existence constraint
// CREATE CONSTRAINT ON ()-[r:relationshipType]-() ASSERT EXISTS(r.property);
//
// 6. Create a Node Key
// ASSERT (variable.propertyName_1, …​, variable.propertyName_n) IS NODE KEY;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// NLP data: all node labels have 'NLP_' as prefix
//
////////////////////////////////////////////////////////////////////////
//
CREATE CONSTRAINT ON (n:AUTHORIZATION) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:SERIOUS_HARM) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:MITIGATING_ACTION) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:OFFSETING_ACTION) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:NOTIFY_FAILURE) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:DEADLINE) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:MONITORING_COMPLIANCE) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:SITE_VISIT) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:REVIEW_REPORT) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:NON_COMPLICANCE_ACTION) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:REQUEST_ENFORCEMENT_ACTION) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:COMMUNICATION_WITH_PROPONENT) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:REQUEST_ENFORCEMENT_REVIEW) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:MONITORING_OFFSETING) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:TERMINAL) ASSERT n.uid IS UNIQUE; 
//
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// List all constraints
CALL db.constraints();
//
// List all indexes
CALL db.indexes();
//
// Wait for all indexes online
CALL db.awaitIndexes();
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// CALL apoc.custom.list;
//
// CALL apoc.custom.removeProcedure('nlp_import');
//
////////////////////////////////////////////////////////////////////////////////
