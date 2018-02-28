FROM openjdk:8


# Ubuntu has the necessary framework to start from
FROM ubuntu:14.04

# Run as root
USER root

# Create Distelli user
RUN useradd -ms /bin/bash distelli

# Set /home/distelli as the working directory
WORKDIR /home/distelli

# Install JDK8 and maven
RUN sudo apt-get update \
    && sudo apt-get install -y software-properties-common python-software-properties curl \
    && sudo add-apt-repository ppa:openjdk-r/ppa \
    && sudo apt-get update \
    && sudo apt-get install -y openjdk-8-jdk ca-certificates-java \
    && sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure \
    && curl -o maven.tar.gz \
    'http://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz' \
    && sudo tar -C /usr/src -zxvf maven.tar.gz \
    && sudo ln -s /usr/src/apache-maven-3.5.2/bin/* /usr/local/bin/ \
    && locale-gen en_US.UTF-8 \
    && export LANG=en_US.utf8 \
    && echo 'LANG=en_US.utf8' >> /etc/default/locale

# Install prerequisites. This provides me with the essential tools for building with.
# Note. You don't need git or mercurial.
RUN sudo apt-get update -y \
    && sudo apt-get -y install build-essential checkinstall git mercurial \
    && sudo apt-get -y install libssl-dev openssh-client openssh-server \
    && sudo apt-get -y install curl apt-transport-https ca-certificates

# Update the .ssh/known_hosts file:
RUN sudo sh -c "ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts"

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://www.distelli.com/download/client | sh 

# Install docker
# Note. This is only necessary if you plan on building docker images
RUN sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && sudo sh -c "echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list" \
    && sudo apt-get update -y \
    && sudo apt-get purge -y lxc-docker \
    && sudo apt-get -y install docker-engine \
    && sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose' \
    && sudo chmod +x /usr/local/bin/docker-compose \
    && sudo docker -v

# Setup a volume for writing docker layers/images
VOLUME /var/lib/docker

# Install gosu
ENV GOSU_VERSION 1.9
RUN sudo curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
     && sudo chmod +x /bin/gosu

USER root

# The following entry point is not necessary
CMD ["/bin/bash"]
