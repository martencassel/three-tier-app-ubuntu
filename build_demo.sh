#!/bin/sh

#
# Build
#
sudo docker-compose build --no-cache

#
# Scan
#
sudo twistcli images scan three-tier-app-ubuntu-frontend:latest \
    --address https://localhost:8083 --details

echo "twistcli returned exit code: $?"

sudo twistcli images scan three-tier-app-ubuntu-database:latest \
    --address https://localhost:8083  --details

echo "twistcli returned exit code: $?"

sudo twistcli images scan three-tier-app-ubuntu-worker:latest \
    --address https://localhost:8083  --details

echo "twistcli returned exit code: $?"


#
# Ship to registry
#
docker login -u martendocker

export REPOSITORY=martendocker

docker tag three-tier-app-ubuntu-frontend:latest $REPOSITORY/three-tier-app-ubuntu-frontend:latest
docker tag three-tier-app-ubuntu-database:latest $REPOSITORY/three-tier-app-ubuntu-database:latest
docker tag three-tier-app-ubuntu-worker:latest $REPOSITORY/three-tier-app-ubuntu-worker:latest

docker image push $REPOSITORY/three-tier-app-ubuntu-frontend:latest
docker image push $REPOSITORY/three-tier-app-ubuntu-database:latest
docker image push $REPOSITORY/three-tier-app-ubuntu-worker:latest

#
# Run
#
ssh marten@localhost -p 2223 'cd three-tier-app-ubuntu/run && docker-compose down'

ssh marten@localhost -p 2223 'cd three-tier-app-ubuntu/run && docker-compose pull && docker-compose up'

