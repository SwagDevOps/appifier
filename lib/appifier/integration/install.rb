# frozen_string_literal: true

require_relative '../integration'
autoload(:FileUtils, 'fileutils')
autoload(:Pathname, 'pathname')
autoload(:SecureRandom, 'securerandom')

# Describe an install, from a given source to a given directory (target).
class Appifier::Integration::Install
  autoload(:DesktopBuilder, "#{__dir__}/install/desktop_builder")

  include(Appifier::Mixins::Fs)
  include(Appifier::Mixins::Inject)

  def initialize(source, target, parameters:, **kwargs) # rubocop:disable Metrics/AbcSize
    # @formatter:off
    {
      config: kwargs[:config],
      logged_runner: kwargs[:logged_runner],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

    @parameters = parameters.to_h.freeze
    @source = Pathname.new(source).realpath.freeze
    @target = Pathname.new(target).freeze
    @backup = Pathname.new(target).dirname.join(".#{target.basename}.#{SecureRandom.hex}").freeze
    # set extraction ----------------------------------------------------------
    @extraction = Appifier::Integration::Extraction.new(source, name: parameters.fetch('logname'))
  end

  # Extracted files path.
  #
  # @return [Extraction]
  attr_reader :extraction

  def call
    prepared do |dir|
      dir.tap do
        make_desktop(dir)
        make_icon(dir)

        make_executable(dir, source)
        symlimk_desktop(dir)
        symlimk_executable(dir)
        clean
      end
    end
  end

  protected

  # @return [Hash]
  attr_reader :parameters

  # AppImage source.
  #
  # @return [Pathname]
  attr_reader :source

  # Install directory.
  #
  # @return [Pathname]
  attr_reader :target

  # Backup directory.
  #
  # @return [Pathname]
  attr_reader :backup

  attr_reader :config

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner

  def prepared(&block) # rubocop:disable Metrics/AbcSize
    target.tap do |dir|
      (fs.mv(dir, backup) if dir.exist?).tap { fs.mkdir_p(dir) }

      begin
        return block.call(dir).tap { fs.rm_rf(backup) }
      rescue StandardError, SignalException => _e
        fs.rm_rf(dir).tap { fs.mv(backup, dir) if backup.exist? }

        raise
      end
    end
  end

  def clean
    extraction&.tap { |dir| fs.rm_rf(dir) }
  end

  def make_executable(dir, executable)
    fs.ln(executable, dir.join('app'))
  rescue Errno::EXDEV
    fs.cp(executable, dir.join('app'))
  end

  # @return [Pathname]
  def make_icon(dir)
    dir.join('.icon').tap do |icon_link|
      dir.join("icon#{extraction.icon.extname}").tap do |icon_path|
        fs.cp(extraction.icon, icon_path)
        fs.ln_sf(icon_path, dir.join('.icon'))
      rescue RuntimeError => e
        warn(e.message)
      end

      apply_icon(dir, icon_link)
    end
  end

  # Apply given icon on given directory.
  #
  # @see https://www.commandlinux.com/man-page/man1/gvfs-set-attribute.1.html
  # @see https://www.mankier.com/1/gio#set
  def apply_icon(dir, icon_path)
    ['gio', 'set', dir.to_s, '-t', 'string', 'metadata::custom-icon', "file://#{icon_path}"].tap do |command|
      logged_runner.call(parameters.fetch('logname') => [command])
    end
  rescue RuntimeError => e
    warn(e) unless verbose?
  end

  # Return path to installed desktop.
  #
  # @return [Pathname]
  def make_desktop(dir)
    DesktopBuilder.new(extraction.desktop.to_s, dir.to_s, parameters: parameters, config: config).call
  end

  def symlimk_desktop(dir)
    (parameters['desktop']&.fetch('name', nil) || extraction.desktop.basename('.desktop')).tap do |name|
      config.fetch('desktops_dir').yield_self do |target_dir|
        fs.mkdir_p(target_dir)

        return fs.ln_sf(dir.join('app.desktop'), target_dir.join("#{name}.desktop"))
      end
    end
  end

  def symlimk_executable(dir)
    config.fetch('bin_dir').yield_self do |target_dir|
      fs.mkdir_p(target_dir)
      fs.ln_sf(dir.join('app'), target_dir.join(parameters.fetch('executable')))
    end
  end
end
