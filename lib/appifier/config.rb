# frozen_string_literal: true

require_relative '../appifier'

# Config from environment variables.
#
# @see https://wiki.archlinux.org/index.php/XDG_Base_Directory
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
    def defaults # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # @formatter:off
      {
        cache_dir: ENV.fetch('XDG_CACHE_HOME', whoami.fetch(:dir).join('.cache')).yield_self do |dir|
          Pathname.new(dir.to_s).join('appifier')
        end,
        recipes_dir: Pathname.new(__dir__).realpath.join('recipes').to_s.freeze,
        # integration values --------------------------------------------------
        applications_dir: whoami.fetch(:dir).join('Applications'),
        bin_dir: whoami.fetch(:dir).join('.local', 'bin'),
        desktops_dir: whoami.fetch(:dir).join('.local', 'share', 'applications'),
        config_dir: ENV.fetch('XDG_CONFIG_HOME', whoami.fetch(:dir).join('.config')).yield_self do |dir|
          Pathname.new(dir.to_s).join('appifier')
        end
      }.transform_keys { |k| k.to_s.freeze }
      # @formatter:on
    end

    protected

    # Return the ``/etc/passwd`` information for the current user.
    #
    # @api private
    #
    # @return [Struct{Symbol => Object}]
    def whoami
      Etc.getpwnam(Etc.getlogin).to_h.tap do |h|
        h[:dir] = Pathname.new(h[:dir])
      end
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
