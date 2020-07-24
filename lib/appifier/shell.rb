# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../appifier'
autoload(:Shellwords, 'shellwords')

# Simple wrapper on top of ``system``.
class Appifier::Shell
  def initialize(verbose: false)
    # noinspection RubySimplifyBooleanInspection
    @verbose = verbose.is_a?(Proc) ? verbose : !!verbose
  end

  def verbose?
    verbose.is_a?(Proc) ? verbose.call : verbose
  end

  # @raise [RuntimeError]
  def sh(*args)
    command(args).yield_self do |command|
      warn(command.to_s) if verbose?

      command.call || (-> { raise command.to_s }).call
    end
  end

  protected

  # @return [Proc|Boolean]
  attr_reader :verbose

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

  # @api private
  #
  # @return [Struct]
  def command(args)
    { env: {}, options: {}, words: args.dup }.sort.to_h.tap do |v|
      v.merge!({ env: args.first, words: v.fetch(:words)[1..-1] }) if args.first.is_a?(Hash)
      v.merge!({ options: args.last, words: v.fetch(:words)[0..-2] }) if args.last.is_a?(Hash)
    end.yield_self do |v|
      Struct.new(*v.keys).new(*v.values).tap do |klass|
        klass.singleton_class.define_method(:call) { system(*self.to_a) }
        # noinspection RubyResolve,RailsParamDefResolve
        klass.singleton_class.define_method(:to_s) { Shellwords.join(public_send(:words)) }
        # noinspection RailsParamDefResolve
        klass.singleton_class.define_method(:to_a) do
          [public_send(:env)].concat(public_send(:words), [public_send(:options)])
        end
      end.freeze
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
