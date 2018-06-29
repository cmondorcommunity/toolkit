FROM ubuntu:xenial

RUN apt-get update -y && \
  apt-get install -y python-pip unzip curl && \
  pip install awscli docker-compose && \
  rm -rf /var/apt/cache

RUN curl -s -L -o /tmp/tfenv.zip https://github.com/kamatama41/tfenv/archive/v0.6.0.zip

RUN curl -s -L -o /tmp/docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz

RUN unzip /tmp/tfenv.zip && \
      mv tfenv-0.6.0/ /usr/local/tfenv && \
      chmod 755 /usr/local/tfenv/bin/* && \
      ln -s /usr/local/tfenv/bin/* /usr/local/bin && \
      tar -zx -C /usr/local -f /tmp/docker.tgz && \
      ln -s /usr/local/docker/docker /usr/local/bin/docker

VOLUME "/app"

WORKDIR "/app"

ENTRYPOINT ["/app/docker/entrypoint.sh"]
