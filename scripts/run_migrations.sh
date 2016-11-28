#!/bin/bash

docker exec -it ticker-api bundle exec rake db:migrate
docker exec -it ticker-api bundle exec rake db:migrate RACK_ENV=test
