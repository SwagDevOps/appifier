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

  # rubocop:disable Metrics/AbcSize

  def initialize(source, target, parameters:, **kwargs)
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
  # rubocop:enable Metrics/AbcSize

  # Extracted files path.
  #
  # @return [Extraction]
  attr_reader :extraction

  # @return [Array<Pathname>]
  def call
    # noinspection RubyYardReturnMatch
    prepared do |dir|
      # @formatter:off
      [
        make_desktop(dir),
        make_icon(dir),
        make_executable(dir, source),
        symlimk_desktop(dir),
        symlimk_executable(dir),
      ].flatten.compact
      # @formatter:on
    end.tap { clean }
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

  # rubocop:disable Metrics/AbcSize

  def prepared(&block)
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
  # rubocop:enable Metrics/AbcSize

  def clean
    extraction&.tap { |dir| fs.rm_rf(dir) }
  end

  def make_executable(dir, executable)
    [executable, dir.join('app')].tap do |args|
      fs.ln(*args)
    rescue Errno::EXDEV
      fs.cp(*args)
    end
  end

  # rubocop:disable Metrics/AbcSize

  # @return [Arry<Pathname>]
  def make_icon(dir)
    dir.join('.icon').yield_self do |icon_link|
      dir.join("icon#{extraction.icon.extname}").tap do |icon_path|
        fs.cp(extraction.icon, icon_path)
        fs.ln_sf(icon_path, dir.join('.icon'))
      rescue RuntimeError => e
        warn(e.message)
      end

      apply_icon(dir, icon_link)

      [icon_link, icon_link.realpath].map(&:freeze).freeze
    end
  end
  # rubocop:enable Metrics/AbcSize

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

  # rubocop:disable Metrics/AbcSize

  # Create symlimk for application desktop.
  #
  # use ``integration.desktop.created = false`` to disable desktop symlink creation.
  #
  # @return [Array<Pathname>, nil]
  def symlimk_desktop(dir)
    (parameters['desktop']&.fetch('name', nil) || extraction.desktop.basename('.desktop')).yield_self do |name|
      config.fetch('desktops_dir').join("#{name}.desktop").yield_self do |desktop_file|
        return nil if parameters['desktop']&.fetch('disabled', false)

        fs.mkdir_p(desktop_file.dirname)
        [dir.join('app.desktop'), desktop_file].tap { |result| fs.ln_sf(*result) }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # @return [Array<Pathname>]
  def symlimk_executable(dir)
    config.fetch('bin_dir').yield_self do |target_dir|
      fs.mkdir_p(target_dir)

      [dir.join('app'), target_dir.join(parameters.fetch('executable'))].tap do |result|
        fs.ln_sf(*result)
      end
    end
  end
end
