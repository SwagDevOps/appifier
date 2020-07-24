# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# List builds.
#
# Builds are indexed by name and sorted by mtime.
class Appifier::BuildsLister
  def initialize(path)
    @path = Pathname.new(path).freeze
  end

  # @return [Hash{String => Array<Build>}]
  def call
    {}.tap do |h|
      scan.each do |item|
        h[item.name] = h[item.name].to_a.concat([item])
      end
    end
  end

  # Describe a build.
  class Build
    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :version

    # @return [Time]
    attr_reader :mtime

    # @return [Pathname]
    attr_reader :path

    def initialize(name, version, path)
      self.tap do
        @name = name
        @version = version
        @path = Pathname.new(path).freeze
        @mtime = File.mtime(self.path)
      end.freeze
    end

    def to_path
      path.to_path
    end
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
