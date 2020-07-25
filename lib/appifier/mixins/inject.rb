# frozen_string_literal: true

require_relative '../mixins'

# Inject behaviour.
#
# Sample of use:
#
# ```ruby
# class Example
#   include(Inject)
#
#   def initialize(flagged: true, dep1: nil, dep2: nil)
#     inject(dep1: dep1, dep2: [dep2, :'utils.something'])
#
#     @flagged = flagged
#   end
#
#   def flagged?
#     @flagged == true
#   end
#
#   protected
#
#   attr_reader :dep1, :dep2
# end
# ```
module Appifier::Mixins::Inject
  protected

  # Inject instance variables.
  #
  # @return [Hash{Symbol => Object}]
  def inject(**definition) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    (self.respond_to?(:container) ? self.container : Appifier.container).yield_self do |container|
      definition.map do |k, v|
        [k.to_sym, v.is_a?(Array) ? v : [v, k.to_sym]].tap { |r| r[1].fetch(1, r[0]) }
      end.map do |var_name, v|
        # @formatter:off
        [
          var_name,
          (v[0].nil? ? container[v.fetch(1)] : v[0]).yield_self do |value|
            instance_variable_set("@#{var_name}", value) if instance_variable_get("@#{var_name}").nil?
          end
        ]
        # @formatter:on
      end.to_h.tap do |h|
        h.instance_eval do # @todo improve assert method with better exception + class
          def assert(&condition)
            sourcifier = lambda do |proc|
              fp = proc.source_location.fetch(0)
              line = proc.source_location.fetch(1)
              code = IO.readlines(fp)[line - 1]

              code[code.index('{')..code.length].strip
            end

            self.tap { raise sourcifier.call(condition) unless instance_eval(&condition) }
          end
        end
      end
    end
  end
end
