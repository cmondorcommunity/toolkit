FROM jenkins/jenkins:lts

ENV GIT_ORG=""
ENV ORG_NAME=""

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN  grep -v -E '^#' /usr/share/jenkins/ref/plugins.txt | /usr/local/bin/install-plugins.sh

# Temporarily switch user to root for build
USER root

# Enable sudo
RUN apt-get update && \
    apt-get -y install sudo curl && \
    usermod -aG sudo jenkins && \
    echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd

# Install pip (needed for AWS CLI), virtualenv, and other utilities
RUN apt-get update && \
    apt-get -y install less nano python-pip virtualenv netcat

# Install Python requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade -r /tmp/requirements.txt

# Packer
RUN curl -s -L -o /tmp/packer.zip https://releases.hashicorp.com/packer/1.2.1/packer_1.2.1_linux_amd64.zip && \
    unzip -o /tmp/packer.zip -d /tmp && \
    chown root:root /tmp/packer && \
    chmod 755 /tmp/packer && \
    mv -f /tmp/packer /usr/local/bin/packer

# tfenv
RUN curl -s -L -o  /tmp/tfenv.tar.gz https://github.com/kamatama41/tfenv/archive/v0.6.0.tar.gz && \
    rm -Rf /tmp/tfenv-0.6.0/ /usr/local/tfenv-0.6.0 && \
    tar -C /tmp -xzf /tmp/tfenv.tar.gz && \
    chown -R jenkins:jenkins /tmp/tfenv-0.6.0 && \
    mv /tmp/tfenv-0.6.0 /usr/local/ && \
    ln -sf /usr/local/tfenv-0.6.0/bin/* /usr/local/bin/

#docker
RUN curl -s -L -o /tmp/docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz && \
    tar -zx -C /usr/local -f /tmp/docker.tgz && \
    ln -s /usr/local/docker/docker /usr/local/bin/docker

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
