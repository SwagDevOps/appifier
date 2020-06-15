# frozen_string_literal: true

# ```sh
# bundle config set clean 'true'
# bundle config set path 'vendor/bundle'
# bundle install
# ```
source 'https://rubygems.org'
git_source(:github) { |name| "https://github.com/#{name}.git" }

group :default do
end

group :development do
  { github: 'SwagDevOps/kamaze-project', branch: 'develop' }.tap do |options|
    gem(*['kamaze-project'].concat([options]))
  end

  gem 'sys-proc'
  gem 'rubocop', '~> 0.79'
  gem 'rugged', '~> 1.0'
end

group :watch do
  # 'listen' is used to "watch"
  # but could be incompatible with some systems
  gem 'listen', '~> 3.2'
end

group :doc do
  gem 'github-markup', '~> 3.0'
  gem 'redcarpet', '~> 3.5'
  gem 'yard', '~> 0.9'
end

group :repl do
  gem 'interesting_methods', '~> 0.1'
  gem 'pry', '~> 0.12'
end

group :test do
  gem 'rspec', '~> 3.8'
  gem 'sham', '~> 2.0'
  gem 'simplecov', '~> 0.16'
end
