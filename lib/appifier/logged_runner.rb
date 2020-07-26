# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# Provide a shell context collecting outputs into files.
class Appifier::LoggedRunner
  include(Appifier::Mixins::Fs)
  include(Appifier::Mixins::Shell)

  # @param [String] directory
  def initialize(directory, env: {})
    @directory = Pathname.new(directory).freeze
    @env = env.to_h.transform_values(&:freeze).freeze
  end

  def call(*args, name:)
    prepare(name) do
      logs_for(name).transform_values { |v| File.open(v, 'w') }.tap do |options|
        sh(*[env].concat(args).concat([options]))
      end
    end
  end

  protected

  # @return [Pathname]
  attr_reader :directory

  # @return [Hash{String => String}]
  attr_reader :env

  def prepare(name, &block)
    self.tap do
      # build_dir { true }
      logs_for(name).each_value do |fp|
        if fp.is_a?(Pathname)
          fp.dirname.tap { |dir| fs.mkdir_p(dir) unless dir.exist? }
          fs.touch(fp)
        end
      end

      return block.call if block
    end
  end

  # @return [Hash{Symbol => Pathname}]
  def logs_for(name)
    { out: 'out.log', err: 'err.log' }.map { |k, v| [k.to_sym, directory.join(name, v)] }.to_h
  end
end
