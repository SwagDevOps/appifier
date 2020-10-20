# frozen_string_literal: true

require_relative '../builds_lister'
autoload(:Pathname, 'pathname')

# Describe a build.
class Appifier::BuildsLister::Build
  include Appifier::Mixins::Immutable
  include Appifier::Mixins::Jsonable

  # @return [String]
  attr_reader :name

  # @return [String, nil]
  attr_reader :version

  # @return [Time, nil]
  attr_reader :mtime

  # @return [Appifier::Filesize, nil]
  attr_reader :size

  # @return [Pathname]
  attr_reader :path

  # @param [String] path
  def initialize(path) # rubocop:disable Metrics/MethodLength
    immutable! do
      @path = Pathname.new(path).freeze
      self.class.__send__(:mtime, path).freeze.tap do |mtime|
        @mtime = mtime
        @size = exist? ? Appifier::Filesize.from_path(self.path.to_path) : nil
      end
      extract.tap do |v|
        @name = v.name
        @version = v.version
      end
    end
  end

  # Get detail about build (public instance_variables).
  #
  # @return [Hash{Symbol => Object}]
  def detail
    as_json
  end

  def as_json(*)
    super.tap do |h|
      h.merge!({ size: h.fetch(:size).to_s })
    end
  end

  # Denote version is defined (not null).
  #
  # @return [Boolean]
  def version?
    !version.nil?
  end

  # Denote file exists.
  #
  # @return [Boolean]
  def exist?
    path.exist?
  end

  def mtime?
    !mtime.nil?
  end

  def size?
    !size.nil?
  end

  # @return [String]
  def to_path
    path.to_path
  end

  alias to_s to_path

  protected

  # Denote name and version can be extracted from path.
  #
  # @return [Boolean]
  # @api private
  def extractable?
    !to_s.scan(version_matcher).to_a.empty?
  end

  # @return [Regexp]
  def version_matcher
    %r{^#{path.dirname}/+(.*)-(([0-9]+.*)|).glibc}
  end

  # @return [Struct]
  def extract
    Struct.new(:name, :version).yield_self do |result_struct|
      return result_struct.new(nil, nil) unless extractable?

      to_s.scan(version_matcher).to_a.fetch(0).yield_self do |r|
        result_struct.new(r.fetch(0).freeze, (r[1].to_s.empty? ? nil : r[1].to_s).freeze)
      end
    end
  end

  class << self
    # @api private
    #
    # @param [String] path
    #
    # @return [Time, nil]
    def mtime(path)
      File.mtime(path)
    rescue Errno::ENOENT
      nil
    end
  end
end
