# frozen_string_literal: true

require_relative '../scripts'
autoload(:Pathname, 'pathname')

# Represent a runner based on files to be downloaded and executed.
class Appifier::Scripts::Runner
  include(Appifier::Mixins::Inject)

  def initialize(**kwargs)
    {
      logged_runner: kwargs[:logged_runner],
      config: kwargs[:config],
      scripts_sequencer: [kwargs[:sequencer], :'scripts.sequencer'],
    }.yield_self do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
  end

  # @param recipe [Appifier::Recipe]
  # @param docker [Boolean]
  #
  # @see Appifier::Builder#build
  #
  # @return [Array<Appifier::DownloadableString>]
  def call(recipe, docker:)
    scripts_sequencer.call(docker).tap do |scripts|
      make_runner_definitions(scripts, recipe: recipe).yield_self { |definitions| logged_runner.call(definitions) }
    end
  end

  protected

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner

  # @return [Hash]
  # @return [Appifier::Config]
  attr_reader :config

  # @return [Class<Appifier::Scripts::Sequence>]
  attr_reader :scripts_sequencer

  # @api private
  #
  # @param recipe [Appifier::Recipe]
  #
  # @return [Hash{String => String}]
  def make_env(recipe:)
    # noinspection RubyYardReturnMatch
    {
      'DOCKER_APP_NAME' => recipe.to_h.fetch('app'),
      'DOCKER_CACHING' => config.fetch('docker_caching'),
    }.transform_values(&:to_s)
  end

  # Make definitions used by ``logged_runner``.
  #
  # @param scripts [Array<Appifier::DownloadableString>]
  # @param recipe [Appifier::Recipe]
  #
  # @return [Hash{String => Array}]
  def make_runner_definitions(scripts, recipe:)
    {
      recipe.name.to_s => [
        [
          make_env(recipe: recipe),
          scripts.fetch(0).to_path,
          recipe.to_path,
        ]
      ]
    }
  end
end
