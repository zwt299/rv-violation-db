FROM ubuntu:18.04
ARG VIO_ID
ARG REPO_ID
ARG SPEC_NAME

RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
# Install Git
  apt-get install -y git && \
# Install python
  apt-get update && \
  apt-get install -y python python-dev python-pip python-virtualenv && \
  rm -rf /var/lib/apt/lists/* && \
# Install misc
  apt-get update && \
  apt-get install -y sudo && \
  apt-get install -y vim && \
  apt-get install -y emacs && \  
  apt-get install -y wget && \
  apt-get install -y bc && \
  apt-get install -y maven && \
  apt-get install -y zip unzip && \
# Install OpenJDK 8
  apt-get install -y openjdk-8-jdk && \
  mv /usr/lib/jvm/java-8-openjdk* /usr/lib/jvm/java-8-openjdk

# Set up user (mopuser)
RUN useradd -ms /bin/bash -c "mopuser" mopuser && echo "mopuser:docker" | chpasswd && adduser mopuser sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

WORKDIR /home/mopuser/
USER mopuser



# Use OpenJDK 8 when building the docker image
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk

# Install Maven 3.5.4 locally for user
RUN \
  wget http://mirrors.ibiblio.org/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
  tar -xzf apache-maven-3.6.3-bin.tar.gz && mv apache-maven-3.6.3/ apache-maven/ && \
  rm apache-maven-3.6.3-bin.tar.gz && \
# Install AspectJ
  wget https://www.cs.cornell.edu/courses/cs6156/2020fa/resources/aspectj1.8.tgz && \
  tar -xzf aspectj1.8.tgz && rm aspectj1.8.tgz && \
# Install JavaMOP
  git clone https://github.com/owolabileg/javamop.git && \
  cd /home/mopuser && \
  cd javamop/ && bash scripts/install-javaparser.sh && \
  cd /home/mopuser && \
  cd javamop/ && /home/mopuser/apache-maven/bin/mvn install -DskipTests && \
  cd /home/mopuser && \
  git clone https://github.com/zwt299/rv-violation-db.git
# Set up the user's configurations
ENV JAVAHOME=/usr/lib/jvm/java-8-openjdk
ENV JAVA_HOME=$JAVAHOME
ENV M2_HOME=$HOME/apache-maven
ENV MAVEN_HOME=$HOME/apache-maven
ENV ASPECTJ_DIR=$HOME/aspectj1.8
ENV PATH=$M2_HOME/bin:$JAVAHOME/bin:$ASPECTJ_DIR/bin:$ASPECTJ_DIR/lib/aspectjweaver.jar:$HOME/javamop/javamop/bin:$HOME/javamop/rv-monitor/bin:$HOME/javamop/rv-monitor/target/release/rv-monitor/lib/rv-monitor-rt.jar:$HOME/javamop/rv-monitor/target/release/rv-monitor/lib/rv-monitor.jar:$PATH
ENV CLASSPATH=$ASPECTJ_DIR/lib/aspectjtools.jar:$ASPECTJ_DIR/lib/aspectjrt.jar:$ASPECTJ_DIR/lib/aspectjweaver.jar:$HOME/javamop/rv-monitor/target/release/rv-monitor/lib/rv-monitor-rt.jar:$HOME/javamop/rv-monitor/target/release/rv-monitor/lib/rv-monitor.jar:$CLASSPATH
# Fetch the script that makes JavaMOP Java Agents and the files that it needs
RUN \
  wget https://www.cs.cornell.edu/courses/cs6156/2020fa/resources/javamop-agent-bundle.tgz && \
  tar xf javamop-agent-bundle.tgz && rm javamop-agent-bundle.tgz

RUN \
  echo '===============Building a JavaMOP Java agent===========' && \
  echo 'In the image: ${HOME}/javamop-agent-bundle/README.txt' && \
  echo '======================================================='

CMD source /home/mopuser/.bashrc && /home/mopuser/run_entrypoint ${VIO_ID}