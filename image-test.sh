#!/bin/bash

curl http://$(docker-machine ip default):9200/?pretty
