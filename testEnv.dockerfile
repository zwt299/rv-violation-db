FROM ubuntu:18.04
ARG TAG

RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
# Install Git
  apt-get install -y git && \
  apt-get install -y sudo && \
# Install python
  apt-get update

# Set up user (mopuser)
RUN useradd -ms /bin/bash -c "mopuser" mopuser && echo "mopuser:docker" | chpasswd && adduser mopuser sudo

USER mopuser

WORKDIR /home/mopuser/

RUN \
    git clone https://github.com/zwt299/rv-violation-db.git && \


ENTRYPOINT []