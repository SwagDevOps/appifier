# frozen_string_literal: true

require_relative '../install'

# Build a desktop with given parameters and config.
class Appifier::Integration::Install::DesktopBuilder
  autoload(:Pathname, 'pathname')

  # @param [String] desktop_path
  # @param [String] app_dir
  def initialize(desktop_path, app_dir, parameters:, config: Appifier::Config.new)
    @desktop_path = Pathname.new(desktop_path.to_s).freeze
    @app_dir = Pathname.new(app_dir.to_s).freeze
    @parameters = parameters.to_h.freeze
    @config = config
  end

  # @return [Appifier::Integration::Desktop]
  def build
    Appifier::Integration::Desktop.new(desktop_path, variables)
  end

  # Write desktop file (altered with ``override``).
  #
  # @return [Pathname]
  def call
    self.build.yield_self do |desktop|
      desktop.alter(parameters['desktop']&.fetch('override', {})).yield_self do |content|
        return app_dir.join('app.desktop').tap { |file| file.write(content) }
      end
    end
  end

  # Get variables used by desktop template.
  #
  # @return [Hash{String => String|Hash]}]
  #
  # @see Appifier::Integration::Desktop#template
  def variables # rubocop:disable Metrics/AbcSize
    { # @formatter:off
      executable: {
        name: parameters.fetch('executable'),
        path: config.fetch('bin_dir').join(parameters.fetch('executable')),
      }.transform_keys { |k| k.to_s.freeze }.transform_values { |v| v.to_s.freeze },
      icon: {
        path: app_dir.join('.icon'),
      }.transform_keys { |k| k.to_s.freeze }.transform_values { |v| v.to_s.freeze },
    }.transform_keys { |k| k.to_s.freeze }.freeze # @formatter:on
  end

  protected

  # @return [Pathname]
  attr_reader :desktop_path

  # @return [Pathname]
  attr_reader :app_dir

  # @return [Hash]
  attr_reader :parameters

  # @return [Appifier::Config]
  attr_reader :config
end
