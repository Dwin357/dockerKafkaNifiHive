FROM ubuntu

USER root

# open port 22
EXPOSE 22

RUN apt-get update

# OpenJDK installation
RUN apt-get install -y openjdk-8-jre openjdk-8-jdk openssh-server vim

# add hadoop user
RUN useradd -m -s /bin/bash hadoop

# set pubkey authentication
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/ssh_config
RUN mkdir -p /home/hadoop/.ssh
RUN echo "PubkeyAcceptedKeyTypes +ssh-dss" >> /home/hadoop/.ssh/config
RUN echo "PasswordAuthentication no" >> /home/hadoop/.ssh/config

# copy keys
ADD configs/id_rsa.pub /home/hadoop/.ssh/id_rsa.pub
ADD configs/id_rsa /home/hadoop/.ssh/id_rsa
RUN chmod 400 /home/hadoop/.ssh/id_rsa
RUN chmod 400 /home/hadoop/.ssh/id_rsa.pub
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
RUN chown hadoop -R /home/hadoop/.ssh

# get nifi sources
#RUN wget http://archive.apache.org/dist/nifi/1.10.0/nifi-1.10.0-bin.tar.gz -P /home/hadoop/
#RUN tar -xzf /home/hadoop/nifi-1.10.0-bin.tar.gz -C /home/hadoop/
#ADD resources/downloads/nifi-1.10.0-bin.tar.gz /home/hadoop/
#RUN mv /home/hadoop/nifi-1.10.0 /home/hadoop/nifi
#RUN rm -rf /home/hadoop/nifi-1.10.0*

ADD resources/downloads/nifi-1.10.0-bin.tar.gz /home/hadoop/
RUN mv /home/hadoop/nifi-1.10.0 /home/hadoop/nifi

# set nifi-env.sh
RUN echo -e "\n" >> /home/hadoop/nifi/bin/nifi-env.sh
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/hadoop/nifi/bin/nifi-env.sh
RUN echo "export TOOLS_JAR=${JAVA_HOME}/lib/tools.jar" >> /home/hadoop/nifi/bin/nifi-env.sh

ADD configs/nifi.properties /home/hadoop/nifi/conf/nifi.properties
RUN chown hadoop -R /home/hadoop/nifi

RUN mkdir /home/hadoop/hdfs
ADD configs/core-site.xml /home/hadoop/hdfs/core-site.xml
ADD configs/hdfs-site.xml /home/hadoop/hdfs/hdfs-site.xml
RUN chown hadoop -R /home/hadoop/hdfs

CMD service ssh start && bash
