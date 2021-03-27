////////////////////////////////////////////////////////////////////////////////
//
CALL apoc.load.xls('/feasible-path.xlsx', '1!A1:D2')
	YIELD map
WITH map
  MERGE (case:CASE {uid: map.identification})
    SET
      case.title = map.title,
      case.category = map.category,
      case.start_state = map.start_state
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
WITH case
  CALL apoc.load.xls('/feasible-path.xlsx', '1!A4:L17')
	  YIELD map
WITH case, map
  MERGE (state:STATE {uid: map.identification})
WITH case, state, map  
  CALL apoc.create.addLabels(state, [map.type]) YIELD node
WITH case, state, map
  SET
    state.title = map.title,
    state.date = DATE(map.date),
    state.event = DATE(map.event)
  FOREACH (a IN SPLIT(map.actors, '|') | 
    MERGE (actor:ACTOR {uid: a + '-' + case.uid})
      SET
        actor.title = a
    MERGE (state)-[:HAS_ACTOR]->(actor)
  )
  FOREACH (i IN SPLIT(map.input_items, '|') | 
    MERGE (item:ITEM {uid: i + '-' + case.uid})
      SET
        item.title = i
    MERGE (state)-[:HAS_INPUT]->(item)
  )
  FOREACH (o IN SPLIT(map.output_items, '|') | 
    MERGE (item:ITEM {uid: o + '-' + case.uid})
      SET
        item.title = o
    MERGE (state)-[:HAS_OUTPUT]->(item)
  )
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
WITH case
  CALL apoc.load.xls('/feasible-path.xlsx', '1!A4:L17')
	  YIELD map
WITH case, map
  MERGE (start_state:STATE {uid: case.start_state})
  MERGE (case)-[r:STARTS_WITH]->(start_state)
WITH case, map
  MERGE (start_state:STATE {uid: map.identification})
  FOREACH (_ IN CASE WHEN map.route IS NOT NULL THEN [1] ELSE [] END |
    MERGE (end_state:STATE {uid: map.route})
    MERGE (start_state)-[r:NEXT]->(end_state)
      SET
        r.enabled = CASE map.route_completed = 'Y' WHEN TRUE THEN TRUE ELSE FALSE END
  )
  FOREACH (state_id IN SPLIT(map.alternate_routes, '|') | 
    MERGE (end_state:STATE {uid: state_id})
    MERGE (start_state)-[r:NEXT]->(end_state)
      SET
        r.enabled = CASE map.alternate_routes_completed = 'Y' WHEN TRUE THEN TRUE ELSE FALSE END
  );
//
////////////////////////////////////////////////////////////////////////////////
