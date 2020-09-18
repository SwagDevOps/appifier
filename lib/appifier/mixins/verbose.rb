# frozen_string_literal: true

require_relative '../mixins'

# Verbose behaviour.
module Appifier::Mixins::Verbose
  # Use ``Appifier.container`` except when a ``verbose`` method is present.
  #
  # @return [Boolean]
  def verbose?
    (self.methods + self.private_methods).map(&:to_sym).include?(:verbose).yield_self do |b|
      # @formatter:off
      {
        true => -> { self.__send__(:verbose) },
        false => -> { Appifier.container.resolve(:verbose) }
      }.fetch(b).call.yield_self { |result| !!result }
      # @formatter:on
    end
  end
end
