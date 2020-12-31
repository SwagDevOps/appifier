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
    }.yield_self do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
  end

  # @param [Appifier::Recipe] recipe
  #
  # @see Appifier::Builder#build
  def call(recipe, docker:) # rubocop:disable Metrics/MethodLength
    {
      'DOCKER_APP_NAME' => recipe.to_h.fetch('app'),
      'DOCKER_CACHING' => config.fetch('docker_caching'),
    }.transform_values(&:to_s).tap do |env|
      Appifier::Scripts::Sequence.new(docker).start.tap do |scripts|
        {
          recipe.name.to_s => [
            [
              env,
              scripts.fetch(0).to_path,
              recipe.to_path,
            ]
          ]
        }.yield_self { |definitions| logged_runner.call(definitions) }
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
