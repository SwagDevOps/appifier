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
#
# It can avoid ``SystemStackError`` (resive) error when ``#immutable`` is called from ``#freeze``.
#
# As a result, ``#immutable`` SHOULD be callable from ``#frezze``:
#
# ```ruby
# class Foo
#   include(Immutable)
#
#   attr_reader :value
#   attr_reader :time
#
#   def initialize(val)
#     @value = 42
#     @time = Time.new
#   end
#
#   def freeze
#     -> { super }.tap { immutable }
#   end
# end
module Appifier::Mixins::Immutable
  class << self
    def included(othermod)
      caller_locations[0]&.tap { |location| register(othermod, location) }

      super
    end

    # @param [Class] klass
    # @param [Thread::Backtrace::Location. String] location
    #
    # @return [Hash{Symbol => String}]
    def register(klass, location)
      self.instance_eval('@origins ||= {}', __FILE__, __LINE__)

      -> { self.origins.dup }.tap do
        { klass.name.to_sym => (location.is_a?(String) ? location : location.path).freeze }.yield_self do |h|
          @origins = self.origins.dup.merge(h).compact.freeze
        end
      end.call
    end

    # Denote given object (from given optional location) has been registered.
    #
    # @api private
    #
    # @param [Class] klass
    # @param [Thread::Backtrace::Location, nil, String] location
    #
    # @return [Boolean]
    def registered?(klass, location: nil)
      klass.name.to_sym.yield_self do |key|
        return self.origins.key?(key) if location.nil?

        self.origins.key?(key) and (location.is_a?(String) ? location : location.path) == origins[key]
      end
    end

    protected

    # Get call origin paths indexed by class symbols.
    #
    # @api private
    #
    # @return [Hash{Symbol => String}]
    attr_reader :origins
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

  protected

  # Freeze instance and attributes.
  #
  # @return [self]
  def immutable(&block)
    caller_locations.yield_self do |locations|
      self.tap do
        block&.call
        [:variables, :instance].each { |key| immutable_freezers[key].call(locations) }
      end
    end
  end

  # @raise [RuntimeError]
  #
  # @return [self]
  def immutable!(&block)
    immutable(&block).tap do |instance|
      return instance if instance.immutable?

      raise "object (#{self.object_id}) is not immutable"
    end
  end

  # Get freezers.
  #
  # @return [Hash{Symbol => Proc}]
  def immutable_freezers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    {
      instance: lambda do |locations, instance = self|
        Appifier::Mixins::Immutable.yield_self do |matcher|
          locations.keep_if do |location|
            matcher.registered?(instance.class, location: location)
          end.map { |location| location.label.to_s.freeze }.yield_self do |labels|
            return labels.include?('freeze') ? false : !!instance.freeze
          end
        end
      end,
      variables: lambda do |_, instance = self|
        instance_variables.each { |sym| instance.instance_eval("#{sym}.freeze", __FILE__, __LINE__) }

        self.immutable?
      end
    }
  end
end
