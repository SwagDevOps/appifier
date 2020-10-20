# frozen_string_literal: true

require_relative '../mixins'

# Mixin appliable on Hash (or any Hashlike with #keep_if interface method).
#
# Case insensitive + { } is supported (EXTGLOB)
#
# @see https://ruby-doc.org/core-2.5.0/File.html#method-c-fnmatch
module Appifier::Mixins::HashGlob
  class << self
    # @param [Hash] hash
    #
    # @return [Hash]
    # @return [Appifier::Mixins::HashGlob]
    def from(hash)
      hash.tap { hash.singleton_class.__send__(:include, self) }
    end
  end

  # @param [String, Array<String>] pattern
  #
  # @return [Hash]
  # @return [Appifier::Mixins::HashGlob]
  def glob(pattern)
    dup.keep_if do |k, _|
      lambda do
        false.tap do
          (pattern.is_a?(Array) ? pattern : [pattern]).each do |matchable|
            return true if File.fnmatch?(matchable, k, ::File::FNM_CASEFOLD | ::File::FNM_EXTGLOB)
          end
        end
      end.call
    end.tap { |h| h.singleton_class.__send__(:include, Appifier::Mixins::HashGlob) }
  end
end
