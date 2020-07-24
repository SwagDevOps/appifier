# frozen_string_literal: true

require_relative '../integration'
autoload(:Pathname, 'pathname')
autoload(:IniParser, 'iniparser')

# Describe a desktop file.
class Appifier::Integration::Desktop < Pathname
  # @return [Hash{String => String}]
  attr_reader :variables

  def initialize(path, variables = {}, template: Appifier.container[:template])
    super(path)

    @variables = variables.dup.freeze
    @template = template
  end

  # @return [Hash]
  def parse
    IniParser::Parser.new(read).parse
  end

  def fetch(*args, &block)
    to_h.fetch(*args, &block)
  end

  # @return [String]
  def filename
    self.basename('.desktop').to_s.freeze
  end

  alias to_h parse

  # Alter original content with given values.
  #
  # @param [Hash] merged
  # @return [String]
  def alter(merged)
    [].tap do |lines|
      self.class.merge(self.to_h, merged.to_h).each do |section_title, section|
        lines << "[#{section_title}]"
        section.each { |k, v| lines << "#{k}=#{template.call(v, variables)}" }
      end
    end.compact.join("\n")
  end

  class << self
    # Deep merge.
    #
    # @api private
    #
    # @return [Hash]
    #
    # @param [Hash] origin
    # @param [Hash] merged
    def merge(origin, merged)
      origin.merge(merged) do |_key, a, b|
        (a.is_a?(Hash) and b.is_a?(Hash)) ? merge(a, b) : b # rubocop:disable Style/TernaryParentheses
      end
    end
  end

  protected

  # @return [Proc]
  #
  # @see Appifier::Container
  attr_reader :template
end
