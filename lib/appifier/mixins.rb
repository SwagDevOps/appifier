# frozen_string_literal: true

require_relative '../appifier'

# Mixins namespace.
module Appifier::Mixins
  # @formatter:off
  {
    HashGlob: 'hash_glob',
    Inject: 'inject',
    Immutable: 'immutable',
    Jsonable: 'jsonable',
    Verbose: 'verbose',
  }.each { |s, fp| autoload(s, "#{__dir__}/mixins/#{fp}") }
  # @formatter:on
end
