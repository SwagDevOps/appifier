# frozen_string_literal: true

require_relative '../appifier'
require 'dry/container'
autoload(:Pathname, 'pathname')
autoload(:Singleton, 'singleton')

# Dependency container.
#
# Sample of use:
#
# ```ruby
# Appifier::Container[:answer]
# ```
class Appifier::Container < Dry::Container
  # noinspection RubyResolve
  include Singleton

  def initialize(*args, &block)
    super.tap do
      self.class.__send__(:file).realpath.tap do |fp|
        self.instance_eval(fp.read, fp.to_s).each { |k, v| self[k] = v }
      end
    end
  end

  # Register an item with the container to be resolved later.
  #
  # @param [Mixed] key
  #   The key to register the container item with (used to resolve)
  # @param [Mixed] contents
  #   The item to register with the container (if no block given)
  # @param [Hash] options
  #   Options to pass to the registry when registering the item
  # @yield
  #   If a block is given, contents will be ignored and the block
  #   will be registered instead
  #
  # @return [Dry::Container::Mixin] self
  def register(key, contents = nil, options = {}, &block)
    -> { super }.tap do
      if self.key?(key) # avoid `Dry::Container::Error` merging
        Dry::Container.new.register(key, contents, options, &block).tap do |container|
          return self.merge(container)
        end
      end
    end.call
  end

  # @return [Dry::Container::Mixin] self
  def []=(key, value)
    (value.respond_to?(:memoized?) and value.public_send(:memoized?)).yield_self do |memoized|
      self.register(key.to_s.freeze, value, { memoize: memoized, call: value.is_a?(::Proc) })
    end
  end

  alias has? key?

  class << self
    protected

    # Get path to config file.
    #
    # @api private
    #
    # @return [Pathname]
    def file
      Pathname.new(__dir__).join(Pathname.new(__FILE__).basename('.*')).join('config.rb')
    end
  end
end
