FROM hadoop-base:3.3.6

LABEL maintainer="Rohan Rajbanshi <rohanrajbanshi1@gmail.com>"

HEALTHCHECK CMD curl -f http://localhost:9870/ || exit 1

# Set NameNode specific environment variables
ENV HDFS_CONF_dfs_namenode_name_dir=file:///hadoop/dfs/name

# Create NameNode data directory
RUN mkdir -p /hadoop/dfs/name

# Volume for persistent storage
VOLUME /hadoop/dfs/name

# Add NameNode startup script
ADD run.sh /run.sh
RUN chmod a+x /run.sh

# Expose NameNode ports
EXPOSE 9870 9000 8020

CMD ["/run.sh"]