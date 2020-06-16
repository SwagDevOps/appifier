# frozen_string_literal: true

require_relative '../appifier'

# CLI entry point
#
# Sample of use:
#
# ```ruby
# Appifier::Cli.new(ARGV).call
# ```
class Appifier::Cli
  autoload(:YAML, 'yaml')

  def initialize(argv = ARGV, builder_class: Appifier::Builder)
    @argv = argv.dup.freeze
    @builder_class = builder_class
  end

  # Execute build for all given arguments
  #
  # @param [Array<String>]
  def call
    arguments.uniq.tap do |recipes|
      recipes.map do |recipe|
        builder_class.new(recipe, **options).prepare!.call
      end.tap do |builds|
        $stdout.puts(builds.join("\n"))
      end
    end
  end

  # @return [Hash{Symbol => Object}]
  def options
    argv.dup.keep_if do |s|
      s =~ /.+=.+/
    end.map do |s|
      s.split('=').yield_self { |res| [res[0], res[1..-1].join('=')] }
    end.map do |k, v|
      [k.to_sym, YAML.safe_load(v)]
    end.to_h
  end

  # @return [Array<String>]
  def arguments
    argv.dup.reject { |s| s =~ /.+=.+/ }
  end

  attr_reader :argv

  protected

  # @return [Class]
  attr_reader :builder_class
end
