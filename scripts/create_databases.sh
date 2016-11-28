#!/bin/bash

env=( development test)

for ENV in "${env[@]}"; do
  docker exec -it ticker-postgres psql -U postgres -c "create database my_api_$ENV;"
done
