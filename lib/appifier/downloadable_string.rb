# frozen_string_literal: true

require_relative '../appifier'
autoload(:URI, 'uri')
autoload(:Pathname, 'pathname')

# Describe a dowloadable text file.
#
# @abstract
class Appifier::DownloadableString < String
  include(Appifier::Mixins::Inject)
  include(Appifier::Mixins::Verbose)

  def initialize(**kwargs)
    # @formatter:off
    {
      fs: kwargs[:fs],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

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

    # Replacements to apply on content.
    #
    # @return [Hash{Regex|String => String}]
    def replacements
      {}
    end

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
      URI.parse(url).yield_self do |uri|
        (uri.scheme == 'file' ? Pathname.new(uri.path).read : Net::HTTP.get(uri)).tap do |content|
          replacements.each { |k, v| content.gsub!(k, v) }
        end
      end
    end
  end

  # @return [String]
  def url
    self.class.url
  end

  # Denote resulting file is supposed to be executable.
  #
  # @return [Boolean]
  def executable?
    self.class.executable?
  end

  def to_path
    Pathname.new(Dir.pwd).join(Pathname.new(self.url).basename.to_s).to_s
  end

  # @return [Pathname]
  def call
    Pathname.new(to_path).tap do |f|
      f.write(self.to_s)
    end.tap do |f|
      fs.chmod(0o755, f) if executable?
    end
  end

  protected

  # @return [Appifier::FileSystem]
  # @return [FileUtils]
  attr_reader :fs
end
