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
      lister: [kwargs[:lister], :'uninstaller.lister']
    }.tap do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
    # @formatter:on
  end

  def call(name)
    # @todo actual implementation
    # lister.call.tap { |res| pp(res) }
  end

  attr_reader :lister
end
