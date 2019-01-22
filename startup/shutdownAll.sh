#!/bin/bash
#
cd ~/Code/george/startup/

echo "Stopping first of six instances..."
cd ./hazelcast1/george/
./bin/stop.sh

echo "Stopping second instance..."
cd ./../../hazelcast2/george/
./bin/stop.sh

echo "Stopping third instance..."
cd ./../../hazelcast3/george/
./bin/stop.sh

echo "Stopping fourth instance..."
cd ./../../hazelcast4/george/
./bin/stop.sh

echo "Stopping fifth instance..."
cd ./../../hazelcast5/george/
./bin/stop.sh

echo "Stopping the final instance..."
cd ./../../hazelcast6/george/
./bin/stop.sh


