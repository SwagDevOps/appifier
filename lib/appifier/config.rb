# frozen_string_literal: true

require_relative '../appifier'

# Config from environment variables.
class Appifier::Config < Hash
  autoload(:YAML, 'yaml')
  autoload(:Etc, 'etc')
  autoload(:Pathname, 'pathname')

  def initialize(from: ENV, prefix: 'APPIFIER')
    @prefix = prefix

    self.tap do
      self.class.__send__(:filter, from, prefix: self.prefix).tap do |filtered|
        self.class.defaults.merge(filtered).tap do |h|
          h.each { |k, v| self[k] = v }
        end
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
      # @formatter:off
      {
        cache_dir: nil,
        recipes_dir: Pathname.new(__dir__).realpath.join('recipes').to_s.freeze,
        # integration values --------------------------------------------------
        applications_dir: home.join('Applications'),
        bin_dir: home.join('.local', 'bin'),
        desktops_dir: home.join('.local', 'share', 'applications'),
      }.transform_keys { |k| k.to_s.freeze }
      # @formatter:on
    end

    protected

    # Get home directory for current user.
    #
    # @return [Pathname]
    def home
      Pathname.new(Etc.getpwnam(Etc.getlogin).dir)
    end

    # @api private
    #
    # @return [Hash{String => Object}]
    def filter(source, prefix:)
      {}.tap do |result|
        source.to_h.dup.freeze.each do |k, v|
          /^#{prefix}_/.tap do |regex|
            # noinspection RubyResolve
            result[k.gsub(regex, '').downcase] = YAML.safe_load(v) if k.match(/^#{prefix}_/)
          end
        end
      end
    end
  end

  protected

  attr_reader :prefix
end
