#!/bin/bash

env=( development test)

for ENV in "${env[@]}"; do
  docker exec -it ticks-postgres psql -U postgres -c "create database my_api_$ENV;"
done
