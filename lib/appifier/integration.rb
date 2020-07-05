# frozen_string_literal: true

require_relative '../appifier'

# Integration
class Appifier::Integration
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  # @formatter:off
  {
    Desktop: 'desktop',
    Extraction: 'extraction',
    Install: 'install',
    BuildsList: 'builds_list',
  }.each { |s, fp| autoload(s, "#{__dir__}/integration/#{fp}") }
  # @formatter:on

  # Read from YAML recipe integration section + users configuration.
  #
  # @return [Hash{String => Object}]
  attr_reader :parameters

  def initialize(out_dir, recipe:, config: Appifier::Config.new, verbose: false, install: false)
    self.tap do
      @out_dir = Pathname.new(out_dir).freeze
      @config = config
      # noinspection RubySimplifyBooleanInspection
      @verbose = !!verbose
      # noinspection RubySimplifyBooleanInspection
      @installable = !!install
      @parameters = parameterize(recipe).freeze
    end.freeze
  end

  def verbose?
    @verbose
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

  def installable?
    @installable
  end

  def fetch(*args, &block)
    parameters.fetch(*args, &block)
  end

  # return [Pathname]
  def call
    builds.values.last.tap do |build|
      config.fetch('applications_dir').join(name).tap do |app_dir|
        Install.new(build, app_dir, config: config, parameters: parameters, verbose: verbose?).tap do |install|
          install.call if installable?
        end
      end
    end
  end

  # Get matching builds sorted by mtime.
  #
  # @return [Hash<String => Pathname>]
  def builds
    BuildsList.new(out_dir, name).freeze
  end

  protected

  # @return [Pathname]
  attr_reader :out_dir

  # @return [Appifier::Config]
  attr_reader :config

  # @param [Hash|Appifier::Recipe] recipe
  #
  # @return [Hash]
  def parameterize(recipe)
    { # @formatter:off
      name: recipe.to_h.fetch('app').to_s,
      executable: recipe.to_h.fetch('app').to_s.downcase,
      exec_params: [], # @formatter:on
    }.transform_keys(&:to_s).merge(recipe.to_h.fetch('integration', {})).yield_self do |h|
      h.merge(user_integrations.fetch(h.fetch('name'), {}))
    end.transform_values(&:freeze).freeze
  end
end
