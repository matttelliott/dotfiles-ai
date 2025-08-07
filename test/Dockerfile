# Dockerfile for testing dotfiles-ai installation
# Based on Debian to match one of our target platforms

FROM debian:bookworm

# Install sudo and basic utilities
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create a test user with sudo privileges
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser:testuser" | chpasswd && \
    usermod -aG sudo testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Copy dotfiles repository
COPY --chown=testuser:testuser . /home/testuser/dotfiles-ai/

# Set working directory
WORKDIR /home/testuser/dotfiles-ai

# Run the CLI-only installation (no GUI tools)
RUN ./install-cli.sh

# Switch to zsh shell
SHELL ["/bin/zsh", "-c"]

# Default command - start zsh
CMD ["/bin/zsh"]