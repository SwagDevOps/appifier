# frozen_string_literal: true

require_relative '../integration'

# Describe a list of builds.
#
# Builds are indexed by version.
class Appifier::Integration::BuildsList < Hash
  autoload(:Pathname, 'pathname')

  def initialize(path, name)
    @path = Pathname.new(path)
    @name = name.to_s

    scan.each { |k, v| self[k] = v }
  end

  def to_path
    @path.to_path
  end

  protected

  # @return [String]
  attr_reader :name

  # @return [Pathname]
  attr_reader :path

  def matcher
    /^#{Pathname.new(to_path).join(name)}-(.*).glibc/
  end

  # Get builds sorted by mtime.
  #
  # @api private
  #
  # @return [Hash<String => Pathname>]
  def scan
    Dir.glob("#{to_path}/*.AppImage").map { |fp| Pathname.new(fp) }.keep_if do |fp|
      fp.to_s.match(matcher)
    end.sort_by { |fp| File.mtime(fp) }.map do |fp|
      [fp.to_s.match(matcher).to_a.fetch(1), fp]
    end.to_h
  end
end
