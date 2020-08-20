# frozen_string_literal: true

require_relative '../appifier'

# Mixins namespace.
module Appifier::Scripts
  # @formatter:off
  {
    Pkg2appimage: 'pkg2appimage',
    FunctionsSh: 'functions_sh',
    Pkg2appimageWithDocker: 'pkg2appimage_with_docker',
    Dockerfile: 'dockerfile',
  }.each { |s, fp| autoload(s, "#{__dir__}/scripts/#{fp}") }
  # @formatter:on

  # Represent a runner based on files to be downloaded and on of them is executed.
  class Runner
    include(Appifier::Mixins::Inject)

    def initialize(**kwargs)
      { logged_runner: kwargs[:logged_runner] }.yield_self do |injection|
        inject(**injection).assert { !values.include?(nil) }
      end
    end

    # @param [Appifier::Recipe]
    def call(recipe, docker:)
      target = (docker ? recipe : recipe.realpath).to_s

      sequence(docker).map { |klass| klass.new.tap(&:call) }.tap do |scripts|
        logged_runner.call({ recipe.to_s => [[scripts.fetch(0).to_path, target]] })
      end
    end

    protected

    # @return [Array<Appifier::DownloadableString>]
    def sequence(docker)
      # @formatter:off
      {
        # fist item is actual executable script
        true => [Pkg2appimageWithDocker, Dockerfile, Pkg2appimage, FunctionsSh],
        false => [Pkg2appimage, FunctionsSh]
      }.fetch(docker)
      # @formatter:on
    end

    # @return [Appifier::LoggedRunner]
    attr_reader :logged_runner
  end
end
