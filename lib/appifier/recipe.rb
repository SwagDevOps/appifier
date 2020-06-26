# frozen_string_literal: true

require_relative '../appifier'

# Recipe
#
# Describe a reacipe, almost a file having a name.
class Appifier::Recipe
  autoload(:YAML, 'yaml')
  autoload(:Pathname, 'pathname')

  # @return [Symbol]
  attr_reader :name

  alias to_sym name

  def initialize(name, config: Appifier::Config.new)
    @name = name.to_sym.freeze
    @config = config
  end

  # @return [String]
  def to_s
    self.to_sym.to_s
  end

  # @return [String]
  def to_path
    realpath.to_path
  end

  # @return [Pathname]
  def dir
    Pathname.new(config.fetch('recipes_dir'))
  end

  # @return [Hash{String => Object}]
  def dump
    # noinspection RubyResolve
    YAML.safe_load(read)
  end

  def to_h
    dump.to_h
  end

  # @return [String]
  def read
    file.read
  end

  # @return [Pathname]
  def realpath
    self.dir.realpath.join("#{name}.yml").realpath
  end

  alias file realpath

  # @return [String]
  def filename
    file.basename('.*').to_s
  end

  protected

  # @return [Appifier::Config]
  attr_reader :config
end
