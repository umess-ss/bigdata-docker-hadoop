FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    openssh-server \
    sudo \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Hadoop 3.3.6
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Set environment variables
ENV PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}
ENV HDFS_CONF_dfs_namenode_name_dir=file:///hadoop/dfs/name

# Create directories and set permissions
RUN mkdir -p /hadoop/dfs/name && \
    chmod -R 755 ${HADOOP_HOME}

# (Optional) Copy your custom config files here
# COPY core-site.xml hdfs-site.xml yarn-site.xml ${HADOOP_HOME}/etc/hadoop/

# Healthcheck (same as original)
HEALTHCHECK CMD curl -f http://localhost:9870/ || exit 1

# Expose ports
EXPOSE 9870 9000

VOLUME /hadoop/dfs/name

# Command to run NameNode (adjust if using a run.sh script)
CMD ["hdfs", "namenode"]