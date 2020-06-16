# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Copyright (C) 2019-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../appifier')

# Bundled behavior.
#
# Allow to detect bundled execution due to ``gems.rb`` and ``gems.locked``
# files presence, and``development`` execution (``gemspec.tpl`` file presence).
module Appifier::Bundled
  autoload(:Pathname, 'pathname')

  class << self
    def included(base)
      base.extend(ClassMethods)

      Pathname.new(caller_locations.first.path).dirname.tap do |caller_path|
        (base.__send__(:base_path) || caller_path).tap do |basepath|
          base.__send__(:base_path=, Pathname(basepath).join('..'))
        end
      end
    end
  end

  # Class methods
  module ClassMethods
    protected

    # Set `base_path` from given `path`.
    #
    # @param [String] path
    # @return [Pathname]
    def base_path=(path)
      @base_path = Pathname.new(path).realpath
    end

    # @return [Pathname]
    def base_path
      @base_path
    end

    # Denote current class is used in a bundled context.
    #
    # @return [Boolean]
    def bundled?
      # @formatter:off
      [%w[gems.rb gems.locked], %w[Gemfile Gemfile.lock]].map do |m|
        Dir.chdir(base_path) do
          m.map { |f| Pathname(f).file? }.uniq
        end
      end.include?([true])
      # @formatter:on
    end

    # Denote current class is used in development context.
    #
    # @return [Boolean]
    def development?
      # @formatter:off
      bundled? and [['gemspec.tpl']].map do |m|
        Dir.chdir(base_path) do
          m.map { |f| Pathname(f).file? }
        end
      end.include?([true])
      # @formatter:on
    end
  end
end
