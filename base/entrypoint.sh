#!/bin/bash

# Set JAVA_HOME in Hadoop env
echo "export JAVA_HOME=${JAVA_HOME}" >> ${HADOOP_CONF_DIR}/hadoop-env.sh

# Execute the command passed to the container
exec "$@"