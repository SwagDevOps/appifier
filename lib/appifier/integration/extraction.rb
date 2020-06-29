# frozen_string_literal: true

require_relative '../integration'

autoload(:Pathname, 'pathname')

# Describe an extraction from a given AppImage file (source).
#
# Extraction MUST contain a valid desktop file and an icon.
class Appifier::Integration::Extraction < Pathname
  include(Appifier::Shell)

  # @return [Pathname]
  attr_reader :source

  def initialize(source, verbose: false)
    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose
    @extracted = false
    @source = Pathname.new(source).realpath.freeze

    self.class.__send__(:mkdir, verbose: verbose?).tap { |tmpdir| super(tmpdir) }
  end

  def verbose?
    @verbose
  end

  # Denote extraction is done.
  #
  # @return [Boolean]
  def extracted?
    @extracted
  end

  # Extracted (unless done) and execute given block.
  def call(&block)
    unless extracted?
      Dir.chdir(self) do
        %w[*.desktop .DirIcon *.png *.svg].each do |target|
          sh(source.realpath.to_s, '--appimage-extract', target)
        end
      end
    end

    block&.call
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

  class << self
    protected

    # @return [Pathname]
    def mkdir(verbose: false)
      require 'tmpdir'

      Pathname.new(Dir.mktmpdir("#{self.name.gsub('::', '-')}.", Dir.tmpdir)).tap do |tmpdir|
        warn("mkdir #{tmpdir}") if verbose
      end
    end
  end
end
