# Each instruction in this file generates a new layer that gets pushed to your local image cache
#

#
# Lines preceeded by # are regarded as comments and ignored
#


FROM registry.access.redhat.com/ubi8/ubi
MAINTAINER Suraj@in.ibm.com 

#### LABEL
LABEL "name"="Suraj@in.ibm.com" \
      "vendor"="IBM" \
      "version"="Version of the image" \
      "release"="A number used to identify the specific build for this image" \
      "summary"="A short overview of the application or component in this image" \
      "description"="long description of the application or component in this image"

#### Disabling "SU" permision 
RUN usermod -s /sbin/nologin root
RUN echo "auth requisite  pam_deny.so" >> /etc/pam.d/su

#### Install prepare infrastructure
RUN yum -y update && \
  yum -y install wget && \
  yum -y install tar && \
  yum -y install git

#### Creating Directory
RUN mkdir opt/java
RUN mkdir opt/tomcat

#### Prepare environment
ENV JAVA_HOME /opt/java
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

#### Install Oracle Java8
ENV JAVA_VERSION 13.0.2
ENV JAVA_VM 0.18.0


WORKDIR /opt/java
RUN wget https://github.com/AdoptOpenJDK/openjdk13-binaries/releases/download/jdk-13.0.2%2B8_openj9-0.18.0/OpenJDK13U-jdk_x64_linux_openj9_13.0.2_8_openj9-0.18.0.tar.gz


#### Coping JDK tar file
##COPY ./JavaTar/jdk-13.0.2_linux-x64_bin.tar.gz /opt/java

#### Running untar Command a nd moving it to ${JAVA_HOME}
##RUN tar -xvf jdk-13.0.2_linux-x64_bin.tar.gz && \
RUN tar -xvf OpenJDK13U-jdk_x64_linux_openj9_13.0.2_8_openj9-0.18.0.tar.gz && \ 
   rm Open*.tar.gz && \
    mv jdk*/*  ${JAVA_HOME}



#### Install Tomcat
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.30
ENV SCRIPT /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}


#### Downloading Tomact Tar File
WORKDIR /opt/tomcat
RUN wget http://mirror.linux-ia64.org/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz


RUN tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz  && \
  rm apache-tomcat*.tar.gz && \
  mv apache-tomcat*/* ${CATALINA_HOME}
  
####Adding License 
RUN mkdir /licenses
ADD ./licenses.txt /licenses

RUN chmod +x ${CATALINA_HOME}/bin/*sh

# Create Tomcat admin user
ADD ./apache-tomcat-9.0.11/create_admin_user.sh $CATALINA_HOME/scripts/create_admin_user.sh
ADD ./apache-tomcat-9.0.11/tomcat.sh $CATALINA_HOME/scripts/tomcat.sh
RUN chmod +x $CATALINA_HOME/scripts/*.sh

# Create tomcat user
RUN groupadd -r tomcat && \
 useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
 chown -R tomcat:tomcat ${CATALINA_HOME}

WORKDIR /opt/tomcat

EXPOSE 8080
EXPOSE 8009

USER tomcat
CMD ["./scripts/tomcat.sh"]


        

