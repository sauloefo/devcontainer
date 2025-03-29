FROM ubuntu:jammy
ENV DOCKER_BUILDKIT=1

SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]

# install gh apt repository

RUN <<EOF
(type -p wget >/dev/null || (apt update && apt-get install wget -y)) \
  && mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
EOF

RUN <<EOF
  apt update
  apt full-upgrade -y
  apt install -y --no-install-recommends \
    curl git gh neovim nano jq tar unzip \
    gnupg openssh-client libssl-dev ca-certificates bash-completion xz-utils locales
  apt-get clean
  rm -rf /var/lib/apt/lists/*
EOF

ENV HOME="/root"

ENV bashrc="$HOME/.bashrc"

RUN echo ". /etc/devcontainer/bashrc" >> "$bashrc"

COPY ./devcontainer /etc/devcontainer

# setup ssh forwarding

RUN <<EOF
  [ -f ~/.ssh ] || mkdir -p ~/.ssh
  echo "Host *" >> ~/.ssh/config
  echo "  ForwardAgent yes" >> ~/.ssh/config
EOF

# install oh-my-posh

RUN curl -s https://ohmyposh.dev/install.sh | bash -s
