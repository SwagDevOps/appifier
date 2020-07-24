# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')
autoload(:FileUtils, 'fileutils')
autoload(:Etc, 'etc')
autoload(:Open3, 'open3')
autoload(:Liquid, 'liquid')

# Builder
class Appifier::Execution
  include(Appifier::Mixins::Shell)

  def initialize
    super
  end

  def call
    self.logfiles.transform_values { |v| File.open(v, 'w') }.tap do |options|
      sh(env, scripts.map(&:call).fetch(0).to_s, target, options)
    end
  end

  def log_patterns
    { out: 'out.log', err: 'err.log' }.map { |k, v| [k.to_sym, build_dir.join('logs', '{{recipe}}', v)] }.to_h
  end
end
