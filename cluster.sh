#!/bin/bash

# Bring the services up
function startServices {
  docker start nodemaster node2 node3
  sleep 5
  echo ">> Starting hdfs ..."
  docker exec -u hadoop -it nodemaster start-dfs.sh
  sleep 5
  echo ">> Starting yarn ..."
  docker exec -u hadoop -d nodemaster start-yarn.sh
  sleep 5
  echo ">> Starting MR-JobHistory Server ..."
  docker exec -u hadoop -d nodemaster mr-jobhistory-daemon.sh start historyserver
  sleep 5
  echo ">> Starting Spark ..."
  docker exec -u hadoop -d nodemaster start-master.sh
  docker exec -u hadoop -d node2 start-slave.sh nodemaster:7077
  docker exec -u hadoop -d node3 start-slave.sh nodemaster:7077
  sleep 5
  echo ">> Starting Spark History Server ..."
  docker exec -u hadoop nodemaster start-history-server.sh
  sleep 5
  echo ">> Preparing hdfs for hive ..."
  docker exec -u hadoop -it nodemaster hdfs dfs -mkdir -p /tmp
  docker exec -u hadoop -it nodemaster hdfs dfs -mkdir -p /user/hive/warehouse
  docker exec -u hadoop -it nodemaster hdfs dfs -chmod g+w /tmp
  docker exec -u hadoop -it nodemaster hdfs dfs -chmod g+w /user/hive/warehouse
  sleep 5
  echo ">> Starting Hive Metastore ..."
  docker exec -u hadoop -d nodemaster hive --service metastore
  docker exec -u hadoop -d nodemaster hive --service hiveserver2
  echo ">> Starting Nifi Server ..."
  docker exec -u hadoop -d nifi /home/hadoop/nifi/bin/nifi.sh start
  echo ">> Starting kafka & Zookeeper ..."
  docker exec -u hadoop -d edge /home/hadoop/kafka/bin/zookeeper-server-start.sh -daemon  /home/hadoop/kafka/config/zookeeper.properties
  docker exec -u hadoop -d edge /home/hadoop/kafka/bin/kafka-server-start.sh -daemon  /home/hadoop/kafka/config/server.properties
  echo "Hadoop info @ nodemaster: http://172.20.1.1:8088/cluster"
  echo "DFS Health @ nodemaster : http://172.20.1.1:50070/dfshealth"
  echo "MR-JobHistory Server @ nodemaster : http://172.20.1.1:19888"
  echo "Spark info @ nodemaster  : http://172.20.1.1:8080"
  echo "Spark History Server @ nodemaster : http://172.20.1.1:18080"
  echo "Zookeeper @ edge : http://172.20.1.5:2181"
  echo "Kafka @ edge : http://172.20.1.5:9092"
  echo "Nifi @ edge : http://172.20.1.5:8080/nifi & from host @ http://localhost:8080/nifi"
}

function stopServices {
  echo ">> Stopping Spark Master and slaves ..."
  docker exec -u hadoop -d nodemaster stop-master.sh
  docker exec -u hadoop -d node2 stop-slave.sh
  docker exec -u hadoop -d node3 stop-slave.sh
  docker exec -u hadoop -d nifi /home/hadoop/nifi/bin/nifi.sh stop
  echo ">> Stopping containers ..."
  docker stop nodemaster node2 node3 edge nifi psqlhms
}

if [[ $1 = "install" ]]; then
  docker network create --subnet=172.20.0.0/16 hadoopnet # create custom network

  # Starting Postresql Hive metastore
  echo ">> Starting postgresql hive metastore ..."
  docker run -d --net hadoopnet --ip 172.20.1.4 --hostname psqlhms --name psqlhms -e POSTGRES_PASSWORD=hive -it dwin/hadoop_cluster:postgresql-hms
  sleep 5
  
  # 3 nodes
  echo ">> Starting master and worker nodes ..."
  docker run -d --net hadoopnet --ip 172.20.1.1 -p 8088:8088 --hostname nodemaster --add-host node2:172.20.1.2 --add-host node3:172.20.1.3 --name nodemaster -it dwin/hadoop_cluster:hive
  docker run -d --net hadoopnet --ip 172.20.1.2 --hostname node2 --add-host nodemaster:172.20.1.1 --add-host node3:172.20.1.3 --name node2 -it dwin/hadoop_cluster:spark
  docker run -d --net hadoopnet --ip 172.20.1.3 --hostname node3 --add-host nodemaster:172.20.1.1 --add-host node2:172.20.1.2 --name node3 -it dwin/hadoop_cluster:spark
  docker run -d --net hadoopnet --ip 172.20.1.5 --hostname edge --add-host nodemaster:172.20.1.1 --add-host node2:172.20.1.2 --add-host node3:172.20.1.3 --add-host psqlhms:172.20.1.4 --name edge -it dwin/hadoop_cluster:edge 
  docker run -d --net hadoopnet --ip 172.20.1.6 -p 8080:8080 --hostname nifi --add-host nodemaster:172.20.1.1 --add-host node2:172.20.1.2 --add-host node3:172.20.1.3 --add-host psqlhms:172.20.1.4 --name nifi -it dwin/hadoop_cluster:nifi 

  # Format nodemaster
  echo ">> Formatting hdfs ..."
  docker exec -u hadoop -it nodemaster hdfs namenode -format
  startServices
  exit
fi


if [[ $1 = "stop" ]]; then
  stopServices
  exit
fi


if [[ $1 = "uninstall" ]]; then
  stopServices
  docker rmi dwin/hadoop_cluster:hadoop dwin/hadoop_cluster:spark dwin/hadoop_cluster:hive dwin/hadoop_cluster:edge dwin/hadoop_cluster:postgresql-hms dwin/hadoop_cluster:nifi -f
  docker network rm hadoopnet
  docker system prune -f
  exit
fi

if [[ $1 = "start" ]]; then  
  docker start psqlhms nodemaster node2 node3 edge nifi
  startServices
  exit
fi

if [[ $1 = "pull_images" ]]; then  
  docker pull -a dwin/hadoop_cluster
  exit
fi

echo "Usage: cluster.sh pull_images|install|start|stop|uninstall"
echo "                 pull_images - download all docker images"
echo "                 install - Prepare to run and start for first time all containers"
echo "                 start  - start existing containers"
echo "                 stop   - stop running processes"
echo "                 uninstall - remove all docker images"
