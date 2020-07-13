# frozen_string_literal: true

autoload(:OpenStruct, 'ostruct')

# Generic struct (ala OpenStruct)
class FactoryStruct < OpenStruct
  # @param [Hash] input
  def initialize(input)
    # noinspection RubyArgCount
    super(input).freeze
  end

  # @see https://apidock.com/ruby/OpenStruct/method_missing
  # @return [Object]
  def method_missing(method, *args) # rubocop:disable Style/MissingRespondToMissing
    -> { super }.tap do
      unless self.to_h.transform_keys(&:to_sym).include?(method.to_s.gsub(/=$/, '').to_sym)
        raise NoMethodError, "undefined method `#{method}' for #{self}", caller(1)
      end
    end.call
  end
end
