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

  # return [Pathname]
  def call
    build.tap do
      config.fetch('applications_dir').join(name).tap do |app_dir|
        Install.new(build, app_dir, parameters: parameters).tap do |install| # rubocop:disable Style/SymbolProc
          install.call # @todo returns file created during install
        end
      end
    end
  end

  protected

  # @return [Pathname]
  attr_reader :build

  # @return [Appifier::Config]
  attr_reader :config

  # @param [Hash|Appifier::Recipe] recipe
  #
  # @return [Hash]
  def parameterize(recipe)
    { # @formatter:off
      name: recipe.to_h.fetch('app').to_s,
      executable: recipe.to_h.fetch('app').to_s.downcase,
      logname: recipe.to_s,
      exec_params: [], # @formatter:on
    }.transform_keys(&:to_s).merge(recipe.to_h.fetch('integration', {})).yield_self do |h|
      h.merge(user_integrations.fetch(h.fetch('name'), {}))
    end.transform_values(&:freeze).freeze
  end
end
