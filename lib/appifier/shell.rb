# frozen_string_literal: true

require_relative '../appifier'

# Wrapper around ``system``
module Appifier::Shell
  autoload(:Shellwords, 'shellwords')

  def verbose?
    true
  end

  def sh(*args)
    warn(Shellwords.join(args.dup.reject { |item| item.is_a?(Hash) })) if verbose?

    system(*args) || (-> { raise args.inspect }).call
  end

  class << self
    def sh(*args)
      instance.sh(*args)
    end

    protected

    def instance
      self.yield_self do |m|
        Class.new { include m }.new
      end
    end
  end
end
