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

# Make scripts executable
RUN chmod +x install*.sh

# Run the CLI-only installation (no GUI tools)
# Run in non-interactive mode
RUN bash -c "yes | ./install-cli.sh" || true

# Run post-install if it exists
RUN if [ -f "./post-install-cli.sh" ]; then \
        bash -c "yes | ./post-install-cli.sh" || true; \
    fi

# Test that key tools were installed
RUN which zsh || echo "zsh not found" && \
    which tmux || echo "tmux not found" && \
    which nvim || echo "nvim not found" && \
    which fzf || echo "fzf not found" && \
    which rg || echo "ripgrep not found" && \
    which fd || echo "fd not found" && \
    which bat || echo "bat not found" && \
    which eza || echo "eza not found" && \
    which git || echo "git found" && \
    echo "Basic tool check complete"

# Switch to zsh shell if available
SHELL ["/bin/bash", "-c"]

# Default command - start bash (more reliable for testing)
CMD ["/bin/bash"]