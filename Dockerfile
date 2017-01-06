FROM univizor/spark-base

MAINTAINER Jozko Skrablin <jozko@zomg.si>

RUN adduser --uid 3001 --disabled-password --gecos 'Apache Spark' spark

ENV SPARK_VERSION=2.1.0 \
  HADOOP_VERSION=2.7

RUN cd /home/spark && wget http://www.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
  tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
  ln -s spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark && \
  chown spark: -R /home/spark && \
  rm -f spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 -O /usr/local/bin/dumb-init && \
  chmod +x /usr/local/bin/dumb-init

RUN mkdir -p /srv/data && chown spark: /srv/data

ADD ./sbin/runspark.sh /usr/local/bin/runspark.sh
RUN chmod +x /usr/local/bin/runspark.sh

USER spark

WORKDIR /srv/data
VOLUME /srv/data

EXPOSE 8080 8081 7077 6066 4040 18080

ENV PATH=$PATH:/home/spark/spark/bin:/home/spark/spark/sbin \
  SPARK_HOME=/home/spark/spark \
  SPARK_NO_DAEMONIZE=1 \
  SPARK_LOCAL_DIRS=/srv/data \
  SPARK_LOG_DIR=/srv/data/spark-logs \
  SPARK_WORKER_DIR=/srv/data

ENTRYPOINT ["runspark.sh"]
