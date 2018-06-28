FROM ubuntu:xenial

RUN apt-get update -y && \
  apt-get install -y python-pip unzip curl && \
  pip install awscli  && \
  rm -rf /var/apt/cache

RUN curl -s -L -o /tmp/tfenv.zip https://github.com/kamatama41/tfenv/archive/v0.6.0.zip

RUN unzip /tmp/tfenv.zip && \
      mv tfenv-0.6.0/ /usr/local/tfenv && \
      chmod 755 /usr/local/tfenv/bin/* && \
      ln -s /usr/local/tfenv/bin/* /usr/local/bin

VOLUME "/app"

WORKDIR "/app"

ENTRYPOINT ["/app/docker/entrypoint.sh"]
