DOCKER_NETWORK = hadoop
ENV_FILE = hadoop.env
HADOOP_VERSION = 3.3.6
IMAGE_TAG = $(HADOOP_VERSION)

# Get current git branch (fallback to version if not in git repo)
current_branch := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$(HADOOP_VERSION)")

.PHONY: build wordcount clean test up down restart logs help

# Build all images
build:
	@echo "Building Hadoop $(HADOOP_VERSION) Docker images..."
	docker build -t hadoop-base:$(IMAGE_TAG) ./base
	docker build -t hadoop-namenode:$(IMAGE_TAG) ./namenode
	docker build -t hadoop-datanode:$(IMAGE_TAG) ./datanode
	docker build -t hadoop-resourcemanager:$(IMAGE_TAG) ./resourcemanager
	docker build -t hadoop-nodemanager:$(IMAGE_TAG) ./nodemanager
	docker build -t hadoop-historyserver:$(IMAGE_TAG) ./historyserver
	docker build -t hadoop-submit:$(IMAGE_TAG) ./submit
	@echo "Build complete!"

# Build without cache (clean build)
rebuild:
	@echo "Rebuilding all images without cache..."
	docker build --no-cache -t hadoop-base:$(IMAGE_TAG) ./base
	docker build --no-cache -t hadoop-namenode:$(IMAGE_TAG) ./namenode
	docker build --no-cache -t hadoop-datanode:$(IMAGE_TAG) ./datanode
	docker build --no-cache -t hadoop-resourcemanager:$(IMAGE_TAG) ./resourcemanager
	docker build --no-cache -t hadoop-nodemanager:$(IMAGE_TAG) ./nodemanager
	docker build --no-cache -t hadoop-historyserver:$(IMAGE_TAG) ./historyserver
	docker build --no-cache -t hadoop-submit:$(IMAGE_TAG) ./submit
	@echo "Rebuild complete!"

# Start the cluster
up:
	@echo "Starting Hadoop cluster..."
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo "Cluster started! Access web UIs at:"
	@echo "  NameNode:        http://localhost:9870"
	@echo "  ResourceManager: http://localhost:8088"
	@echo "  HistoryServer:   http://localhost:19888"
	@echo "  DataNode:        http://localhost:9864"

# Stop the cluster
down:
	@echo "Stopping Hadoop cluster..."
	docker-compose down

# Restart the cluster
restart: down up

# View logs
logs:
	docker-compose logs -f

