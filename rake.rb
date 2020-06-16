# frozen_string_literal: true

require 'rake'

autoload(:YAML, 'yaml')

if Gem::Specification.find_all_by_name('simplecov').any?
  if YAML.safe_load(ENV['coverage'].to_s) == true
    autoload(:SimpleCov, 'simplecov')

    SimpleCov.start do
      add_filter 'rake/'
      add_filter 'spec/'
    end
  end
end

require_relative 'lib/appifier'
require 'kamaze/project'

Kamaze::Project.instance do |c|
  c.subject = Appifier
  c.name = 'appifier'
  # @formatter:off
  # noinspection RubyLiteralArrayInspection
  c.tasks = [
    'cs', 'cs:pre-commit',
    'doc', 'doc:watch',
    'gem', 'gem:install',
    'misc:gitignore',
    'shell',
    'sources:license',
    'test',
    'version:edit',
  ].shuffle
  # @formatter:on
end.load!

task default: [:gem]

# @type [Kamaze::Project] project
if project.path('spec').directory?
  task :spec do |_task, args|
    Rake::Task[:test].invoke(*args.to_a)
  end
end
