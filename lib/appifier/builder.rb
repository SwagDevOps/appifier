# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')
autoload(:FileUtils, 'fileutils')
autoload(:Etc, 'etc')
autoload(:Open3, 'open3')

# Builder
class Appifier::Builder
  include(Appifier::Mixins::Fs)
  include(Appifier::Mixins::Inject)
  include(Appifier::Mixins::Verbose)

  # @return [Appifier::Recipe]
  attr_reader :recipe

  # @param [String] recipe
  #
  # @option kwargs [Boolean] :docker
  # @option kwargs [Boolean] :install
  def initialize(recipe, docker: true, install: false, **kwargs)
    # @formatter:off
    {
      config: kwargs[:config],
      lister: [kwargs[:lister], :builds_lister],
      logged_runner: kwargs[:logged_runner],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

    @recipe = Appifier::Recipe.new(recipe, config: self.config).freeze
    # noinspection RubySimplifyBooleanInspection
    @docker = !!docker
    # noinspection RubySimplifyBooleanInspection
    @installable = !!install
    @tmpdir = self.config.fetch('cache_dir')
  end

  # Return an array of created files.
  #
  # @return [Array<Pathname>]
  def call
    build(downloadables)

    [builds.last].tap do |builds|
      Appifier::Integration.new(builds.fetch(0), recipe: recipe).call if installable?
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

  # @return [Pathname|Object]
  def build_dir(&block)
    tmpdir.tap do |dir|
      if block
        fs.mkdir_p(dir) unless dir.exist?
        return Dir.chdir(dir.realpath) { block.call }
      end
    end
  end

  # @return [Array<Appifier::DownloadableString>]
  def downloadables
    # @formatter:off
    {
      # fist item is actual executable script
      true => [Appifier::PkgScriptDocker, Appifier::Dockerfile, Appifier::PkgScript, Appifier::PkgFunctions],
      false => [Appifier::PkgScript, Appifier::PkgFunctions]
    }.fetch(docker?).yield_self do |files| # @formatter:on
      # @type [Class<Appifier::DownloadableString>] klass
      files.map(&:new)
    end
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

  # @return [Appifier::Config]
  attr_reader :config

  # @return [Pathname]
  attr_reader :tmpdir

  # @return [Pathname]
  attr_reader :builder

  # @return [Appifier::BuildsLister]
  attr_reader :lister

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner

  # @raise [ArgumentError]
  def recipe=(recipe)
    @recipe = recipe.to_sym
  end

  # Get list of builds (through lister) for current app.
  #
  # @return [Array<Pathname>]
  def builds
    recipe.to_h.fetch('app').yield_self do |app_name|
      lister.call.fetch(app_name).map { |build| Pathname.new(build.path) }
    end
  end

  # @param [Array<Appifier::Downloadable>] scripts
  def build(scripts) # rubocop:disable Metrics/AbcSize
    build_dir do
      Pathname.new('recipes').join("#{recipe.filename}.yml").tap do |f|
        fs.mkdir_p(f.dirname)
        fs.cp(recipe.file.to_s, f)
      end

      logged_runner.call({ recipe.to_s => [[scripts.map(&:call).fetch(0).to_s, target]] })
    end
  end
end
