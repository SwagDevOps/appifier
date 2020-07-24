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
