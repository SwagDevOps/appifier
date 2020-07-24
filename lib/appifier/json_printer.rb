# frozen_string_literal: true

require_relative '../appifier'
autoload(:JSON, 'json')

# Print JSON (from an arbitrary payload) to STDOUT.
class Appifier::JsonPrinter
  class << self
    # @return [Proc]
    def formatter
      lambda do |source, tty: false|
        require 'rouge'

        formatter = Rouge::Formatters::Terminal256.new
        lexer = Rouge::Lexer.find('json')

        return tty ? formatter.format(lexer.lex(source)) : source
      end
    end
  end

  def initialize(formatter: self.class.formatter, output: $stdout)
    self.tap do
      @formatter = formatter
      @output = output
    end.freeze
  end

  # Print given payload as JSON on output.
  #
  # @return [String]
  def call(payload)
    format(payload).tap { |s| output.write("#{s.strip}\n") }
  end

  protected

  # @return [Proc]
  attr_reader :formatter

  # @return [IO]
  attr_reader :output

  # Format given payload
  #
  # @return [String]
  def format(payload)
    JSON.pretty_generate(payload).tap do |source|
      return formatter.call(source, tty: tty?)
    end
  end

  # Denote output is supposed to be a tty.
  #
  # @return [Boolean]
  def tty?
    !!(output.respond_to?(:isatty) and output.isatty)
  end
end
