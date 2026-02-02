#!/bin/bash

# Wait for configuration to be available
if [ ! -f ${HADOOP_CONF_DIR}/core-site.xml ]; then
    echo "Waiting for Hadoop configuration..."
    sleep 5
fi

# Format NameNode if it hasn't been formatted yet
if [ ! -d /hadoop/dfs/name/current ]; then
    echo "Formatting NameNode..."
    ${HADOOP_HOME}/bin/hdfs namenode -format -force -nonInteractive
fi

# Start NameNode
echo "Starting NameNode..."
${HADOOP_HOME}/bin/hdfs namenode