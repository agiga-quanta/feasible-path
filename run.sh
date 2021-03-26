#!/bin/bash

./prepare.sh
docker-compose pull nlp neo4j
docker-compose up --no-build
docker-compose down
