# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.0'

# Web
gem 'puma'
gem 'roda'
gem 'slim'

# Configuration
gem 'econfig'
gem 'rake'

# Debugging
gem 'pry'

# Communication
gem 'http'

# Security
gem 'rbnacl' # assumes libsodium package already installed

# Development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'rack-test'
  gem 'rerun'
end
