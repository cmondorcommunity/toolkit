FROM jenkins/jenkins:lts

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN  grep -v -E '^#' /usr/share/jenkins/ref/plugins.txt | /usr/local/bin/install-plugins.sh

# Temporarily switch user to root for build
USER root

# Install Python requirements
COPY requirements.txt /tmp/requirements.txt

# Enable sudo
RUN apt-get update && \
    apt-get -y install sudo curl jq less nano python-pip virtualenv netcat && \
    usermod -aG sudo jenkins && \
    echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd && \
    pip install --upgrade --no-cache-dir -r /tmp/requirements.txt

# Packer https://releases.hashicorp.com/packer/1.2.4/packer_1.2.4_linux_amd64.zip
RUN curl -sSL -o /tmp/packer.zip https://releases.hashicorp.com/packer/1.2.4/packer_1.2.4_linux_amd64.zip && \
    unzip -uo /tmp/packer.zip -d /usr/local/bin && \
    chmod -R 755 /usr/local/bin/packer

# tfenv
RUN mkdir -p /usr/local/tfenv && \
    curl -sSL https://github.com/kamatama41/tfenv/archive/v0.6.0.tar.gz \
    | tar -xzC /usr/local/tfenv && \
    chmod 755 /usr/local/tfenv/tfenv-0.6.0/bin/* && \
    chown -R jenkins. /usr/local/tfenv/tfenv-0.6.0 && \
    ln -s /usr/local/tfenv/tfenv-0.6.0/bin/* /usr/local/bin

# docker client
RUN mkdir -p /usr/local/docker && \
    curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz \
    | tar -xzC /usr/local/docker && \
    ln -s /usr/local/docker/docker/docker /usr/local/bin/docker

ENV JAVA_OPTS -Duser.timezone=America/Los_Angeles -Xmx4096m  -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false

# New entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Default configs
COPY ref/ /usr/share/jenkins/ref/
RUN chown -R jenkins:root /usr/share/jenkins

# Switch back to jenkins user so that jenkins runs as jenkins
USER jenkins
WORKDIR /var/jenkins_home
