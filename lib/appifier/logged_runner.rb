# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# Provide a shell context collecting outputs into files.
class Appifier::LoggedRunner
  include(Appifier::Mixins::Inject)
  include(Appifier::Mixins::Immutable)

  # @return [String]
  attr_reader :mode

  # @param [String] directory
  def initialize(directory, env: {}, **kwargs)
    # @formatter:off
    {
      fs: kwargs[:fs],
      shell: kwargs[:shell],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

    immutable do
      @directory = Pathname.new(directory).freeze
      @env = env.to_h.transform_values(&:freeze).freeze
      @mode = 'a'
    end
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
            self.class.cmd(command, env: self.env.dup, runner: ->(*args) { self.shell.sh(*args) }).call(**options)
          end
        end
      end
    end
  end

  protected

  class << self
    # Prepare command into a Struct able to execute itself.
    #
    # @api private
    #
    # @param [Array<String>] command
    # @param [Hash<String => String>] env
    #
    # @return [Struct]
    def cmd(command, env: {}, runner: nil)
      if command[0].is_a?(Hash)
        env = env.dup.merge(command[0])
        command = command[1..-1]
      end

      Struct.new(:env, :args).new(env, command).tap do |cmd|
        cmd.singleton_class.define_method(:to_a) { [cmd.env].concat(cmd.args) }
        cmd.singleton_class.define_method(:call) { |**options| runner.call(*cmd.to_a.concat([options])) } if runner
      end
    end
  end

  # @return [Pathname]
  attr_reader :directory

  # @return [Hash{String => String}]
  attr_reader :env

  # @return [Appifier::FileSystem]
  # @return [FileUtils]
  attr_reader :fs

  # @return [Appifier::Shell]
  attr_reader :shell

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
