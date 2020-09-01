# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# Mixins namespace.
module Appifier::Scripts
  # @formatter:off
  {
    Downloadables: 'downloadables',
    Runner: 'runner',
    Sequence: 'sequence',
  }.each { |s, fp| autoload(s, "#{__dir__}/scripts/#{fp}") }
  # @formatter:on
end
