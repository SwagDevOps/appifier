# frozen_string_literal: true

require_relative '../scripts'
autoload(:Pathname, 'pathname')

# Represent a runner based on files to be downloaded and executed.
class Appifier::Scripts::Runner
  include(Appifier::Mixins::Inject)

  def initialize(**kwargs)
    { logged_runner: kwargs[:logged_runner] }.yield_self do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
  end

  # @param [String] target
  def call(target, docker:)
    Pathname.new(target).basename('.yml').yield_self do |targent_name|
      # @formatter:off
      Appifier::Scripts::Sequence.new(docker).start.tap do |scripts|
        {
          targent_name => [[scripts.fetch(0).to_path, target]]
        }.yield_self do |definitions|
          logged_runner.call(definitions)
        end
      end
      # @formatter:on
    end
  end

  protected

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner
end
