FROM ubuntu:22.04

LABEL maintainer="Rohan Rajbanshi <rohanrajbanshi1@gmail.com>"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including Java
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    curl \
    openssh-server \
    openssh-client \
    sudo \
    net-tools \
    netcat \
    gnupg \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

# Import Hadoop GPG keys for verification
RUN curl -O https://dist.apache.org/repos/dist/release/hadoop/common/KEYS && \
    gpg --import KEYS

# Set Hadoop version and download URL
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz

# Download, verify, and extract Hadoop
RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xzf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

# Create symbolic links and directories
RUN ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop
RUN ln -s /opt/hadoop-${HADOOP_VERSION}/etc/hadoop /etc/hadoop
RUN mkdir -p /opt/hadoop-${HADOOP_VERSION}/logs
RUN mkdir -p /hadoop-data

# Set Hadoop environment variables
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}

# Add entrypoint script
ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]