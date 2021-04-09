

Install

Step 1) download dependencies & put in resources/downloads/
	- http://archive.apache.org/dist/flume/1.9.0/apache-flume-1.9.0-bin.tar.gz
	- http://archive.apache.org/dist/kafka/2.4.0/kafka_2.12-2.4.0.tgz
	- http://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
	- https://jdbc.postgresql.org/download/postgresql-42.2.9.jar
	- https://repo1.maven.org/maven2/commons-lang/commons-lang/2.6/commons-lang-2.6.jar
	- https://archive.apache.org/dist/hadoop/core/hadoop-3.2.0/hadoop-3.2.0.tar.gz
	- https://archive.apache.org/dist/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz
	- http://archive.apache.org/dist/nifi/1.10.0/nifi-1.10.0-bin.tar.gz
	- https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.tgz
	- https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-without-hadoop.tgz

Step 2) build images
	$ ./build.sh

Step 3A) generate containers, first time only
	$ ./cluster.sh install

Step 3B) start existing containers, 2+ time
	$ ./cluster.sh start

Actions

Visit NiFi
	web-browser: localhost:8080/nifi

"SSH" into NiFi server
	$ docker exec -it nifi /bin/bash

"SSH" into edge node
	$ docker exec -it edge /bin/bash

HDFS
	Run HDFS commands (from edge node)
		- ssh into edge node
		- run as normal

	Run HDFS commands (from host)
		$ docker exec -t edge hdfs dfs -ls /user

HIVE
	Run hive commands (from node)
		- ssh into edge node
		$ beeline -u jdbc:hive2://nodemaster:10000

	Open hive (from host)
		$ docker exec -it edge beeline -u jdbc:hive2://nodemaster:10000

KAFKA
	Add topic
		$ docker exec -t edge /home/hadoop/kafka/bin/kafka-topics.sh \
		--create \
	  --zookeeper edge:2181 \
	  --replication-factor 1 \
	  --partitions 1 \
	  --topic my-topic

	List topics
		$ docker exec -t edge /home/hadoop/kafka/bin/kafka-topics.sh \
		--list \
	  --zookeeper edge:2181

	Open terminal consumer (ctrl+c to exit)
		$ docker exec -it edge /home/hadoop/kafka/bin/kafka-console-consumer.sh \
		--bootstrap-server edge:9092 \
	  --topic my-topic \
	  --from-beginning

	Open terminal producer (ctrl+c to exit)
		$ docker exec -it edge /home/hadoop/kafka/bin/kafka-console-producer.sh \
		--broker-list edge:9092 \
	  --topic my-topic 







