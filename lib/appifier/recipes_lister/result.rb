# frozen_string_literal: true

require_relative '../recipes_lister'

# Describe a result
#
# @see Appifier::RecipesLister#call
class Appifier::RecipesLister::Result
  include Appifier::Mixins::Inject
  include Appifier::Mixins::Immutable

  def initialize(hash, **kwargs)
    # @formatter:off
    {
      dupper: [kwargs[:dupper], :'utils.dupper'],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

    immutable! { @value = dupper.call(hash) }
  end

  # @return [Hash]
  # @return [Appifier::Mixins::HashGlob]
  def to_h
    dupper.call(value).yield_self { |h| Appifier::Mixins::HashGlob.from(h) }
  end

  # @return [Array<String>]
  def keys
    to_h.keys
  end

  # @return [Array<Appifier::Recipe>]
  def values
    to_h.values
  end

  def fetch(name)
    to_h.glob(name).values.tap do |results|
      if results.empty?
        DidYouMean::SpellChecker.new(dictionary: keys.map(&:to_s)).correct(name).tap do |v|
          raise KeyError, ["key not found: #{name}", "Did you mean? #{v.inspect}}"].join("\n")
        end
      end

      return results.fetch(0)
    end
  end

  protected

  attr_reader :value

  # @return [Proc]
  attr_reader :dupper
end
