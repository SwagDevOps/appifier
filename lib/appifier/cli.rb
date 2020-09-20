# frozen_string_literal: true

require_relative '../appifier'

# CLI entry point
#
# Sample of use:
#
# ```ruby
# Appifier::Cli.new.call
# ```
#
# @see Appifier::Cli::Runner
class Appifier::Cli < Appifier::BaseCli
  # Recurrent options.
  #
  # @api private
  # @todo use a more meaningful name
  OPTIONS = { # @formatter:off
    dry_run: {
      default: false,
      type: :boolean,
      desc: 'Never change files/directories, with printing message before acting',
    }.freeze,
    verbose: {
      default: false,
      type: :boolean,
      desc: 'Output messages before acting',
    }.freeze,
  }.freeze
  # @formatter:on

  class << self
    def commands # rubocop:disable Metrics/MethodLength:
      # @formatter:off
      {
        build: {
          desc: 'Build given recipe',
          options: {
            verbose: OPTIONS.fetch(:verbose),
            docker: {
              default: true,
              type: :boolean,
              desc: 'Docker',
            },
            install: {
              default: false,
              type: :boolean,
              desc: 'Install',
            }
          },
          method: ->(recipe) { runner.call(:build, recipe) },
        },
        config: {
          desc: 'Display config',
          options: {},
          method: -> { runner.call(:config) },
        },
        list: {
          desc: 'List builds based on app name',
          options: {
            detail: {
              default: false,
              type: :boolean,
              desc: 'Show detail',
            },
          },
          method: ->(pattern = nil) { runner.call(:list, pattern) },
        },
        uninstall: {
          desc: 'Uninstall',
          options: {
            verbose: OPTIONS.fetch(:verbose),
            dry_run: OPTIONS.fetch(:dry_run),
          },
          method: ->(pattern) { runner.call(:uninstall, pattern) },
        },
      }
      # @formatter:on
    end
  end
end

require_relative 'cli/runner'
