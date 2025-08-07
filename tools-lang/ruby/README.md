# Ruby - Dynamic Programming Language

Ruby development with rbenv for version management and essential gems.

## Installation

```bash
./tools-lang/ruby/setup.sh
```

## What Gets Installed

### Core Tools
- **rbenv** - Ruby version manager
- **ruby-build** - Compile and install Ruby versions
- **Ruby 3.2 & 3.3** - Latest stable versions

### Essential Gems
- **bundler** - Dependency management
- **rails** - Full-stack web framework
- **rspec** - BDD testing framework
- **rubocop** - Ruby linter
- **pry** - Enhanced REPL
- **solargraph** - Language server
- **debug** - Ruby debugger

## Version Management with rbenv

### Installing Ruby Versions
```bash
rbenv install 3.3.0       # Specific version
rbenv install 3.2         # Latest 3.2.x
rbenv install --list      # List available versions
```

### Setting Ruby Versions
```bash
rbenv global 3.3.0        # Set default Ruby
rbenv local 3.2.0         # Set for current project
rbenv shell 3.1.0         # Set for current shell
```

### Managing Versions
```bash
rbenv versions            # List installed versions
rbenv version             # Show current version
rbenv which ruby          # Path to Ruby executable
rbenv rehash              # Refresh shims
```

## Dependency Management with Bundler

### Project Setup
```bash
bundle init               # Create Gemfile
bundle install            # Install dependencies
bundle update             # Update gems
bundle exec command       # Run with bundle context
```

### Gemfile Example
```ruby
source 'https://rubygems.org'
ruby '3.3.0'

gem 'rails', '~> 7.1'
gem 'puma'
gem 'pg'

group :development, :test do
  gem 'rspec-rails'
  gem 'debug'
end
```

## Common Workflows

### New Rails Project
```bash
gem install rails
rails new myapp
cd myapp
bundle install
rails server
```

### New Ruby Project
```bash
mkdir myproject && cd myproject
echo "3.3.0" > .ruby-version
bundle init
# Edit Gemfile
bundle install
```

### Running Tests
```bash
# RSpec
bundle exec rspec
bundle exec rspec spec/models

# Minitest
bundle exec rake test
bundle exec ruby -Itest test/models/user_test.rb
```

### Code Quality
```bash
# Linting
bundle exec rubocop
bundle exec rubocop -a      # Auto-fix

# Security
bundle exec brakeman

# Performance
bundle exec fasterer
```

## Configured Aliases

### rbenv
- `rbv` - rbenv versions
- `rbi` - rbenv install
- `rbg` - rbenv global
- `rbl` - rbenv local
- `rbs` - rbenv shell
- `rbr` - rbenv rehash

### Bundle
- `be` - bundle exec
- `bi` - bundle install
- `bu` - bundle update
- `bc` - bundle clean
- `bo` - bundle open

### Rails
- `rs` - rails server
- `rc` - rails console
- `rg` - rails generate
- `rd` - rails destroy
- `rdb` - rails db:migrate
- `rt` - rails test

### Gems
- `gi` - gem install
- `gu` - gem update
- `gun` - gem uninstall
- `gl` - gem list

## Rails Development

### Generators
```bash
rails generate model User
rails generate controller Users
rails generate scaffold Post title:string
rails generate migration AddEmailToUsers
```

### Database
```bash
rails db:create           # Create database
rails db:migrate          # Run migrations
rails db:rollback         # Rollback migration
rails db:seed             # Seed database
rails db:reset            # Drop and recreate
```

### Console
```bash
rails console             # Interactive console
rails console --sandbox   # Rollback on exit
rails dbconsole          # Database console
```

### Testing
```bash
rails test                # Run all tests
rails test:models         # Test models only
rails test test/models/user_test.rb
```

## Debugging

### With debug gem
```ruby
require 'debug'

def some_method
  debugger  # Breakpoint
  # code
end
```

### With pry
```ruby
require 'pry'

def some_method
  binding.pry  # Breakpoint
  # code
end
```

### Rails Console
```ruby
# Reload console
reload!

# Pretty print
pp User.first

# View methods
User.methods.sort

# Source location
User.method(:find).source_location
```

## Performance

### Profiling
```bash
bundle exec ruby-prof script.rb
bundle exec stackprof script.rb
```

### Benchmarking
```ruby
require 'benchmark'

Benchmark.bm do |x|
  x.report("method1") { method1 }
  x.report("method2") { method2 }
end
```

### Memory Profiling
```bash
bundle exec memory_profiler script.rb
```

## Best Practices

1. **Use .ruby-version** - Specify Ruby version per project
2. **Pin gem versions** - Avoid surprises in production
3. **Use Bundler** - Always use bundle exec
4. **Write tests** - TDD/BDD with RSpec or Minitest
5. **Lint code** - Use RuboCop consistently
6. **Document code** - YARD documentation
7. **Use frozen strings** - Add magic comment
8. **Avoid monkey patching** - Use refinements
9. **Follow conventions** - Ruby style guide
10. **Profile first** - Don't guess performance

## Common Gems

### Web
- `rails` - Full-stack framework
- `sinatra` - Lightweight framework
- `rack` - Web server interface
- `puma` - Web server

### Database
- `pg` - PostgreSQL
- `mysql2` - MySQL
- `sqlite3` - SQLite
- `redis` - Redis client
- `activerecord` - ORM

### Testing
- `rspec` - BDD framework
- `minitest` - Built-in testing
- `capybara` - Integration testing
- `factory_bot` - Test factories
- `faker` - Fake data

### Background Jobs
- `sidekiq` - Background processing
- `resque` - Redis-backed jobs
- `delayed_job` - Database-backed jobs

### API
- `grape` - REST API framework
- `jbuilder` - JSON builder
- `active_model_serializers` - Serialization

## Tips

1. **Learn Ruby first** - Before Rails
2. **Read the docs** - Ruby and gem docs are excellent
3. **Use IRB/Pry** - Interactive exploration
4. **Understand blocks** - Core to Ruby
5. **Master enumerable** - Powerful methods
6. **Use symbols** - For identifiers
7. **Embrace conventions** - Convention over configuration
8. **Write idiomatic Ruby** - Read Ruby style guide
9. **Test everything** - Ruby makes testing easy
10. **Have fun** - Ruby is designed for happiness!