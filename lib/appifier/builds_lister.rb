# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# List builds.
#
# Builds are indexed by name and sorted by mtime.
class Appifier::BuildsLister
  autoload(:Build, "#{__dir__}/builds_lister/build")

  # @param [String] path
  def initialize(path)
    @path = Pathname.new(path).freeze
  end

  # Get builds indexed by name and sorted by mtime.
  #
  # @return [Hash{String => Array<Build>}]
  def call
    {}.tap do |h|
      scan.each do |item|
        h[item.name] = h[item.name].to_a.concat([item])
      end
    end
  end

  def fetch(*args, &block)
    call.fetch(*args, &block)
  end

  protected

  # @return [Pathname]
  attr_reader :path

  def matcher
    %r{^#{Pathname.new(path)}/(.*)-([0-9]+.*).glibc}
  end

  # Get builds sorted by mtime.
  #
  # @api private
  #
  # @return [Array<Build>]
  def scan
    Dir.glob("#{path}/*.AppImage").map { |fp| Pathname.new(fp) }.keep_if do |fp|
      fp.to_s.match(matcher)
    end.sort_by { |fp| File.mtime(fp) }.map do |fp|
      Build.new(*fp.to_s.match(matcher).to_a[1..-1].concat([fp]))
    end
  end
end
