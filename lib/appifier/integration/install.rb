# frozen_string_literal: true

require_relative '../integration'

# Describe an install, from a given source to a given directory (target).
class Appifier::Integration::Install
  autoload(:FileUtils, 'fileutils')
  autoload(:Pathname, 'pathname')

  include(Appifier::Shell)

  def initialize(source, target, parameters:, config: Appifier::Config.new, verbose: false)
    @parameters = parameters.to_h.freeze
    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose
    @fs = verbose ? FileUtils::Verbose : FileUtils
    @source = Pathname.new(source).realpath.freeze
    @target = Pathname.new(target).freeze
    @config = config
  end

  # Extracted files path.
  #
  # @return [Extraction]
  def extraction
    @extraction ||= Appifier::Integration::Extraction.new(source, verbose: verbose?)
  end

  def call
    prepared do |dir|
      make_icon(dir).tap { |icon| make_desktop(dir, icon) }
      make_executable(dir, source)
      symlimk_desktop(dir)
      symlimk_executable(dir)
    end
  end

  def verbose?
    @verbose
  end

  protected

  # @return [Hash]
  attr_reader :parameters

  attr_reader :fs

  # @return [Pathname]
  attr_reader :source

  # @return [Pathname]
  attr_reader :target

  attr_reader :config

  def prepared(&block)
    target.tap do |dir|
      if block
        fs.rm_rf(dir)
        fs.mkdir_p(dir)

        return block.call(dir)
      end
    end
  end

  def make_executable(dir, executable)
    fs.ln(executable, dir.join('app'))
  rescue Errno::EXDEV
    fs.cp(executable, dir.join('app'))
  end

  # @return [Pathname]
  def make_icon(dir)
    dir.join("icon#{extraction.icon.extname}").tap do |dir_icon|
      fs.cp(extraction.icon, dir_icon)
      begin
        sh('gio', 'set', dir.to_s, '-t', 'string', 'metadata::custom-icon', "file://#{dir_icon}")
      rescue RuntimeError => e
        warn(e) unless verbose?
      end
    end
  end

  # Return path to installed desktop.
  #
  # @return [Pathname]
  def make_desktop(dir, icon)
    Appifier::Integration::Desktop.new(extraction.desktop).yield_self do |desktop|
      desktop.alter(dir: dir, icon: icon, exec_params: parameters.fetch('exec_params')).yield_self do |content|
        return dir.join("#{parameters.fetch('name')}.desktop").tap { |file| file.write(content) }
      end
    end
  end

  def symlimk_desktop(dir)
    config.fetch('desktops_dir').yield_self do |target_dir|
      fs.mkdir_p(target_dir)
      fs.ln_sf(dir.join("#{parameters.fetch('name')}.desktop"), target_dir)
    end
  end

  def symlimk_executable(dir)
    config.fetch('bin_dir').yield_self do |target_dir|
      fs.mkdir_p(target_dir)
      fs.ln_sf(dir.join('app'), target_dir.join(parameters.fetch('executable')))
    end
  end
end
