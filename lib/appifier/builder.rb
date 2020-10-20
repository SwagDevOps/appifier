# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')
autoload(:FileUtils, 'fileutils')
autoload(:Etc, 'etc')
autoload(:Open3, 'open3')

# Builder
class Appifier::Builder
  include(Appifier::Mixins::Inject)
  include(Appifier::Mixins::Immutable)

  # @return [Appifier::Recipe]
  attr_reader :recipe

  # @param [String] recipe
  #
  # @option kwargs [Boolean] :docker
  # @option kwargs [Boolean] :install
  def initialize(recipe, docker: true, install: false, **kwargs) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # @formatter:off
    {
      config: kwargs[:config],
      fs: kwargs[:fs],
      lister: [kwargs[:lister], :builds_lister],
      scripts_runner: [kwargs[:scripts_runner], :'build.scripts_runner'],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

    immutable! do
      @recipe = Appifier::Recipe.new(recipe, config: self.config).freeze
      # noinspection RubySimplifyBooleanInspection
      @docker = !!docker
      # noinspection RubySimplifyBooleanInspection
      @installable = !!install
      @tmpdir = self.config.fetch('cache_dir').freeze
    end
  end

  # Return an array of created files.
  #
  # @return [Appifier::BuildLister::Build]
  # @return [Array<Pathname>] when installable
  def call # rubocop:disable Metrics/MethodLength
    build

    # noinspection RubyYardReturnMatch
    builds.last.yield_self do |last_build|
      # noinspection RubyNilAnalysis
      # @formatter:off
      {
        false => -> { last_build },
        true => lambda do
          [last_build]
            .concat(Appifier::Integration.new(last_build, recipe: recipe).call)
            .map { |fp| Pathname.new(fp) }.sort.uniq
        end
      }.fetch(installable?).call
      # @formatter:on
    end
  end

  # Denote build will be run in a docker context.
  #
  # @return [Boolean]
  def docker?
    @docker
  end

  # Denote install will be run after build.
  #
  # @return [Boolean]
  def installable?
    @installable
  end

  # Target used during build.
  #
  # Differs depending on docker or raw script execution:
  #
  # * ``pkg2appimage-with-docker``
  # * ``pkg2appimage``
  def target
    (docker? ? recipe : recipe.realpath).to_s
  end

  protected

  # @return [Appifier::FileSystem]
  # @return [FileUtils]
  attr_reader :fs

  # @return [Appifier::Config]
  attr_reader :config

  # @return [Pathname]
  attr_reader :tmpdir

  # @return [Pathname]
  attr_reader :builder

  # @return [Appifier::BuildsLister]
  attr_reader :lister

  # @return [Appifier::Scripts::Runner]
  attr_reader :scripts_runner

  # @raise [ArgumentError]
  def recipe=(recipe)
    @recipe = recipe.to_sym
  end

  # Get list of builds (through lister) for current app.
  #
  # @raise [KeyError]
  #
  # @return [Array<Appifier::BuildsLister::Build>]
  def builds
    # noinspection RubyYardReturnMatch
    recipe.to_h.fetch('app').yield_self { |app_name| lister.call.fetch(app_name) }
  end

  def build
    build_dir do
      Pathname.new('recipes').join("#{recipe.filename}.yml").tap do |f|
        fs.mkdir_p(f.dirname)
        fs.cp(recipe.file.to_s, f)
      end

      # @type [Appifier::Scripts::Runner] scripts_runner
      scripts_runner.call(recipe, docker: docker?)
    end
  end

  # @return [Pathname|Object]
  def build_dir(&block)
    tmpdir.tap do |dir|
      if block
        fs.mkdir_p(dir) unless dir.exist?
        return Dir.chdir(dir.realpath) { block.call }
      end
    end
  end
end
