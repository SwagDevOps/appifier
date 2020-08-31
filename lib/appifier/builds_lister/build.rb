# frozen_string_literal: true

require_relative '../builds_lister'
autoload(:Pathname, 'pathname')

# Describe a build.
class Appifier::BuildsLister::Build
  # @return [String]
  attr_reader :name

  # @return [String]
  attr_reader :version

  # @return [Time]
  attr_reader :mtime

  # @return [Pathname]
  attr_reader :path

  def initialize(path)
    self.tap do
      @path = Pathname.new(path).freeze
      @mtime = File.mtime(self.path)
      extract.tap do |v|
        @name = v.name
        @version = v.version
      end
    end.freeze
  end

  def version?
    !version.nil?
  end

  def to_path
    path.to_path
  end

  alias to_s to_path

  def to_json(*_)
    to_path.inspect
  end

  protected

  # @return [Regexp]
  def version_matcher
    %r{^#{path.dirname}/(.*)-([0-9]+.*).glibc}
  end

  # @return [Struct]
  def extract
    to_s.scan(version_matcher).to_a.fetch(0).yield_self do |r|
      Struct.new(:name, :version).new(r.fetch(0), r[1])
    end
  end
end
