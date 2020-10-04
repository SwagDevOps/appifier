# frozen_string_literal: true

require_relative '../appifier'

# Uninstaller
#
# Installations are retrievd by symlinks pointing to application directory.
#
# @see Appifier::Uninstaller::Lister
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
      lister: [kwargs[:lister], :'uninstaller.lister'],
      desktop_database_updater: kwargs[:desktop_database_updater],
    }.tap do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
    # @formatter:on
  end

  # @param [String] pattern
  #
  # @return [Hash{String => Array}, nil]
  # @return [Hash]
  def call(pattern)
    lister.call.glob(pattern).tap do |result|
      result.map { |_, v| v }.flatten.each do |fp|
        fs.public_send("rm_#{fp.directory? ? :r : nil}f", fp)
      end
    end.tap do |result|
      desktop_database_updater.call unless result.empty?

      return nil if result.empty?
    end
  end

  protected

  # @return [Appifier::FileSystem]
  # @return [FileUtils]
  attr_reader :fs

  # @return [Appifier::Uninstaller::Lister]
  attr_reader :lister

  # @return [Appifier::DesktopDatabaseUpdater]
  attr_reader :desktop_database_updater
end
