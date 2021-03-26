#!/bin/bash

# generate ssh key
echo "Y" | ssh-keygen -t rsa -P "" -f configs/id_rsa

# Hadoop build
docker build -f ./hadoop/Dockerfile . -t dwin/hadoop_cluster:hadoop

# Spark
docker build -f ./spark/Dockerfile . -t dwin/hadoop_cluster:spark

# PostgreSQL Hive Metastore Server
docker build -f ./postgresql-hms/Dockerfile . -t dwin/hadoop_cluster:postgresql-hms

# Hive
docker build -f ./hive/Dockerfile . -t dwin/hadoop_cluster:hive

# Nifi
docker build -f ./nifi/Dockerfile . -t dwin/hadoop_cluster:nifi

# Edge
docker build -f ./edge/Dockerfile . -t dwin/hadoop_cluster:edge