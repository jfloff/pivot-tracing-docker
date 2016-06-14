#!/bin/sh

# run services
printf "[INFO] Starting namenode and datanode "
${HADOOP_HOME}/bin/hdfs --config $HADOOP_CONF_DIR namenode -format
${HADOOP_HOME}/sbin/hadoop-daemon.sh start namenode
${HADOOP_HOME}/sbin/hadoop-daemon.sh start datanode
