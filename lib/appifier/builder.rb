# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')
autoload(:FileUtils, 'fileutils')
autoload(:Etc, 'etc')
autoload(:Open3, 'open3')

# Builder
class Appifier::Builder
  include(Appifier::Mixins::Shell)
  include(Appifier::Mixins::Fs)
  include(Appifier::Mixins::Verbose)

  # @return [Appifier::Recipe]
  attr_reader :recipe

  # @param [String] recipe
  def initialize(recipe, docker: true, install: false, config: Appifier.container[:config])
    @config = config
    @recipe = Appifier::Recipe.new(recipe, config: config).freeze
    # noinspection RubySimplifyBooleanInspection
    @docker = !!docker
    # noinspection RubySimplifyBooleanInspection
    @installable = !!install
    @tmpdir = config.fetch('cache_dir')
  end

  # @return [Hash{String => String}]
  def env
    # @formatter:off
    # noinspection RubyStringKeysInHashInspection
    {
      'ARCH' => config.fetch('build_arch'),
      'LC_ALL' => 'C.UTF-8',
      'LANG' => 'C.UTF-8',
      'LANGUAGE' => 'C.UTF-8',
      'FUNCTIONS_SH' => tmpdir.join('functions.sh'),
    }.dup.transform_keys(&:freeze).transform_values { |v| v.to_s.freeze }
    # @formatter:on
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
      true => [Appifier::PkgScriptDocker, Appifier::Dockerfile, Appifier::PkgScript, Appifier::PkgFunctions],
      false => [Appifier::PkgScript, Appifier::PkgFunctions]
    }.fetch(docker?).yield_self do |files| # @formatter:on
      # @type [Class<Appifier::DownloadableString>] klass
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

    Appifier::Integration.new(build_dir.join('out'), recipe: recipe, install: installable?).call
  end

  protected

  # @return [Appifier::Config]
  attr_reader :config

  # @return [Pathname]
  attr_reader :tmpdir

  # @return [Pathname]
  attr_reader :builder

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
