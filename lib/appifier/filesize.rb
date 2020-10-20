# frozen_string_literal: true

require_relative '../appifier'

# Describe a filesize.
class Appifier::Filesize
  include Appifier::Mixins::Immutable
  include Appifier::Mixins::Jsonable

  # @type [Array<String>]
  UNITS = %w[B KB MB GB TB PB EB].freeze

  # @type [Hash{String => Integer}]
  LIMITS = UNITS.map.with_index(1) { |key, exp| [key.freeze, 1024.pow(exp)] }.to_h.freeze

  # @param [Integer, Float] value
  def initialize(value)
    raise ArgumentError, "Numeric expected, got #{value.class}" unless value.is_a?(Numeric)

    immutable! { @value = value.public_send(value.is_a?(Float) ? :to_f : :to_i) }
  end

  def to_i
    to_f.to_i
  end

  def to_f
    self.value * 1.0
  end

  def to_s
    # noinspection RubyNilAnalysis
    {
      true => -> { stringifier.call(value, LIMITS.values.last) },
      false => lambda do
        LIMITS.values.sort.each { |factor| return stringifier.call(to_f, factor) if to_f < factor }
      end
    }.fetch(to_f >= LIMITS.values.last).call
  end

  class << self
    # Static constructor.
    #
    # @param [String] path
    #
    # @return [Appifier::Filesize]
    def from_path(path)
      File.size(path).yield_self { |value| self.new(value) }
    end
  end

  protected

  # @return [Integer, Float]
  attr_reader :value

  # @return [Proc]
  def stringifier(format: '%.2<value>f %<suffix>s')
    lambda do |value, factor|
      suffixer = ->(cf) { LIMITS.to_a.keep_if { |_, v| v == cf }.fetch(0).fetch(0) }

      format % {
        value: (value * 1.0) / (factor / 1024.0),
        suffix: suffixer.call(factor)
      }
    end
  end
end
