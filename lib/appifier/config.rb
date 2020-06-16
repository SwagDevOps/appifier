# frozen_string_literal: true

require_relative '../appifier'

# Config from environment variables.
class Appifier::Config < Hash
  autoload(:YAML, 'yaml')

  def initialize(from: ENV, prefix: 'APPIFIER')
    @prefix = prefix

    self.tap do
      self.class.defaults.merge(self.class.filter(from, prefix: self.prefix)).tap do |h|
        h.each { |k, v| self[k] = v }
      end
    end.compact!.freeze
  end

  def freeze
    self.each_key { |k| self[k] = self[k].freeze }
    super
  end

  class << self
    # @return [Hash{String => Object}]
    def defaults
      {
        'cache_dir' => nil,
        'recipes_dir' => Pathname.new(__dir__).realpath.join('recipes').to_s.freeze
      }
    end

    # @return [Hash{String => Object}]
    def filter(source, prefix:)
      {}.tap do |result|
        source.to_h.dup.freeze.each do |k, v|
          /^#{prefix}_/.tap do |regex|
            result[k.gsub(regex, '').downcase] = YAML.safe_load(v) if k.match(/^#{prefix}_/)
          end
        end
      end
    end
  end

  protected

  attr_reader :prefix
end
