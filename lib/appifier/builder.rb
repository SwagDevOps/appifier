# frozen_string_literal: true

require_relative '../appifier'

# Builder
class Appifier::Builder
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')
  autoload(:Etc, 'etc')
  autoload(:YAML, 'yaml')
  autoload(:Open3, 'open3')

  # @return [String]
  attr_reader :recipe

  include(Appifier::Shell)

  # @param [String] recipe
  # @param [Boolean] verbose
  def initialize(recipe, verbose: false, docker: true, config: Appifier::Config.new, arch: RbConfig::CONFIG.fetch('host_cpu')) # rubocop:disable Layout/LineLength
    self.recipe = recipe

    @config = config
    # noinspection RubyStringKeysInHashInspection
    @env = { 'ARCH' => arch }
    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose
    # noinspection RubySimplifyBooleanInspection
    @docker = !!docker
    @fs = verbose ? FileUtils::Verbose : FileUtils
    @tmpdir = config.fetch('cache_dir') do
      require 'tmpdir' unless Dir.respond_to?(:tmpdir)

      Pathname.new(Dir.tmpdir).realpath.join("pkg2appimage.#{Etc.getpwnam(Etc.getlogin).uid}")
    end.yield_self { |path| Pathname.new(path) }
  end

  def verbose?
    @verbose
  end

  def docker?
    @docker
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

  def app_name
    YAML.safe_load(recipe_file.read).fetch('app')
  end

  # @return [Pathname]
  def recipe_file
    recipes_dir.realpath.join("#{recipe}.yml").realpath
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

  # @return [Pathname]
  def out_dir
    build_dir.join('out')
  end

  # @return [Array<Pathname>]
  def builds
    Dir.glob("#{out_dir}/*.AppImage").map do |fp|
      Pathname.new(fp)
    end.sort_by { |fp| File.mtime(fp) }
  end

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
  # Differs depending on docker or raw script execution.
  # ``pkg2appimage``
  def target
    (docker? ? recipe : recipe_file).to_s
  end

  # @return [Pathname]
  def call
    -> { builds }.tap { build(downloadables) }.call.last
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

  # @return [Pathname]
  def recipes_dir
    Pathname.new(config.fetch('recipes_dir'))
  end

  # @raise [ArgumentError]
  def recipe=(recipe)
    @recipe = recipe.to_sym
  end

  # @param [Array<Appifier::Downloadable>] scripts
  def build(scripts) # rubocop:disable Metrics/AbcSize
    build_dir do
      Pathname.new('recipes').join("#{recipe_file.basename('.*')}.yml").tap do |f|
        fs.mkdir_p(f.dirname)
        fs.cp(recipe_file.to_s, f)
      end

      self.logs.transform_values { |v| File.open(v, 'w') }.tap do |options|
        sh(env, scripts.map(&:call).fetch(0).to_s, target, options)
      end
    end
  end
end
