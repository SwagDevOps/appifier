# frozen_string_literal: true

require_relative '../appifier'

# CLI entry point
#
# Sample of use:
#
# ```ruby
# Appifier::Cli.new.call
# ```
class Appifier::Cli < Appifier::BaseCli
  class << self
    def commands # rubocop:disable Metrics/MethodLength:
      # @formatter:off
      {
        build: {
          desc: 'Build',
          options: {
            verbose: {
              default: false,
              type: :boolean,
              desc: 'Verbose'
            },
            docker: {
              default: true,
              type: :boolean,
              desc: 'Docker'
            },
            install: {
              default: false,
              type: :boolean,
              desc: 'Install'
            }
          },
          method: ->(recipe) { runner.build(recipe) }
        }
      }
      # @formatter:on
    end
  end

  # Runner providing methods.
  class Runner < Appifier::BaseCli::Runner
    def build(recipe)
      Appifier::Builder.new(recipe, **options).prepare!.call.tap do |build|
        $stdout.puts(build)
      end
    end
  end
end
