# frozen_string_literal: true

require_relative '../scripts'
autoload(:Pathname, 'pathname')

# Represent a runner based on files to be downloaded and executed.
class Appifier::Scripts::Runner
  include(Appifier::Mixins::Inject)

  def initialize(**kwargs)
    # @formatter:off
    {
      logged_runner: kwargs[:logged_runner],
      config: kwargs[:config],
    }.yield_self do |injection|
      # @formatter:on
      inject(**injection).assert { !values.include?(nil) }
    end
  end

  # @param [Appifier::Recipe] recipe
  def call(recipe, docker:)
    # @formatter:off
    {
      'DOCKER_APP_NAME' => recipe.to_h.fetch('app'),
      'DOCKER_CACHING' => config.fetch('docker_caching'),
    }.transform_values(&:to_s).tap do |env|
      # @formatter:on
      Appifier::Scripts::Sequence.new(docker).start.tap do |scripts|
        # @formatter:off
        {
          recipe.name.to_s => [[env, scripts.fetch(0).to_path, recipe.name.to_s]]
        }.yield_self { |definitions| logged_runner.call(definitions) } # @formatter:on
      end
    end
  end

  protected

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner

  # @return [Hash]
  # @return [Appifier::Config]
  attr_reader :config
end
