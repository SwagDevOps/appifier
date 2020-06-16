# frozen_string_literal: true

require_relative '../appifier'

# Describe a dowloadable text file.
class Appifier::DownloadableString < String
  autoload(:Pathname, 'pathname')
  autoload(:FileUtils, 'fileutils')

  def initialize(verbose: false)
    require 'net/http'

    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose
    self.fs = (verbose ? FileUtils::Verbose : FileUtils)

    warn("curl #{url}") if verbose?
    Net::HTTP.get(uri).yield_self { |s| super(s) }
  end

  class << self
    def url
      ''
    end

    def executable?
      false
    end
  end

  # @return [String]
  def url
    self.class.url
  end

  # @return [URI]
  def uri
    URI.parse(self.url)
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
