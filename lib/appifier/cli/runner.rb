# frozen_string_literal: true

require_relative '../cli'

# Runner
class Appifier::Cli::Runner < Appifier::BaseCli::Runner
  include(Appifier::Mixins::Printer)

  def initialize(options = {}, container: Appifier.container)
    self.container = container

    super(options).tap do
      @options = self.options
      container.freeze
    end
  end

  def build(recipe)
    Appifier::Builder.new(recipe, **options).prepare!.call.tap { |build| printer.call(build) }
  end

  protected

  # @return [Appifier::Container]
  attr_accessor :container

  # Prepare options.
  #
  # Pass some options from options to container values,
  # as a result options are removed.
  #
  # @return [self]
  def options
    return super if container.frozen?

    super.transform_keys(&:to_sym).dup.tap do |options|
      # k: container key, v: options key
      { verbose: :verbose }.each do |k, v|
        -> { options.delete(k) }.tap { container[v] = options[k] }.call
      end
    end.freeze
  end
end
