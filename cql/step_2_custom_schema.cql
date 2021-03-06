////////////////////////////////////////////////////////////////////////////////
//
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
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// NLP data: all node labels have 'NLP_' as prefix
//
////////////////////////////////////////////////////////////////////////
//
// Document
//
CREATE CONSTRAINT ON (n:DOCUMENT) ASSERT n.uid IS UNIQUE;
// - uid: the unique identifier of a document (e.g. file name)
//
// Sentence
//
CREATE CONSTRAINT ON (n:SENTENCE) ASSERT n.uid IS UNIQUE;
//
CREATE INDEX ON :SENTENCE(c);
// - c is the textual content, it is  indexed
CREATE INDEX ON :SENTENCE(s);
// - s is the sentiment score, it is an indexed integer
CREATE INDEX ON :SENTENCE(n);
// - n is the numner of occurences of the sentence
//
// Named Entity
//
CREATE CONSTRAINT ON (n:NAMED_ENTITY) ASSERT n.c IS UNIQUE;
// - c is the textual content, it is unique and indexed
CREATE CONSTRAINT ON (n:NAMED_ENTITY_CARDINAL) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_DATE) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_EVENT) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_FAC) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_GPE) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_LAW) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_LANGUAGE) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_LOC) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_MONEY) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_NORP) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_ORDINAL) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_ORG) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_PERCENT) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_PERSON) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_PRODUCT) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_QUANTITY) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_TIME) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NAMED_ENTITY_WORK_OF_ART) ASSERT n.c IS UNIQUE;
// - the entity type label (18 named entity types, e.g. PERSON)
CREATE INDEX ON :NAMED_ENTITY(n);
// - n is the number of occurences of the entity
//
// Key Phrase
//
CREATE CONSTRAINT ON (n:KEY_PHRASE) ASSERT n.c IS UNIQUE;
// - c is the textual content, it is unique and indexed
CREATE INDEX ON :KEY_PHRASE(n);
// - n is the numner of occurences of the key phrase
//
// Lemmatized word
//
CREATE CONSTRAINT ON (n:WORD) ASSERT n.l IS UNIQUE;
// - l is the lemma form of the text, it is unique and indexed
CREATE INDEX ON :WORD(n);
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// STATE definitions
//
////////////////////////////////////////////////////////////////////////////////
//
CREATE CONSTRAINT ON (n:CASE) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:STATE) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:ACTION) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:BEGIN_STATE) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:DECISION) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:END_STATE) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:INPUT) ASSERT n.uid IS UNIQUE;
CREATE CONSTRAINT ON (n:PROCESS) ASSERT n.uid IS UNIQUE; 
//
CREATE CONSTRAINT ON (n:ACTOR) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:ITEM) ASSERT n.uid IS UNIQUE; 
CREATE CONSTRAINT ON (n:ALERT) ASSERT n.uid IS UNIQUE; 
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Call the nlp micro service to process the documents.
//
CALL apoc.custom.asProcedure(
  'nlp_import',
  'WITH $n AS n
    CALL apoc.load.jsonParams($nlp_service, {method: "POST"}, $input)
      YIELD value
  WITH n, value
    UNWIND value AS document
  WITH n, document
    UNWIND document.p AS sentence

  WITH n, sentence
    UNWIND sentence.e AS entity
  WITH n, sentence, entity
    MERGE (e:NAMED_ENTITY {c: entity.c})
      ON CREATE SET e.n = 1
      ON MATCH SET e.n = e.n + 1
    MERGE (n)-[r:HAS_NAMED_ENTITY]->(e)
      ON CREATE SET r.n = 1
      ON MATCH SET r.n = r.n + 1
  WITH n, sentence, e, entity
    CALL apoc.create.addLabels(e, ["NAMED_ENTITY_" + entity.t]) YIELD node
  WITH n, sentence, node AS e, entity
    UNWIND entity.w AS word
      MERGE (w:WORD {l: word.l})
        ON CREATE SET w.n = 1
        ON MATCH SET w.n = w.n + 1
      MERGE (e)-[r:HAS_WORD]->(w)

  WITH n, sentence
    UNWIND sentence.k AS key_phrase
  WITH n, sentence, key_phrase
    MERGE (k:KEY_PHRASE {c: key_phrase.c})
      ON CREATE SET k.n = 1
      ON MATCH SET k.n = k.n + 1
    MERGE (n)-[r:HAS_KEY_PHRASE]->(k)
      ON CREATE SET r.n = 1
      ON MATCH SET r.n = r.n + 1
  WITH n, sentence, k, key_phrase
    UNWIND key_phrase.w AS word
      MERGE (w:WORD {l: word.l})
        ON CREATE SET w.n = 1
        ON MATCH SET w.n = w.n + 1
      MERGE (k)-[r:HAS_WORD]->(w)
        ON CREATE SET r.c = word.c
  RETURN n AS result;',
  'write',
  [['result','NODE']],
  [['n','NODE'], ['nlp_service','STRING'], ['input','STRING']]
);
//
CALL apoc.custom.list;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// CALL apoc.custom.list;
//
// CALL apoc.custom.removeProcedure('nlp_import');
//
////////////////////////////////////////////////////////////////////////////////
