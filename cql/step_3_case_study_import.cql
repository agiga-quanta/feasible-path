////////////////////////////////////////////////////////////////////////////////
//
// Authorization
//
MERGE (authorization:AUTHORIZATION {uid: 'CASE-12345'})
  SET 
    authorization.title = 'Parks Canada, Trent Severn Waterway, Dam at Lock 23 Replacement'
WITH authorization
  MERGE (harm_1:SERIOUS_HARM {uid: 'SH-1-CASE-12345'})
    SET
      harm_1.title = 'Serious Harm associated with phase 1 cofferdam footprint and dewatering',
      harm_1.affected_area = '2417 m2', 
      harm_1.start_date = 'November 1, 2018',
      harm_1.end_date = 'July 15, 2019'
  MERGE (authorization)-[:HAS_SERIOUS_HARM]->(harm_1)
  MERGE (harm_2:SERIOUS_HARM {uid: 'SH-2-CASE-12345'})
    SET
      harm_2.title = 'Serious Harm associated with phase 2 cofferdam footprint and dewatering',
      harm_2.affected_area = '1867 m2', 
      harm_2.start_date = 'July 15, 2019',
      harm_2.end_date = 'July 15, 2020'
  MERGE (authorization)-[:HAS_SERIOUS_HARM]->(harm_2)
WITH authorization
  MERGE (mitigation_action:MITIGATING_ACTION {uid: 'MGA-1-CASE-12345'})
    SET 
      mitigation_action.title = 'Fourteen conditions relating to avoiding and mitigating serious harm'
  MERGE (offseting_action:OFFSETING_ACTION {uid: 'OFA-1-CASE-12345'})
    SET 
      offseting_action.title = 'Six contingency measures'
  MERGE (authorization)-[:HAS_MITIGATING_ACTION]->(mitigation_action)
  MERGE (authorization)-[:HAS_OFFSETING_ACTION]->(offseting_action)
WITH authorization
  MERGE (deadline:DEADLINE {uid: 'DL-1-CASE-12345'})
    SET
      deadline.date = 'March 15, 2021'
  MERGE (authorization)-[:HAS_DEADLINE]->(deadline)
WITH authorization
  MERGE (notify_failure:NOTIFY_FAILURE {uid: 'NF-1-CASE-12345'})
    SET
      notify_failure.title = 'Inform DFO'
  MERGE (authorization)-[:NOTIFY_IF_FAIL]->(notify_failure)
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Monitoring compliance
//
WITH authorization

  MERGE (monitoring_compliance:MONITORING_COMPLIANCE {uid: 'MNC-1-CASE-12345'})
    SET
      monitoring_compliance.title = 'Monitoring and Report for Avoidance and Mitigation'
  MERGE (authorization)-[:HAS_MONITORING_COMPLIANCE]->(monitoring_compliance)

  MERGE (site_visit:SITE_VISIT {uid: 'SV-1-CASE-12345-MNC'})
    SET
      site_visit.title = 'Makes site visit'
  MERGE (monitoring_compliance)-[:VISITS_SITE]->(site_visit)

  MERGE (review_compliance_report:REVIEW_REPORT {uid: 'RRP-1-CASE-12345'})
    SET
      review_compliance_report.title = 'Compliance report review'
  MERGE (monitoring_compliance)-[:REVIEW_COMPLICANCE_REPORT]->(review_compliance_report)

  MERGE (non_compliance_action:NON_COMPLICANCE_ACTION {uid: 'NCA-1CASE-12345'})
    SET
      non_compliance_action.title = 'Takes non-compliance action'
  MERGE (review_compliance_report)-[:TAKES_NON_COMPLICANCE_ACTION]->(non_compliance_action)

  MERGE (request_enforcement_action:REQUEST_ENFORCEMENT_ACTION {uid: 'REA-1-CASE-12345'})
    SET
      request_enforcement_action.title = 'Requests enforcement action'
  MERGE (communication_with_proponent:COMMUNICATION_WITH_PROPONENT {uid: 'CWP-1-CASE-12345'})
    SET
      communication_with_proponent.title = 'Communicates with proponent'
  MERGE (non_compliance_action)-[:REQUESTS_ENFORCEMENT_ACTION]->(request_enforcement_action)
  MERGE (non_compliance_action)-[:COMMUNICATES_WITH_PROPONENT]->(communication_with_proponent)

  MERGE (enforcement_review:REQUEST_ENFORCEMENT_REVIEW {uid: 'RER-1-CASE-12345'})
    SET
      enforcement_review.title = 'Enforcement review'
  MERGE (request_enforcement_action)-[:REQUESTS_ENFORCEMENT_REVIEW]->(enforcement_review)
  MERGE (enforcement_review)-[:ENFORCEMENT_REVIEW_COMPLEST]->(review_compliance_report)
  MERGE (communication_with_proponent)-[:COMMUNICATED_WITH_PROPONENT]->(review_compliance_report)

  MERGE (complete_compliance_monitoring:MONITORING_COMPLIANCE {uid: 'CMC-1-CASE-12345'})
   SET
      complete_compliance_monitoring.title = 'Compliance monitoring completed'
  MERGE (review_compliance_report)-[:COMPLIANCE_REPORT_REVIEWED]->(complete_compliance_monitoring)

  MERGE (case_complete:TERMINAL {uid: 'CC-1-CASE-12345'})
    ON CREATE SET
      case_complete.title = 'CASE-12345 closed'
  MERGE (complete_compliance_monitoring)-[:COMPLICANCE_COMPLETES]->(case_complete)
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Monitoring effectiveness
//
WITH authorization

  MERGE (monitoring_offseting:MONITORING_OFFSETING {uid: 'MNO-1-CASE-12345'})
    SET
      monitoring_offseting.title = 'Monitoring and Report for Offseting'
  MERGE (authorization)-[:HAS_MONITORING_OFFSETING]->(monitoring_offseting)

  MERGE (review_offseting_report:REVIEW_REPORT {uid: 'RRP-2-CASE-12345'})
    SET 
      review_offseting_report.title = 'Offseting report review'

  FOREACH (report IN [['December 31, 2018', '1', 'Interim report 1'], ['December 31, 2019', '2', 'Interim report 2'], ['December 31, 2020', '3', 'Final report']] | 
      MERGE (deadline:DEADLINE {uid: 'DL-MNO-R-' + report[1] + 'CASE-12345'})
        SET
          deadline.date = report[0],
          deadline.title = report[2]
      MERGE (monitoring_offseting)-[:HAS_DEADLINE]->(deadline)
      MERGE (deadline)-[:REVIEW_OFFSETING_REPORT]->(review_offseting_report)
  )

  MERGE (complete_offseting_monitoring:MONITORING_OFFSETING {uid: 'CMO-1-CASE-12345'})
   SET
      complete_offseting_monitoring.title = 'Compliance monitoring completed'
  MERGE (review_offseting_report)-[:COMPLIANCE_REPORT_REVIEWED]->(complete_offseting_monitoring)

  MERGE (case_complete:TERMINAL {uid: 'CC-1-CASE-12345'})
  MERGE (complete_offseting_monitoring)-[:OFFSETING_COMPLETES]->(case_complete);
//
////////////////////////////////////////////////////////////////////////////////

