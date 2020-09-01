# frozen_string_literal: true

require_relative '../scripts'

# Represent a sequence to be executed by a runner.
#
# @see Appifier::Scripts::Runner
class Appifier::Scripts::Sequence < ::Array
  # fist item is actual executable script
  #
  # @api private
  SCRIPTS = { # @formatter:off
    true => [:Pkg2appimageWithDocker, :Dockerfile, :Pkg2appimage, :FunctionsSh],
    false => [:Pkg2appimage, :FunctionsSh]
  }.freeze
  # @formatter:on

  # @param [Boolean] docker
  def initialize(docker)
    SCRIPTS.fetch(docker).each do |sym|
      Appifier::Scripts::Downloadables.const_get(sym).tap do |klass|
        self.push(klass)
      end
    end
  end

  # Initialize all strings (and download them as files).
  #
  # @return [Array<Appifier::DownloadableString>]
  def start
    self.map { |klass| klass.new.tap(&:call) }.freeze
  end
end
