# frozen_string_literal: true

require_relative '../appifier'

# Integration
class Appifier::Integration
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')
  autoload(:Desktop, "#{__dir__}/integration/desktop")

  include(Appifier::Shell)
  include(Appifier::Inflector)

  def initialize(app_dir, out_dir, config: Appifier::Config.new, recipe: nil, verbose: false, install: false) # rubocop:disable Metrics/ParameterLists
    @app_dir = Pathname.new(app_dir).realpath.freeze
    @out_dir = Pathname.new(out_dir).realpath.freeze
    @recipe = recipe.freeze
    @fs = verbose ? FileUtils::Verbose : FileUtils
    @config = config
    # noinspection RubySimplifyBooleanInspection
    @installable = !!install
  end

  def installable?
    @installable
  end

  # return [Pathname]
  def call
    builds.last.tap do |build|
      install(build) if installable?
    end
  end

  def name
    desktop.entry.fetch('Name')
  end

  # @return [Pathname]
  def desktop
    Desktop.new(app_dir)
  end

  # Files to remove in case of failure.
  #
  # @todo handle exception and clenup before crash
  # @see #install
  #
  # @return [Array<Pathname>]
  def cleanables
    # @formatter:off
    [
      config.fetch('applications_dir').join(name),
    ]
    # @formatter:on
  end

  # Get matching builds sorted by mtime.
  #
  # @return [Array<Pathname>]
  def builds
    Dir.glob("#{out_dir}/*.AppImage").map { |fp| Pathname.new(fp) }.keep_if do |fp|
      /^#{out_dir.join(name)}-[0-9]+.[0-9]+.[0-9]+/.yield_self do |reg|
        fp.to_s.match(reg)
      end
    end.sort_by { |fp| File.mtime(fp) }
  end

  # Read YAML ``integration`` section.
  #
  # @return [Hash{String => Object}]
  def integration
    recipe.to_h.fetch('integration')
  end

  protected

  # @return [nil|Appifier::Recipe]
  attr_reader :recipe

  # @return [Pathname]
  attr_reader :app_dir

  # @return [Pathname]
  attr_reader :out_dir

  # @return [Class<FileUtils>]
  attr_reader :fs

  # @return [Appifier::Config]
  attr_reader :config

  def app(&block)
    config.fetch('applications_dir').join(name).tap do |dir|
      if block
        fs.rm_rf(dir)
        fs.mkdir_p(dir)

        return block.call(dir)
      end
    end
  end

  def install(build)
    app do |dir|
      make_executable(dir, build)
      make_icon(dir).tap { |icon| make_desktop(dir, icon) }
      symlimk_desktop(dir)
      symlimk_executable(dir)
    end
  end

  def make_executable(dir, executable)
    fs.ln(executable, dir.join('app'))
  rescue Errno::EXDEV
    fs.cp(executable, dir.join('app'))
  end

  # @return [Pathname]
  def make_icon(dir)
    app_dir.join(integration.fetch('icon')).yield_self do |origin_icon|
      dir.join("icon#{origin_icon.extname}").tap do |dir_icon|
        fs.cp(origin_icon, dir_icon)
        begin
          sh('gio', 'set', dir.to_s, '-t', 'string', 'metadata::custom-icon', "file://#{dir_icon}")
        rescue RuntimeError => e
          warn(e)
        end
      end
    end
  end

  # Return path to installed desktop.
  #
  # @return [Pathname]
  def make_desktop(dir, icon)
    desktop.alter(dir: dir, icon: icon, exec_params: integration.fetch('exec_params', [])).yield_self do |content|
      return dir.join("#{name}.desktop").tap { |file| file.write(content) }
    end
  end

  def symlimk_desktop(dir)
    config.fetch('desktops_dir').yield_self do |target_dir|
      fs.mkdir_p(target_dir)
      fs.ln_sf(dir.join("#{name}.desktop"), target_dir)
    end
  end

  def symlimk_executable(dir)
    config.fetch('bin_dir').yield_self do |target_dir|
      fs.mkdir_p(target_dir)
      fs.ln_sf(dir.join('app'), target_dir.join(integration.fetch('executable', name.downcase)))
    end
  end
end
