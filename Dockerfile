FROM oraclelinux:7.2

MAINTAINER Timothy Langford

RUN yum -y update
RUN yum -y install wget

# Install Oracle Java
RUN wget --no-cookies \
         --no-check-certificate \
         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
         "http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jre-8u65-linux-x64.rpm"
RUN yum -y localinstall jre-8u65-linux-x64.rpm
RUN rm -f jre-8u65-linux-x64.rpm
ENV JAVA_HOME=/usr/java/jre1.8.0_65

# Install Elasticsearch
COPY build/elastic.repo /etc/yum.repos.d/elastic.repo
RUN rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
RUN yum -y install elasticsearch

# Create Elasticsearch config
ENV ELASTICSEARCH_HOME=/usr/share/elasticsearch/
COPY elasticsearch/config/ /usr/share/elasticsearch/config
ENV CLUSTER_NAME=elasticsearch_cluster
ENV HTTP_ENABLE=true
ENV NODE_MASTER=true
ENV NODE_DATA=true
ENV MULTICAST=true

# Configure an elasticsearch user
RUN adduser -D -g elasticsearch

# Mount Elasticsearch '/data' volume
RUN mkdir /data
RUN chown -R elasticsearch /data /usr/share/elasticsearch/
VOLUME ["/data"]

# Mount Elastic certs
# VOLUME ["/usr/share/elasticsearch/config/certs"]

EXPOSE 9200 9300

# Run Elasticsearch as user 'elasticsearch'
# RUN ulimit -l unlimited
USER elasticsearch
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
