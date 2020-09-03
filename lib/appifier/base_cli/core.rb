# frozen_string_literal: true

require_relative '../base_cli'
autoload(:Thor, 'thor')

# Simple inheritance of Thor
#
# @see https://github.com/erikhuda/thor/
# @see https://github.com/erikhuda/thor/issues/244
class Appifier::BaseCli::Core < Thor
  class << self
    def exit_on_failure?
      true
    end

    def start(given_args = ARGV, config = {})
      config[:shell] ||= Thor::Base.shell.new
      dispatch(nil, given_args.dup, nil, config)
    rescue Thor::UndefinedCommandError => e
      ErrorHandler.new(config).call(e, retcode: Errno::EINVAL::Errno)
    rescue Thor::Error => e
      ErrorHandler.new(config).call(e)
    rescue Errno::EPIPE
      # This happens if a thor command is piped to something like `head`,
      # which closes the pipe when it's done reading. This will also
      # mean that if the pipe is closed, further unnecessary
      # computation will not occur.
      exit(true)
    end
  end

  # Simple error handler
  class ErrorHandler
    # @param [Hash{Symbol => Object}] config
    def initialize(config, exit_on_failure: false)
      @config = config.freeze
      # noinspection RubySimplifyBooleanInspection
      @exit_on_failure = !!exit_on_failure
    end

    def exit_on_failure?
      self.exit_on_failure
    end

    # @param [StandardError] error
    # @param [Integer, Boolean] retcode
    #
    # @return [StandardError]
    # @raise [SystemExit]
    #
    # @see https://github.com/erikhuda/thor/blob/99330185faa6ca95e57b19a402dfe52b1eba8901/lib/thor/base.rb#L488
    def call(error, retcode: nil)
      error.tap do |e|
        config[:debug] || ENV['THOR_DEBUG'] == '1' ? (raise e) : config.fetch(:shell).error(e.message)
        exit(retcode || false) if exit_on_failure?
      end
    end

    protected

    # @return [Hash{Symbol => Object}]
    attr_reader :config

    # @return [Boolean]
    attr_reader :exit_on_failure
  end
end
