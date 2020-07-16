#!/bin/bash
set -ex

# Fresh
apt-get update

# Upgrade base
apt-get -y upgrade

# Install setup dependencies
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    gnupg2 \
    ;

# Install docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Add Git PPA
add-apt-repository -y ppa:git-core/ppa

# Install kube repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" |  tee -a /etc/apt/sources.list.d/kubernetes.list

apt-get update

# Create a runner user
useradd -ms /bin/bash runner

# Install the runner and its dependencies
mkdir -p /opt/actions-runner && cd /opt/actions-runner
curl -sLO https://github.com/actions/runner/releases/download/v${ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz
rm ./actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz
/opt/actions-runner/bin/installdependencies.sh

# Begrudgingly allow the runner to modify itself as it writes logs to ./_diag and credentials to ./.*
chown -R runner /opt/actions-runner

# Install utilities
# TODO grab this from https://help.github.com/en/actions/automating-your-workflow-with-github-actions/software-installed-on-github-hosted-runners somehow?
apt-get install -y \
    docker-ce \
    git \
    inetutils-ping \
    sudo \
    jq \
    unzip \
    kubectl \
;

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
 ./aws/install

# Install kustomize
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
ln -s $(pwd)/kustomize /usr/local/bin/kustomize

# Hook up the runner user with passwordless sudo
# https://help.github.com/en/actions/automating-your-workflow-with-github-actions/virtual-environments-for-github-hosted-runners#administrative-privileges-of-github-hosted-runners
echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner
chmod 0440 /etc/sudoers.d/runner


# Cleanup
rm -rf /var/lib/apt/lists/*
rm -f awscliv2.zip


echo "Hi" $NEW_REPO