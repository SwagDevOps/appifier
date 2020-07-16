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

  # @return [Dry::Container::Mixin] self
  def []=(key, value)
    (value.respond_to?(:memoized?) and value.public_send(:memoized?)).yield_self do |memoized|
      self.register(key.to_s.freeze, value, { memoize: memoized, call: value.is_a?(::Proc) })
    end
  end

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
