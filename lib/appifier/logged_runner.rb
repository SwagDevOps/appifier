# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# Provide a shell context collecting outputs into files.
class Appifier::LoggedRunner
  include(Appifier::Mixins::Fs)
  include(Appifier::Mixins::Shell)

  # @return [String]
  attr_reader :mode

  # @param [String] directory
  def initialize(directory, env: {})
    @directory = Pathname.new(directory).freeze
    @env = env.to_h.transform_values(&:freeze).freeze
    @mode = 'a'
  end

  # Call commands and collect logs by given names.
  #
  # @param [Hash{}Symbol => Array] definitions
  #
  # Sample of use:
  #
  # ```
  # logged_runner.call({ 'sample' => [['true']] })
  # ```
  def call(definitions)
    definitions.each do |name, commands|
      prepare(name) do
        logs_for(name).transform_values { |v| File.open(v, self.mode) }.tap do |options|
          commands.each do |command|
            sh(*[env].concat(command).concat([options]))
          end
        end
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
