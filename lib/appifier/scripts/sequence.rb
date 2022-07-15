# frozen_string_literal: true

require_relative '../scripts'

# Represent a sequence to be executed by a runner.
#
# @see Appifier::Scripts::Runner
class Appifier::Scripts::Sequence < ::Array
  # fist item is actual executable script
  #
  # @api private
  # @see Appifier::Scripts::Runner#call
  #
  # @type [Hash{Boolean => Array<Symbol>}]
  SCRIPTS = {
    true => [:Pkg2appimageWithDocker, :Dockerfile, :Pkg2appimage, :FunctionsSh, :ExcludeList],
    false => [:Pkg2appimage, :FunctionsSh, :ExcludeList]
  }.freeze

  class << self
    # Get an array of downloaded scripts.
    #
    # @return [Array<Appifier::DownloadableString>]
    def call(docker)
      self.new(docker).start
    end
  end

  # @param [Boolean] docker
  def initialize(docker)
    super()

    SCRIPTS.fetch(docker).each do |sym|
      resolve(sym).tap { |klass| self.push(klass) }
    end
  end

  # Initialize all strings (and download them as files).
  #
  # @return [Array<Appifier::DownloadableString>]
  def start
    self.map { |klass| klass.new.tap(&:call) }.freeze
  end

  protected

  # Resolve given name as a ``DownloadableString``.
  #
  # @return [Class<Appifier::DownloadableString>]
  def resolve(name)
    Appifier::Scripts::Downloadables.const_get(name.to_sym)
  end
end
