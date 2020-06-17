# frozen_string_literal: true

require_relative '../appifier'

# Describe a dowloadable text file.
#
# @abstract
class Appifier::DownloadableString < String
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')

  def initialize(verbose: false)
    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose

    self.fs = (verbose? ? FileUtils::Verbose : FileUtils)
    self.class.__send__(:fetch, self.url, verbose: verbose?).tap { |s| super(s) }
  end

  class << self
    # @return [String]
    def url
      raise 'Not implemented'
    end

    # Denote dowload will be executable or not.
    #
    # Default do ``false``
    #
    # @return [Boolean]
    def executable?
      false
    end

    protected

    autoload(:URI, 'uri')

    # Fetch given url to string.
    #
    # @api private
    #
    # @param [String] url
    #
    # @return [String]
    def fetch(url, verbose: true)
      require 'net/http'

      warn("curl #{url}") if verbose

      URI.parse(url).yield_self { |uri| Net::HTTP.get(uri) }
    end
  end

  # @return [String]
  def url
    self.class.url
  end

  def verbose?
    @verbose
  end

  def executable?
    self.class.executable?
  end

  # @return [Pathname]
  def call
    Pathname.new(Dir.pwd).join(Pathname.new(self.url).basename.to_s).tap do |f|
      f.write(self.to_s)
    end.tap do |f|
      fs.chmod(0o755, f) if executable?
    end
  end

  protected

  attr_accessor :fs
end
