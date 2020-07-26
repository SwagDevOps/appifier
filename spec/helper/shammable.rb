# frozen_string_literal: true

# Shammable methods
module Shammable
  # Singleton configuration for shams.
  class Config < Hash
    include Singleton
    autoload(:Pathname, 'pathname')

    class << self
      # @return [Hash{Symbol => Object}]
      def defaults
        { path: Pathname.new(Dir.pwd).join('spec', 'sham') }
      end
    end

    def initialize
      self.class.defaults.each { |k, v| self[k] = v }
    end

    def freeze
      -> { super }.tap { self.transform_values(&:freeze) }.call
    end
  end

  # Retrieve ``sham`` by given ``name``
  #
  # @param [Symbol] name
  # @return [Struct]
  def sham(name) # rubocop:disable Metrics/AbcSize
    shams_store.tap do |shams|
      shams[name.to_sym] ||= lambda do
        # self.const_get(:Config)
        Config.instance.freeze[:path].join("#{name}.rb").read.yield_self do |content|
          instance_eval(content).yield_self { |v| Struct.new(*v.keys).new(*v.values) }
        end
      end.call
    end.fetch(name.to_sym)
  end

  protected

  # Storage for shams already loaded.
  #
  # @return [Hash{Symbol => Struct}]
  def shams_store
    @shams_store ||= {}
  end
end
