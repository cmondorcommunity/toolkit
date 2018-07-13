FROM ubuntu:xenial

# utils
RUN apt-get update -y && \
  apt-get install -y python-pip unzip curl jq && \
  pip install --no-cache-dir awscli docker-compose && \
  rm -rf /var/lib/apt/lists/*

# tfenv
RUN mkdir -p /usr/local/tfenv && \
    curl -sSL https://github.com/kamatama41/tfenv/archive/v0.6.0.tar.gz \
    | tar -xzC /usr/local/tfenv && \
    chmod 755 /usr/local/tfenv/tfenv-0.6.0/bin/* && \
    ln -s /usr/local/tfenv/tfenv-0.6.0/bin/* /usr/local/bin

# docker client
RUN mkdir -p /usr/local/docker && \
    curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz \
    | tar -xzC /usr/local/docker && \
    ln -s /usr/local/docker/docker/docker /usr/local/bin/docker

VOLUME "/app"

WORKDIR "/app"

ENTRYPOINT ["/app/docker/entrypoint.sh"]

