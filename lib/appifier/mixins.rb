# frozen_string_literal: true

require_relative '../appifier'

# Mixins namespace.
module Appifier::Mixins
  # @formatter:off
  {
    Fs: 'fs',
    HashGlob: 'hash_glob',
    Inject: 'inject',
    Jsonable: 'jsonable',
    Shell: 'shell',
    Verbose: 'verbose',
  }.each { |s, fp| autoload(s, "#{__dir__}/mixins/#{fp}") }
  # @formatter:on
end
