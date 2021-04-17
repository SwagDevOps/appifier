# frozen_string_literal: true

require_relative '../appifier'
autoload(:Pathname, 'pathname')

# List recipes
class Appifier::RecipesLister
  include(Appifier::Mixins::Inject)

  # @formatter:off
  {
    Result: 'result',
  }.each { |s, fp| autoload(s, "#{__dir__}/recipes_lister/#{fp}") }
  # @formatter:on

  def initialize(**kwargs)
    # @formatter:off
    {
      config: kwargs[:config],
    }.tap do |injection|
      inject(**injection).assert { !values.include?(nil) }
    end
    # @formatter:on
  end

  # Get recipes indexed by name.
  #
  # @return [Hash{String => Appifier::Recipe}]
  # @return [Appifier::Mixins::HashGlob]
  def recipes
    scan.to_h.transform_keys(&:to_s).yield_self { |h| Appifier::Mixins::HashGlob.from(h) }
  end

  # Get recipes indexed by app name.
  #
  # @return [Appifier::Mixins::HashGlob]
  # @return [Hash{String => Appifier::Recipe}]
  def apps
    recipes
      .values
      .map { |recipe| [recipe.dump.fetch('app'), recipe] }
      .to_h
      .transform_keys(&:to_s).yield_self { |h| Appifier::Mixins::HashGlob.from(h) }
  end

  # Get recipes indexed by app name.
  def call
    self.apps.tap do |result|
      self.recipes.keep_if { |k, _| !result.glob(k) }.yield_self do |recipes|
        return result.merge(recipes).sort.to_h.yield_self { |h| Result.new(h) }
      end
    end
  end

  protected

  # @return [Appifier::Config]
  attr_reader :config

  # Get builds sorted by mtime.
  #
  # @api private
  #
  # @return [Hash{Symbol => Appifier::Recipe}]
  def scan
    {}.tap do |result|
      config.fetch('recipes_path').reverse.map do |path|
        Dir.glob("#{path}/*.yml").map do |fp|
          Appifier::Recipe.new(Pathname.new(fp).basename('.*').to_s, config: config)
        end
      end.flatten.each do |recipe|
        result[recipe.name] ||= recipe
      end
    end
  end
end
