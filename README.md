# feasible-path
Consulting advisor on data and process modelling for Program Activity Tracking for Habitat (PATH)

## The Project

### *Background*

Fisheries and Oceans Canada (DFO) through the Fish and Fish Habitat Protection Program (FFHPP) manages physical threats to fish and fish habitat and aquatic species at risk. DFO reviews proposals for work near water to determine whether they are likely to result in the death of fish or the harmful alteration, disruption or destruction (HADD) of fish habitat. DFO also reviews projects to determine whether they will adversely impact listed species at risk and contravene sections 32, 33 or 58 of the Species at Risk Act (SARA).  All information related to project reviews is entered into the Departmental database PATH (Program Activity Tracking for Habitat).

Detailed project information either entered or uploaded into the PATH is not currently searchable using existing database search functions. Analysis of the information is required to support program work planning essential for aligning program delivery activities with Departmental priorities and work objectives.

Currently the only means to retrieve this information is to search each file activity list (consisting of 10’s to hundreds of entries) relies on experienced individual users to identify or remember linkages between relevant documents. Due the large number of applications now within PATH, the time required to do this searching and connecting is significant, resulting in a significant backlog of reviews and high potential for ambiguity and human error. Furthermore, this siloed working process makes it hard for integration of further activities, responding to system failure, and/or knowledge transfer and/or analysis.

### *Objective*

The objective is to evaluate the feasibility of automating the application of PATH domain knowledge of current working process using network science and supervised machine learning. This evaluation will be used to develop a strategy for future work that will empower decision-makers through automatic aggregation of existing data resources into a connected data graph, visual representation of decision making process, and suggesting recommendations.

Core to this exercise is establishing and characterizing case studies consisting of a concrete set of extracted information, step-by-step flow diagram depicting involved process, contextualization with domain-specific knowledge, decision making logic, and desirable outcomes. Using a set of defined case-studies, this work will classify existing authorization processes into distinct classes, describe in detail the technical process for automation, and define requirements for supervised machine learning of existing and future domain knowledge.

<details><summary>Click for details!</summary>

### *Statement of Work*

i. Understand and identify database information searching problem

1. Identify a set of 5 focused PATH searches that exemplify typical day-to-day operations and critical pain-points for their business needs.
2. Propose a method for observing and recording the step-by-step process taken to achieve these searches.
3. Propose and execute a method to track the query process.

ii. Track and characterize the process and data involved 

1. Observe and record in detail the processes and data used to execute above searches
2. Characterize the types of data and processes observed during the search 
3. Develop a conceptual process model showing how data types are linked in complete a search
4. Extract sample data objects sufficient to demonstrate the data types and processes

iii. Propose a next viable project 

Develop a proposal for a larger-scale project aimed at mining PATH data and making it operational within the scope of:
1. RR daily business needs and
2. Data extraction for potential research into cumulative effects.

iv. Support/Collaboration

This project will be supported at several levels within DFO:
1. Neil Fisher within regulatory review will provide support on defining the use-cases and walking through the PATH authorization processes that need to be automated.
2. Tom Bird (ecosystem science) will provide technical bridging between RR and the technical advisor, as well as development of scoping for next steps. 

### *Deliverables*
- Written report on the outcome of the exercise and the feasibility of a follow-on project.
- Diagram of the conceptual model developed. 

</details>

## First Case study

[Here's the full description of the case](doc/Path_Data_Mining_Case_Study.docx) and its [flowchart](doc/flowchart.png).

Below is the graph representing the case

![Here's the case transformed into a graph](img/graph.png)

### How to reproduce this on your computer

*If you have only 5 mins and don't care if you want to keep it on your own machine*

- Go to create a [neo4j sandbox](https://neo4j.com/sandbox/), click on 'Launch a Free Sandbox', agree to the terms, launch a blank sandbox, click on 'Open' green button to open a browser tab to access the sandbox.

- copy the context of this [Cypher query](cql/step_3_case_study_import.cql), paste it into the query box, click on the blue button to run it.

- then run the following to see the whole graph:

        MATCH (n) RETURN n


*If you can deal with Docker and has admin right to your own machine*

To run it on your computer (macOS or Linux)
- install Docker Desktop (Docker & Docker Compose)
- checkout the repository:

        git clone https://github.com/nghia71/feasible-path.git
        cd feasible-path

- create and run neo4j docker:

        ./run.sh

- open your browser, go to http://localhost:7474, enter with username `neo4j`, password `path`

- copy the content of this [Cypher query](cql/step_3_case_study_import.cql), paste it into the query box, click on the blue button to run it.

- then run the following to see the whole graph:

        MATCH (n) RETURN n

