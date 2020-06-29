# frozen_string_literal: true

require_relative '../appifier'

# Integration
class Appifier::Integration
  autoload(:Pathname, 'pathname')

  # @formatter:off
  {
    Desktop: 'desktop',
    Extraction: 'extraction',
    Install: 'install',
    BuildsList: 'builds_list',
  }.each { |s, fp| autoload(s, "#{__dir__}/integration/#{fp}") }
  # @formatter:on

  # Read from YAML integration section.
  #
  # @return [Hash{String => Object}]
  attr_reader :parameters

  def initialize(out_dir, config: Appifier::Config.new, recipe: nil, verbose: false, install: false)
    @out_dir = Pathname.new(out_dir).freeze
    @recipe = recipe.freeze
    @config = config
    # noinspection RubySimplifyBooleanInspection
    @verbose = !!verbose
    # noinspection RubySimplifyBooleanInspection
    @installable = !!install
    # set parameters
    @parameters = { # @formatter:off
      'name' => recipe.to_h.fetch('app'),
      'executable' => recipe.to_h.fetch('app').downcase,
      'exec_params' => [], # @formatter:on
    }.merge(recipe.to_h.fetch('integration', {})).transform_values(&:freeze).freeze
  end

  def verbose?
    @verbose
  end

  def name
    fetch('name')
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

  # @return [nil|Appifier::Recipe]
  attr_reader :recipe

  # @return [Pathname]
  attr_reader :out_dir

  # @return [Appifier::Config]
  attr_reader :config
end
