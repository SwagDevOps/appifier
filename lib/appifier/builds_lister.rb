# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# List builds.
#
# Builds are indexed by name and sorted by mtime.
class Appifier::BuildsLister
  # @formatter:off
  {
    Build: 'build',
    ScanResult: 'scan_result',
  }.each { |s, fp| autoload(s, "#{__dir__}/builds_lister/#{fp}") }
  # @formatter:on

  # @param [String] path
  def initialize(path)
    @path = Pathname.new(path).freeze
  end

  # Get builds indexed by name and sorted by mtime.
  #
  # @return [ScanResult]
  # @return [Hash{String => Array<Build>}]
  def call
    ScanResult.new(scan)
  end

  def fetch(*args, &block)
    call.fetch(*args, &block)
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # Get builds sorted by mtime.
  #
  # @api private
  #
  # @return [Array<Build>]
  def scan
    Dir.glob("#{path}/*.AppImage").map { |fp| Build.new(fp) }.keep_if(&:version?).sort_by(&:mtime)
  end
end
