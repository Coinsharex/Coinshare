# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5'
gem 'roda', '~>3'

# Configuration
gem 'figaro', '~>1'
gem 'rake'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb'
gem 'sequel', '~>5'

group :production do
  gem 'pg'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

gem 'pry'

group :development do
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-performance'

end

group :development, :test do
  gem 'rack-test'
  gem 'sequel-seed'
  gem 'sqlite3'
end

# Coverage
gem 'simplecov'