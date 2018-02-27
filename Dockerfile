FROM openjdk:9

RUN curl -o maven.tar.gz \
    'http://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz' \
    && tar -C /usr/src -zxvf maven.tar.gz \
    && ln -s /usr/src/apache-maven-3.5.2/bin/* /usr/local/bin/ \
