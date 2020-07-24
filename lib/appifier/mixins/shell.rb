# frozen_string_literal: true

require_relative '../mixins'
autoload(:Shellwords, 'shellwords')

# # Mixin to expose a wrapper around ``system``.
module Appifier::Mixins::Shell
  protected

  # @raise [RuntimeError]
  #
  # @return [Boolean]
  def sh(*args)
    # @type [Appifier::Shell] shell
    (self.respond_to?(:container) ? container : Appifier.container).resolve(:shell).yield_self do |shell|
      shell.sh(*args)
    end
  end
end
