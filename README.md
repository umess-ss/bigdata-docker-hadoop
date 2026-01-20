# Hadoop 3.3.6 Multi-Node Cluster on Docker

A production-ready, containerized Hadoop 3.3.6 cluster setup using Docker Compose. This project provides a complete ecosystem including HDFS, YARN, and a MapReduce History Server, optimized for modern development environments.

## 🚀 Architecture
This setup deploys the following components:
* **NameNode**: The master node for HDFS.
* **DataNode**: The slave node for storage.
* **ResourceManager**: The master for YARN job scheduling.
* **NodeManager**: The slave for executing tasks.
* **HistoryServer**: Tracks completed MapReduce jobs.



---

## 🛠️ Prerequisites
* **Docker Desktop** (Windows/Mac/Linux)
* **Docker Compose**
* Minimum **4GB RAM** allocated to Docker.

---

## 📂 Project Structure
```text
.
├── config/              # Hadoop XML configuration files
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   ├── mapred-site.xml
│   └── yarn-site.xml
├── docker-compose.yml   # Docker service definitions
└── README.md            # Project documentation
```


## 1. Clone the repo
```bash
git clone <your-repo-link>
cd docker-hadoop
```

## 2. Start the Cluster
```bash
docker compose up -d
```

## 🌐 Web Interfaces
Once the cluster is running, you can access the following dashboards in your browser:
* **HDFS NameNode** -> http://localhost:9870
* **YARN ResourceManager** -> http://localhost:8088
* **MapReduce History** -> http://localhost:19888
* **DataNode Stats** -> http://localhost:9864

## Basic Usage Example
1. The HDFS "Hello World" (File Operations)
```bash
# 1. Create a user directory in HDFS
docker exec -it namenode hdfs dfs -mkdir -p /user/root/testdata

# 2. Upload a file from the container to HDFS
docker exec -it namenode hdfs dfs -put /etc/protocols /user/root/testdata

# 3. List the file to verify upload
docker exec -it namenode hdfs dfs -ls /user/root/testdata

# 4. Read the first few lines of the file from HDFS
docker exec -it namenode hdfs dfs -cat /user/root/testdata/protocols | head -n 10
```
2. Run a MapReduce Job (WordCount)
This is the standard test to ensure YARN (ResourceManager and NodeManager) can schedule and execute tasks.
```bash 
# Run the built-in WordCount example on the file we just uploaded
docker exec -it namenode hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount /user/root/testdata/protocols /user/root/output

# View the results
docker exec -it namenode hdfs dfs -cat /user/root/output/part-r-00000 | head -n 20
```
3. Testing the HistoryServer
After running the job above, users should verify that the HistoryServer is tracking the task.

Action: Open http://localhost:19888 in your browser.

What to look for: You should see a record of the wordcount job you just ran, showing its completion status and logs.

4. Estimating Pi (CPU Intensive Test)
This is a fun way to test the cluster's processing power using a Quasi-Monte Carlo method.
```bash
# Calculate Pi using 10 maps and 100 samples per map
docker exec -it namenode hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 10 100
```