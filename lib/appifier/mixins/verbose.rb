# frozen_string_literal: true

require_relative '../mixins'

# Verbose behaviour.
module Appifier::Mixins::Verbose
  # @return [Boolean]
  def verbose?
    return !!@verbose unless @verbose.nil?

    (self.respond_to?(:container) ? container : Appifier.container).resolve(:verbose)
  end
end
