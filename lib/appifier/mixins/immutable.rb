# frozen_string_literal: true

require_relative '../mixins'

# Frozen object.
#
# Sample of use:
#
# ```ruby
# class Foo
#   include(Immutable)
#
#   attr_reader :value
#   attr_reader :time
#
#   def initialize(val)
#     immutable do
#       @value = 42
#       @time = Time.new
#     end
#   end
# end
#
# sample = Foo.new
# sample.immutable?
# # true
# sample.value.frozen?
# # true
# sample.time.frozen?
# # true
# ```
module Appifier::Mixins::Immutable
  # Freeze instance and attributes.
  #
  # @return [self]
  def immutable(&block)
    self.tap do
      block&.call
      instance_variables.each { |sym| self.instance_eval("#{sym}.freeze", __FILE__, __LINE__) }
      freeze
    end
  end

  # Denote instance is immutable.
  #
  # @return [Boolean]
  def immutable?
    # @formatter:off
    instance_variables
      .map { |sym| self.instance_eval("#{sym}.frozen?", __FILE__, __LINE__) }
      .tap { |res| return [self.frozen?].concat(res).uniq == [true] }
    # @formatter:on
  end
end
