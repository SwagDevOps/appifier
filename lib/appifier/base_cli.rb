# frozen_string_literal: true

require_relative '../appifier'
autoload(:Thor, 'thor')

# @abstract
class Appifier::BaseCli
  class << self
    # @abstract
    #
    # @return [Hash{Symbol => hash}]
    def commands
      {}
    end

    # @!method runner
    #   @return [Appifier::BaseCli::Runner]
  end

  # A new instance of BaseCli.
  def initialize
    { instance: self, commands: commands }.tap do |params|
      core.instance_eval do
        params.fetch(:commands).each do |command_name, command|
          desc(command.fetch(:usage), command.fetch(:desc))
          command.fetch(:options, {}).each { |k, v| method_option(k, v) }
          define_method(command_name, &command.fetch(:method))
        end
      end
    end
  end

  # rubocop:enable

  # @param [Array<String>] given_args
  # @param [Hash] config
  def start(given_args = ARGV.dup, config = {})
    (given_args.include?('--help') ? ['help'] : given_args).yield_self do |args|
      core.start(args, config)
    end
  end

  alias call start

  protected

  # @return [Class<Thor>]
  def core
    { instance: self, commands: commands }.yield_self do |params|
      @core ||= Class.new(Thor) do
        no_commands do
          define_method(:runner) { params.fetch(:instance).class.const_get(:Runner).new(options) }
        end
      end
    end
  end

  # @return [Hash{Symbol => Hash}]
  def commands
    self.class.commands.map do |command_name, command|
      command_name.to_s.yield_self do |usage|
        command.fetch(:method).parameters.each do |v, k|
          usage = v != :req ? "#{usage} [#{k.to_s.upcase}]" : "#{usage} {#{k.to_s.upcase}}"
        end

        command.merge!({ usage: usage })
      end
      [command_name, command]
    end.to_h
  end

  # Runner providing methods.
  #
  # @abstract
  # @see Appifier::Cli::Runner
  class Runner
    # @return [Hash{Symbol => Object}]
    attr_reader :options

    # @param [Hash{String => Object}] options
    def initialize(options = {})
      @options = options.dup.transform_keys(&:to_sym).freeze
    end

    def call(method, *args)
      self.public_send(method, *args)
    end
  end
end
