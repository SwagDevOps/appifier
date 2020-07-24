# frozen_string_literal: true

require_relative '../mixins'
autoload(:Shellwords, 'shellwords')

# Mixin to expose printer.
module Appifier::Mixins::Printer
  protected

  # @return [Appifier::JsonPrinter]
  def printer
    (self.respond_to?(:container) ? container : Appifier.container).resolve(:printer)
  end
end
