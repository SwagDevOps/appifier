# frozen_string_literal: true

require_relative '../appifier'

# List builds.
#
# Builds are indexed by name and sorted by mtime.
class Appifier::Uninstaller
  # @formatter:off
  {
    Lister: 'lister',
  }.each { |s, fp| autoload(s, "#{__dir__}/uninstaller/#{fp}") }
  # @formatter:on

  include(Appifier::Mixins::Inject)

  def initialize(**kwargs)
    # @formatter:off
    {
      fs: kwargs[:fs],
      lister: [kwargs[:lister], :'uninstaller.lister']
    }.tap do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
    # @formatter:on
  end

  def call(pattern)
    lister.call.glob(pattern).tap do |result|
      result.map { |_, v| v }.flatten.each do |fp|
        fs.public_send("rm_#{fp.directory? ? :r : nil}f", fp)
      end
    end
  end

  protected

  # @return [Appifier::FileSystem]
  # @return [FileUtils]
  attr_reader :fs

  # @return [Appifier::Uninstaller::Lister]
  attr_reader :lister
end
