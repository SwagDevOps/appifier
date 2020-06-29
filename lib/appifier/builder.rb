# frozen_string_literal: true

require_relative '../appifier'

# Builder
class Appifier::Builder
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')
  autoload(:Etc, 'etc')
  autoload(:Open3, 'open3')

  # @return [Appifier::Recipe]
  attr_reader :recipe

  include(Appifier::Shell)

  # @param [String] recipe
  # @param [Boolean] verbose
  def initialize(recipe, verbose: false, docker: true, install: false, config: Appifier::Config.new, arch: RbConfig::CONFIG.fetch('host_cpu')) # rubocop:disable Layout/LineLength, Metrics/ParameterLists
    @config = config
    @recipe = Appifier::Recipe.new(recipe, config: config).freeze
    # noinspection RubyStringKeysInHashInspection
    @env = { 'ARCH' => arch }
    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose
    # noinspection RubySimplifyBooleanInspection
    @docker = !!docker
    @fs = verbose ? FileUtils::Verbose : FileUtils
    # noinspection RubySimplifyBooleanInspection
    @installable = !!install
    @tmpdir = config.fetch('cache_dir')
  end

  def verbose?
    @verbose
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

  # @return [Hash{Symbol => Pathname}]
  def logs
    { out: 'out.log', err: 'err.log' }.map { |k, v| [k.to_sym, build_dir.join('logs', recipe.to_s, v)] }.to_h
  end

  def prepare!
    self.tap do
      build_dir { true }
      logs.each_value do |fp|
        if fp.is_a?(Pathname)
          fp.dirname.tap { |dir| fs.mkdir_p(dir) unless dir.exist? }
          fs.touch(fp)
        end
      end
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

  # @return [Array<Appifier::DownloadableString>]
  def downloadables
    # @formatter:off
    {
      # fist item is actual executable script
      true => [Appifier::PkgScriptDocker, Appifier::Dockerfile, Appifier::PkgScript],
      false => [Appifier::PkgScript]
    }.fetch(docker?).yield_self do |files| # @formatter:on
      files.map { |klass| klass.new(verbose: verbose?) }
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

  # @return [Pathname]
  def call
    build(downloadables)

    # rubocop:disable Layout/LineLength
    Appifier::Integration.new(build_dir.join('out'), recipe: recipe, config: config, verbose: verbose?, install: installable?).call
    # rubocop:enable Layout/LineLength,
  end

  protected

  # @return [FileUtils]
  attr_accessor :fs

  # @return [Pathname]
  attr_reader :tmpdir

  # @return [Hash{String => String}]
  attr_reader :env

  # @return [Pathname]
  attr_reader :builder

  # @return [Appifier::Config]
  attr_reader :config

  # @raise [ArgumentError]
  def recipe=(recipe)
    @recipe = recipe.to_sym
  end

  # @param [Array<Appifier::Downloadable>] scripts
  def build(scripts) # rubocop:disable Metrics/AbcSize
    build_dir do
      Pathname.new('recipes').join("#{recipe.filename}.yml").tap do |f|
        fs.mkdir_p(f.dirname)
        fs.cp(recipe.file.to_s, f)
      end

      self.logs.transform_values { |v| File.open(v, 'w') }.tap do |options|
        sh(env, scripts.map(&:call).fetch(0).to_s, target, options)
      end
    end
  end
end
