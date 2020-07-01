# frozen_string_literal: true

require_relative '../integration'

autoload(:Pathname, 'pathname')

# Describe a desktop file.
class Appifier::Integration::Desktop < Pathname
  autoload(:IniParser, 'iniparser')
  autoload(:Liquid, 'liquid')

  # @return [Hash{String => String}]
  attr_reader :variables

  def initialize(path, variables = {})
    super(path)

    @variables = variables.dup.freeze
  end

  # @return [Hash]
  def parse
    IniParser::Parser.new(read).parse
  end

  def fetch(*args, &block)
    to_h.fetch(*args, &block)
  end

  def filename
    self.basename('.desktop')
  end

  alias to_h parse

  # Alter original content with given values.
  #
  # @return [String]
  def alter(merged)
    [].tap do |lines|
      self.class.merge(self.to_h, merged.to_h).each do |section_title, section|
        lines << "[#{section_title}]"
        section.each { |k, v| lines << "#{k}=#{self.template(v)}" }
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

  # @param [String] str
  #
  # @return [String]
  #
  # @see https://github.com/Shopify/liquid/blob/70c45f8cd84c753298dd47488b85169458692875/README.md
  #
  # @raise [Liquid::Error]
  def template(str)
    Liquid::Template.parse(str, { error_mode: :strict }).yield_self do |template|
      template.render(variables, { strict_variables: true }).tap do
        raise template.errors.first unless template.errors.empty?
      end
    end
  end
end
