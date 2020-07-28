# frozen_string_literal: true

require_relative '../integration'
autoload(:Pathname, 'pathname')
autoload(:SecureRandom, 'securerandom')

# Describe an extraction from a given AppImage file (source).
#
# Extraction MUST contain a valid desktop file and an icon.
class Appifier::Integration::Extraction < Pathname
  include(Appifier::Mixins::Inject)
  include(Appifier::Mixins::Verbose)

  # @return [String]
  # @return [String]
  attr_reader :name

  # @return [Pathname]
  attr_reader :source

  # @return [Array<String>]
  attr_reader :extractables

  def initialize(source, name:, **kwargs)
    inject({ logged_runner: kwargs[:logged_runner] }).assert { !values.include?(nil) }

    @name = name.to_s
    @source = Pathname.new(source).realpath.freeze
    @extractables = %w[*.desktop .DirIcon *.svg *.png].map(&:freeze).freeze

    self.class.__send__(:mkdir, verbose: verbose?).tap { |tmpdir| super(tmpdir).freeze }
  end

  # Extracted (unless done) and execute given block.
  def call(&block)
    block.tap do
      Dir.chdir(self) do
        extractables.each do |target|
          next if extracted?(target)

          [source.realpath.to_s, '--appimage-extract', target].tap do |command|
            logged_runner.call({ self.name => [command] })
          end
        end
      end
    end.call
  end

  # Get path to desktop file.
  #
  # @return [Pathname]
  def desktop
    call do
      Dir.glob(self.join('squashfs-root', '*.desktop')).fetch(0).yield_self do |fp|
        Pathname.new(fp).realpath.freeze
      end
    end
  end

  # Get path to icon file.
  #
  # @return [Pathname]
  def icon
    call do
      self.join('squashfs-root', '.DirIcon').realpath.freeze
    end
  end

  protected

  # Denote given pattern is already extracted.
  #
  # @return [Boolean]
  def extracted?(target)
    false.tap do
      Dir.chdir(self) do
        return true unless Dir.glob("squashfs-root/#{target}").empty?

        return true if %w[.png .svg].include?(File.extname(target.to_s)) and File.file?('squashfs-root/.DirIcon')
      end
    end
  end

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner

  class << self
    # @api private
    #
    # @return [Pathname]
    def mkdir(verbose: false)
      require 'tmpdir'

      [name.gsub('::', ''), SecureRandom.hex].join('.').yield_self do |dirname|
        Pathname.new(Dir.tmpdir).join(dirname).tap do |tmpdir|
          (verbose ? FileUtils::Verbose : FileUtils).mkdir(tmpdir)
        end
      end
    end
  end
end
