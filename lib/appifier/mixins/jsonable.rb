# frozen_string_literal: true

require_relative '../mixins'
require 'json'
autoload(:DeepDup, 'deep_dup')

# Convert the object to a JSON representation.
#
# Public attributes are visible (through accessors).
module Appifier::Mixins::Jsonable
  # @api private
  module ClassMethods
    # @api private
    STORE = :json_variables

    __send__(:define_method, STORE) { instance_variable_get("@#{STORE}".to_sym).dup }

    protected

    attr_writer STORE

    [:attr_accessor, :attr_reader].each do |method_name|
      module_eval do
        __send__(:define_method, method_name) do |*attrs|
          # noinspection RubySuperCallWithoutSuperclassInspection
          super(*attrs).tap do
            attrs.each do |attr|
              next unless self.allocate.public_methods.include?(attr.to_sym)

              instance_variable_get("@#{STORE}".to_sym).push(*attr)
            end
          end
        end
      end
    end
  end

  class << self
    protected

    def included(othermod)
      super.tap do
        othermod.extend(ClassMethods)
        othermod.__send__("#{ClassMethods::STORE}=", [])
      end
    end
  end

  # @return [Hash{Symbol => Object}]
  def as_json(*)
    {}.tap do |serialized|
      self.class.__send__(ClassMethods::STORE).each do |attr|
        serialized[attr.to_sym] = DeepDup.deep_dup(self.public_send(attr))
      end
    end
  end

  # @see https://ruby-doc.org/stdlib-2.6.3/libdoc/json/rdoc/JSON.html#module-JSON-label-Generating+JSON
  #
  # @return [String]
  def to_json(*args)
    as_json.to_json(*args)
  end
end
