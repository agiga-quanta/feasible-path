////////////////////////////////////////////////////////////////////////////////
//

// :param xlsx_file => '/import/feasible-path.xlsx';
:param xlsx_file => 'https://github.com/nghia71/feasible-path/raw/main/import/feasible-path.xlsx';

:param sheets => ['1', '2'];

UNWIND $sheets AS sheet
WITH sheet
  CALL apoc.load.xls($xlsx_file, sheet + '!A1:D2')
    YIELD map
WITH sheet, map
  MERGE (case:CASE {uid: map.identification})
    SET
      case.title = map.title,
      case.category = map.category,
      case.start_state = map.start_state
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
WITH sheet, case
  CALL apoc.load.xls($xlsx_file, sheet + '!A4:M27')
	  YIELD map
WITH sheet, case, map
  MERGE (state:STATE {uid: map.identification})
WITH sheet, case, state, map  
  CALL apoc.create.addLabels(state, [map.type]) YIELD node
WITH sheet, case, state, map
  SET
    state.title = map.title,
    state.date = DATE(map.date),
    state.event = DATE(map.event),
    state.output_items = map.output_items
  FOREACH (a IN SPLIT(map.actors, '|') | 
    MERGE (actor:ACTOR {uid: a + '-' + case.uid})
      SET
        actor.title = a
    MERGE (state)<-[:ACTS_ON]-(actor)
  )
  FOREACH (i IN SPLIT(map.input_items, '|') | 
    MERGE (item:ITEM {uid: i + '-' + case.uid})
      SET
        item.title = i
    MERGE (state)<-[:HAS_INPUT]-(item)
  )
  FOREACH (o IN SPLIT(map.output_items, '|') | 
    MERGE (item:ITEM {uid: o + '-' + case.uid})
      SET
        item.title = o
    MERGE (state)-[:HAS_OUTPUT]->(item)
  )
  FOREACH (a IN SPLIT(map.alert, '|') |
    MERGE (alert:ALERT {uid: a + '-' + case.uid})
      SET
        alert.title = a
    MERGE (state)-[:HAS_ALERT]->(alert)
  )
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
WITH sheet, case
  CALL apoc.load.xls($xlsx_file, sheet + '!A4:M27')
	  YIELD map
WITH sheet, case, map
  MERGE (start_state:STATE {uid: case.start_state})
  MERGE (case)-[r:STARTS_WITH]->(start_state)
WITH sheet, case, map
  MERGE (start_state:STATE {uid: map.identification})
  FOREACH (_ IN CASE WHEN map.route IS NOT NULL THEN [1] ELSE [] END |
    MERGE (end_state:STATE {uid: map.route})
    FOREACH(_ IN CASE map.route_completed = 'Y' WHEN TRUE THEN [1] ELSE [] END |
      MERGE (start_state)-[r:COMPLETED]->(end_state)
    )
    FOREACH(_ IN CASE map.route_completed = 'N' WHEN TRUE THEN [1] ELSE [] END |
      MERGE (start_state)-[r:PENDING]->(end_state)
    )
  )
  FOREACH (state_id IN SPLIT(map.alternate_routes, '|') | 
    MERGE (end_state:STATE {uid: state_id})
    FOREACH(_ IN CASE map.alternate_routes_completed = 'Y' WHEN TRUE THEN [1] ELSE [] END |
      MERGE (start_state)-[r:COMPLETED]->(end_state)
    )
    FOREACH(_ IN CASE map.alternate_routes_completed = 'N' WHEN TRUE THEN [1] ELSE [] END |
      MERGE (start_state)-[r:PENDING]->(end_state)
    )
  );
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Load ACTION nodes
// Call the nlp micro service to process the output items.
//
CALL apoc.periodic.iterate(
"
	MATCH (n:ACTION)
		WITH n, [
			apoc.map.fromPairs([['u', 'output_items'], ['c', CASE n.output_items IS NULL WHEN TRUE THEN '' ELSE REPLACE(n.output_items, '|', '. ') END]])
		] AS input
	RETURN n, input
", "
	WITH n, input
  	CALL custom.nlp_import(n, 'http://nlp:8000/process/', apoc.convert.toJson(input))
      YIELD result
	RETURN 1;
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
////////////////////////////////////////////////////////////////////////////////