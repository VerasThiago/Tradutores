FROM ubuntu:latest
RUN apt-get update -y \
    && apt-get install -y valgrind \
    && apt-get install -y --no-install-recommends build-essential bison flex \
    && rm -rf /var/lib/apt/lists/* 
       
COPY . /usr/src/trad
WORKDIR /usr/src/trad