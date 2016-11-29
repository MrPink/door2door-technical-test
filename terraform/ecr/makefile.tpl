TAG?=latest

all: build tag push

build:
  docker build -t ticks .

tag:
  docker tag ticks ${ecr_url}/ticks:$(TAG)

push:
  docker push ${ecr_url}/ticks:$(TAG)
