#!/bin/bash
#
cd ~/Code/george/startup/

echo "Starting first instance..."
cd ./hazelcast1/george/
./bin/start.sh

echo "Starting second instance..."
cd ./../../hazelcast2/george/
./bin/start.sh

echo "Starting third instance..."
cd ./../../hazelcast3/george/
./bin/start.sh

echo "Starting fourth instance..."
cd ./../../hazelcast4/george/
./bin/start.sh

echo "Starting fifth instance..."
cd ./../../hazelcast5/george/
./bin/start.sh

echo "Starting final instance..."
cd ./../../hazelcast6/george/
./bin/start.sh

echo "...and that's all of them"
