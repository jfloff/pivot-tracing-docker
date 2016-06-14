FROM java:7

MAINTAINER João loff <jfloff@gsd.inesc-id.com>

# install needed packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      maven \
      aspectj \
      ant \
  && rm -rf /var/lib/apt/lists/*

# install protofbuf 2.5.0
RUN mkdir /home/protobuf && cd /home/protobuf \
  && curl -# -O https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz \
  && gunzip protobuf-2.5.0.tar.gz \
  && tar -xvf protobuf-2.5.0.tar \
  && cd protobuf-2.5.0 \
  && ./configure --prefix=/usr \
  && make && make install \
  && rm -rf /home/protobuf

#set environment variables
ENV HADOOP_OPTS '-XX:+StartAttachListener'
ENV HADOOP_HOME /home/pt/hadoop/hadoop-dist/target/hadoop-2.7.2
ENV HADOOP_CONF_DIR /home/pt/hadoop-config/

# copy to WD
ADD build.sh /home/
ADD start-hdfs.sh /home/

# startup command
CMD sh /home/build.sh
