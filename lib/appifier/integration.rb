# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')
autoload(:YAML, 'yaml')

# Integration
class Appifier::Integration
  # @formatter:off
  {
    Desktop: 'desktop',
    Extraction: 'extraction',
    Install: 'install',
    BuildsList: 'builds_list',
  }.each { |s, fp| autoload(s, "#{__dir__}/integration/#{fp}") }
  # @formatter:on

  include(Appifier::Mixins::Inject)

  # Read from YAML recipe integration section + users configuration.
  #
  # @return [Hash{String => Object}]
  attr_reader :parameters

  # Install given build.
  #
  # @param [String] build path to a build result file (an *.AppImage file)
  #
  # @option kwargs [Appifier::Recipe] :recipe
  def initialize(build, recipe:, **kwargs)
    inject(config: kwargs[:config]).assert { !values.include?(nil) }

    self.tap do
      @build = Pathname.new(build).freeze
      @parameters = parameterize(recipe).freeze
    end.freeze
  end

  def name
    fetch('name')
  end

  # Get users configured integrations.
  #
  # Indexed by integration name.
  #
  # @return [Hash{String => Object}]
  def user_integrations
    Pathname.new(config.fetch('config_dir')).join('integration.yml').read.yield_self do |content|
      YAML.safe_load(content).tap do |h|
        return {} unless h.is_a?(Hash)

        h.map { |k, v| v['name'] = k } # avoid to override initial name
      end
    end
  rescue Errno::ENOENT
    {}
  end

  def fetch(*args, &block)
    parameters.fetch(*args, &block)
  end

  # return [Array<Pathname>]
  def call
    build.tap do
      config.fetch('applications_dir').join(name).tap do |app_dir|
        Install.new(build, app_dir, parameters: parameters).tap do |install|
          return install.call # @todo returns file created during install
        end
      end
    end
  end

  protected

  class << self
    # @param [Hash] origin
    # @param [Hash] merged
    #
    # @api private
    #
    # @return [Hash]
    # #raise [ArgumentError]
    # @see Appifier::Integration#parameterize
    def deep_merge(origin, merged)
      unless origin.is_a?(Hash) and merged.is_a?(Hash)
        "Expected Hash arguments, got #{[origin.class, merged.class]}"
          .tap { |message| raise ArgumentError, message }
      end

      lambda do |_, x, y|
        y.tap do
          return deep_merge(x, y) if x.is_a?(Hash) and y.is_a?(Hash)
        end
      end.yield_self { |f| origin.merge(merged, &f) }
    end
  end

  # @return [Pathname]
  attr_reader :build

  # @return [Appifier::Config]
  attr_reader :config

  # @param [Hash|Appifier::Recipe] recipe
  #
  # @return [Hash]
  def parameterize(recipe) # rubocop:disable Metrics/AbcSize
    { # @formatter:off
      name: recipe.to_h.fetch('app').to_s,
      executable: recipe.to_h.fetch('app').to_s.downcase,
      logname: recipe.to_s, # @formatter:on
    }.transform_keys(&:to_s).merge(recipe.to_h.fetch('integration', {})).yield_self do |h|
      self.class.__send__(:deep_merge, h, user_integrations[h.fetch('name')].to_h)
          .to_h
          .transform_values(&:freeze).freeze
    end
  end
end
