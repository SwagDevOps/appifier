# frozen_string_literal: true

require_relative '../mixins'

# Convert the object to its JSON representation.
module Appifier::Mixins::Jsonable
  class << self
    protected

    def included(othermod)
      super

      require 'json'
    end
  end

  # @see https://ruby-doc.org/stdlib-2.6.3/libdoc/json/rdoc/JSON.html#module-JSON-label-Generating+JSON
  #
  # @return [String]
  def to_json(*args)
    super(*args)
  end
end
