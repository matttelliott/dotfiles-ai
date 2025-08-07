#!/bin/bash
# Ruby setup script via rbenv

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
    else
        PLATFORM="linux"
    fi
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

install_ruby_dependencies() {
    log_info "Installing Ruby build dependencies..."
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install openssl readline libyaml
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y \
                autoconf \
                bison \
                build-essential \
                libssl-dev \
                libyaml-dev \
                libreadline6-dev \
                zlib1g-dev \
                libncurses5-dev \
                libffi-dev \
                libgdbm6 \
                libgdbm-dev \
                libdb-dev \
                uuid-dev
            ;;
    esac
}

install_rbenv() {
    log_info "Installing rbenv (Ruby Version Manager)..."
    
    if [[ -d "$HOME/.rbenv" ]]; then
        log_info "rbenv is already installed"
        # Update rbenv
        cd "$HOME/.rbenv" && git pull && cd - > /dev/null
        # Update ruby-build
        if [[ -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
            cd "$HOME/.rbenv/plugins/ruby-build" && git pull && cd - > /dev/null
        fi
        return 0
    fi
    
    # Install rbenv
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    
    # Install ruby-build plugin
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    
    # Install rbenv-gemset plugin (optional)
    git clone https://github.com/jf/rbenv-gemset.git ~/.rbenv/plugins/rbenv-gemset
    
    # Install rbenv-vars plugin (optional)
    git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
    
    log_success "rbenv installed successfully"
}

setup_rbenv_shell_integration() {
    log_info "Setting up rbenv shell integration..."
    
    local rbenv_config='
# rbenv (Ruby Version Manager)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - 2>/dev/null || true)"

# rbenv aliases
alias rbv="rbenv versions"
alias rbi="rbenv install"
alias rbg="rbenv global"
alias rbl="rbenv local"
alias rbs="rbenv shell"
alias rbu="rbenv uninstall"
alias rbr="rbenv rehash"
alias rbw="rbenv which"
alias rbp="rbenv version"

# Bundle aliases
alias be="bundle exec"
alias bi="bundle install"
alias bu="bundle update"
alias bc="bundle clean"
alias bo="bundle open"

# Rails aliases
alias rs="rails server"
alias rc="rails console"
alias rg="rails generate"
alias rd="rails destroy"
alias rdb="rails db:migrate"
alias rdbr="rails db:rollback"
alias rdbs="rails db:seed"
alias rt="rails test"
alias rr="rails routes"

# Gem aliases
alias gi="gem install"
alias gu="gem update"
alias gun="gem uninstall"
alias gl="gem list"
alias gs="gem search"

# Ruby aliases
alias rb="ruby"
alias irb="irb --simple-prompt"
'
    
    # Add to shell RC files
    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "rbenv init" "$rc_file"; then
                echo "$rbenv_config" >> "$rc_file"
                log_success "Added rbenv config to $(basename $rc_file)"
            else
                log_info "rbenv already configured in $(basename $rc_file)"
            fi
        fi
    done
    
    # Source for current session
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)" || true
}

install_ruby_versions() {
    log_info "Installing Ruby versions..."
    
    # Ensure rbenv is available
    if ! command -v rbenv &> /dev/null; then
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
    fi
    
    if ! command -v rbenv &> /dev/null; then
        log_error "rbenv not found in PATH"
        return 1
    fi
    
    # Install latest stable Ruby 3.2 and 3.3
    local ruby_versions=("3.2" "3.3")
    
    for version in "${ruby_versions[@]}"; do
        # Get latest patch version
        latest=$(rbenv install --list 2>/dev/null | grep -E "^${version}\.[0-9]+$" | tail -1 | xargs)
        
        if [[ -n "$latest" ]]; then
            if rbenv versions | grep -q "$latest"; then
                log_info "Ruby $latest is already installed"
            else
                log_info "Installing Ruby $latest (this may take a while)..."
                rbenv install "$latest"
                log_success "Ruby $latest installed"
            fi
        else
            log_warning "Could not find Ruby $version version"
        fi
    done
    
    # Set global Ruby to latest 3.3
    latest_33=$(rbenv versions --bare | grep -E "^3\.3\.[0-9]+$" | tail -1)
    if [[ -n "$latest_33" ]]; then
        rbenv global "$latest_33"
        rbenv rehash
        log_success "Set global Ruby to $latest_33"
    fi
}

install_ruby_gems() {
    log_info "Installing essential Ruby gems..."
    
    # Ensure rbenv Ruby is being used
    if ! command -v gem &> /dev/null; then
        log_warning "gem not found, skipping gem installation"
        return 1
    fi
    
    # Update RubyGems itself
    log_info "Updating RubyGems..."
    gem update --system
    
    # Essential gems
    local gems=(
        "bundler"           # Dependency management
        "rake"              # Build tool
        "pry"               # Better REPL
        "rubocop"           # Linter
        "solargraph"        # Language server
        "rails"             # Web framework
        "sinatra"           # Lightweight web framework
        "rspec"             # Testing framework
        "minitest"          # Testing framework
        "foreman"           # Process manager
        "dotenv"            # Environment variables
        "puma"              # Web server
        "sidekiq"           # Background jobs
        "debug"             # Debugger
        "fasterer"          # Performance suggestions
        "reek"              # Code smell detector
        "brakeman"          # Security scanner
    )
    
    log_info "Installing essential gems..."
    for gem_name in "${gems[@]}"; do
        log_info "Installing $gem_name..."
        gem install "$gem_name" || log_warning "Failed to install $gem_name"
    done
    
    # Rehash to make new commands available
    rbenv rehash
    
    log_success "Ruby gems installed"
}

setup_gem_config() {
    log_info "Configuring RubyGems..."
    
    # Create gemrc
    cat > "$HOME/.gemrc" << 'EOF'
---
:backtrace: false
:bulk_threshold: 1000
:sources:
- https://rubygems.org/
:update_sources: true
:verbose: true
gem: --no-document
benchmark: false
EOF
    
    log_success "RubyGems configured"
}

create_ruby_templates() {
    log_info "Creating Ruby project templates..."
    
    # Create template directory
    mkdir -p "$HOME/.config/ruby/templates"
    
    # Create .ruby-version template
    if command -v ruby &> /dev/null; then
        ruby -v | awk '{print $2}' > "$HOME/.config/ruby/ruby-version.template"
    fi
    
    # Create Gemfile template
    cat > "$HOME/.config/ruby/templates/Gemfile" << 'EOF'
source 'https://rubygems.org'

ruby File.read('.ruby-version').strip

# Web framework (choose one)
# gem 'rails', '~> 7.1'
# gem 'sinatra'

# Database
# gem 'pg'           # PostgreSQL
# gem 'mysql2'       # MySQL
# gem 'sqlite3'      # SQLite

# Web server
gem 'puma'

# Background jobs
# gem 'sidekiq'
# gem 'resque'

# Testing
group :test do
  gem 'rspec'
  gem 'minitest'
  gem 'capybara'
  gem 'factory_bot'
  gem 'faker'
end

# Development
group :development do
  gem 'rubocop', require: false
  gem 'solargraph', require: false
  gem 'debug'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
end

# Development and test
group :development, :test do
  gem 'dotenv'
  gem 'byebug'
end
EOF
    
    # Create Rakefile template
    cat > "$HOME/.config/ruby/templates/Rakefile" << 'EOF'
require 'rake/testtask'
require 'rubocop/rake_task'

desc "Run tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc "Run RuboCop"
RuboCop::RakeTask.new(:rubocop)

desc "Run all checks"
task :check => [:test, :rubocop]

task :default => :test
EOF
    
    # Create .rubocop.yml template
    cat > "$HOME/.config/ruby/templates/.rubocop.yml" << 'EOF'
AllCops:
  TargetRubyVersion: 3.2
  NewCops: enable
  Exclude:
    - 'vendor/**/*'
    - 'db/schema.rb'
    - 'db/migrate/*'
    - 'bin/*'
    - 'node_modules/**/*'

Style/Documentation:
  Enabled: false

Style/FrozenStringLiteralComment:
  Enabled: true

Metrics/MethodLength:
  Max: 15

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'test/**/*'

Layout/LineLength:
  Max: 120
EOF
    
    log_success "Ruby templates created"
}

# Main installation
main() {
    log_info "Setting up Ruby with rbenv..."
    
    install_ruby_dependencies
    install_rbenv
    setup_rbenv_shell_integration
    install_ruby_versions
    install_ruby_gems
    setup_gem_config
    create_ruby_templates
    
    log_success "Ruby setup complete!"
    echo
    if command -v ruby &> /dev/null; then
        echo "Ruby $(ruby -v | awk '{print $2}') is installed"
    fi
    echo
    echo "rbenv commands:"
    echo "  rbenv install 3.3     - Install Ruby 3.3"
    echo "  rbenv global 3.3      - Set global Ruby"
    echo "  rbenv local 3.2       - Set local Ruby"
    echo "  rbenv versions        - List installed versions"
    echo
    echo "Installed gems:"
    echo "  bundler, rails, rspec, rubocop, pry, and more"
    echo
    echo "Note: Restart your shell or run 'source ~/.zshrc' to use rbenv"
}

main "$@"