FROM oraclelinux:9

# Update and upgrade packages
RUN dnf makecache && dnf upgrade -y

# Install basic packages 
RUN dnf install --disableplugin=subscription-manager --setopt=install_weak_deps=0 --setopt=tsflags=nodocs -y \
    ca-certificates \
    curl \
    jq \
    unzip \
    wget \
    && dnf clean --disableplugin=subscription-manager all 

# Install java jdk 11 using dnf package  manager
RUN dnf install java-11

# jenkins arguments
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG JENKINS_VERSION=2.440.2
ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -N -d "$JENKINS_HOME" -u ${uid} -g ${gid} -l -m -s /bin/bash ${user}

# Ensuring path is there
# Create the destination directory if it does not exist
RUN mkdir -p /usr/share/jenkins
# Download jenkins 
RUN curl -fsSL https://get.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war -o /usr/share/jenkins/jenkins.war \
&& chown -R ${user} "$JENKINS_HOME" 

# Update and upgrade packages
RUN dnf makecache && dnf upgrade -y

# for main web interface:
EXPOSE ${http_port}

# will be used by attached agents:
EXPOSE ${agent_port}

USER ${user}

ENTRYPOINT [ "java", "-jar", "/usr/share/jenkins/jenkins.war" ]