# Run WordCount example
wordcount:
	@echo "Running WordCount example..."
	docker build -t hadoop-wordcount:$(IMAGE_TAG) ./submit
	@echo "Creating input directory in HDFS..."
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:$(IMAGE_TAG) hdfs dfs -mkdir -p /input/
	@echo "Uploading test file to HDFS..."
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:$(IMAGE_TAG) hdfs dfs -copyFromLocal -f /opt/hadoop/README.txt /input/
	@echo "Running WordCount job..."
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount:$(IMAGE_TAG)
	@echo "WordCount results:"
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:$(IMAGE_TAG) hdfs dfs -cat /output/*
	@echo "Cleaning up HDFS..."
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:$(IMAGE_TAG) hdfs dfs -rm -r /output
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:$(IMAGE_TAG) hdfs dfs -rm -r /input
	@echo "WordCount example complete!"

# Run Pi estimation example
pi:
	@echo "Running Pi estimation example..."
	@echo "Calculating Pi using Monte Carlo method..."
	docker exec -it namenode hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-$(HADOOP_VERSION).jar pi 10 100
	@echo "Pi estimation complete!"

# Test HDFS operations
test-hdfs:
	@echo "Testing HDFS operations..."
	@echo "1. Creating test directory..."
	docker exec -it namenode hdfs dfs -mkdir -p /test
	@echo "2. Listing root directory..."
	docker exec -it namenode hdfs dfs -ls /
	@echo "3. Uploading test file..."
	docker exec -it namenode hdfs dfs -put /opt/hadoop/LICENSE.txt /test/
	@echo "4. Listing test directory..."
	docker exec -it namenode hdfs dfs -ls /test
	@echo "5. Reading file content (first 10 lines)..."
	docker exec -it namenode hdfs dfs -cat /test/LICENSE.txt | head -n 10
	@echo "6. Cleaning up..."
	docker exec -it namenode hdfs dfs -rm -r /test
	@echo "HDFS test complete!"

# Test YARN
test-yarn:
	@echo "Testing YARN with WordCount..."
	docker exec -it namenode hdfs dfs -mkdir -p /user/root/input
	docker exec -it namenode hdfs dfs -put /opt/hadoop/etc/hadoop/*.xml /user/root/input
	docker exec -it namenode hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-$(HADOOP_VERSION).jar wordcount /user/root/input /user/root/output
	@echo "Job output:"
	docker exec -it namenode hdfs dfs -cat /user/root/output/part-r-00000 | head -n 20
	docker exec -it namenode hdfs dfs -rm -r /user/root/output
	docker exec -it namenode hdfs dfs -rm -r /user/root/input
	@echo "YARN test complete!"

# Check cluster status
status:
	@echo "Checking Hadoop cluster status..."
	@echo "\n=== Docker Containers ==="
	docker-compose ps
	@echo "\n=== HDFS Status ==="
	docker exec namenode hdfs dfsadmin -report | head -n 20
	@echo "\n=== YARN Nodes ==="
	docker exec resourcemanager yarn node -list
	@echo "\n=== Hadoop Version ==="
	docker exec namenode hadoop version

# Clean up volumes and images
clean:
	@echo "Cleaning up Docker volumes and images..."
	docker-compose down -v
	docker rmi -f hadoop-base:$(IMAGE_TAG) || true
	docker rmi -f hadoop-namenode:$(IMAGE_TAG) || true
	docker rmi -f hadoop-datanode:$(IMAGE_TAG) || true
	docker rmi -f hadoop-resourcemanager:$(IMAGE_TAG) || true
	docker rmi -f hadoop-nodemanager:$(IMAGE_TAG) || true
	docker rmi -f hadoop-historyserver:$(IMAGE_TAG) || true
	docker rmi -f hadoop-submit:$(IMAGE_TAG) || true
	docker rmi -f hadoop-wordcount:$(IMAGE_TAG) || true
	@echo "Cleanup complete!"

# Format NameNode (WARNING: Deletes all HDFS data!)
format-namenode:
	@echo "WARNING: This will delete all HDFS data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		docker-compose up -d; \
		echo "NameNode formatted!"; \
	else \
		echo "Cancelled."; \
	fi

# Shell access to NameNode
shell-namenode:
	docker exec -it namenode bash

# Shell access to DataNode
shell-datanode:
	docker exec -it datanode bash

# Shell access to ResourceManager
shell-resourcemanager:
	docker exec -it resourcemanager bash

# Help
help:
	@echo "Hadoop $(HADOOP_VERSION) Docker Cluster - Makefile Commands"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build              - Build all Docker images"
	@echo "  make rebuild            - Rebuild all images without cache"
	@echo ""
	@echo "Cluster Management:"
	@echo "  make up                 - Start the Hadoop cluster"
	@echo "  make down               - Stop the Hadoop cluster"
	@echo "  make restart            - Restart the cluster"
	@echo "  make status             - Check cluster status"
	@echo "  make logs               - View cluster logs"
	@echo ""
	@echo "Testing:"
	@echo "  make wordcount          - Run WordCount MapReduce example"
	@echo "  make pi                 - Run Pi estimation example"
	@echo "  make test-hdfs          - Test HDFS operations"
	@echo "  make test-yarn          - Test YARN with WordCount"
	@echo ""
	@echo "Shell Access:"
	@echo "  make shell-namenode     - Open bash shell in NameNode"
	@echo "  make shell-datanode     - Open bash shell in DataNode"
	@echo "  make shell-resourcemanager - Open bash shell in ResourceManager"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean              - Remove all volumes and images"
	@echo "  make format-namenode    - Format NameNode (deletes all data!)"
	@echo ""
	@echo "Help:"
	@echo "  make help               - Show this help message"