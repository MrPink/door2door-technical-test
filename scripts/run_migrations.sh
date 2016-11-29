#!/bin/bash

docker exec -it ticks-api bundle exec rake db:migrate
docker exec -it ticks-api bundle exec rake db:migrate RACK_ENV=test
