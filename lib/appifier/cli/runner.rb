# frozen_string_literal: true

require_relative '../cli'

# Runner
class Appifier::Cli::Runner < Appifier::BaseCli::Runner
  include(Appifier::Mixins::Inject)

  def initialize(options = {}, **kwargs)
    # @formatter:off
    {
      config: kwargs[:config],
      printer: kwargs[:printer],
      builds_lister: kwargs[:builds_lister],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on

    (kwargs[:container] || Appifier.container).yield_self do |container|
      super(self.class.__send__(:optionize, container, options)).tap { container.freeze }
    end
  end

  # @return [Appifier::Config]
  attr_reader :config

  # @return [Array<Pathname>]
  def build(recipe)
    Appifier::Builder.new(recipe, **options).call
  end

  # Call public method and format with printer output.
  #
  # @return [Object]
  def call(method, *args)
    super.tap { |result| printer.call(result) }
  end

  # @param [String] pattern
  #
  # @return [Hash{String => Array}]
  # @return [Hash{String => Hash}]
  #
  # @see https://ruby-doc.org/core-2.1.2/File.html#method-c-fnmatch-3F
  def list(pattern = nil)
    builds_lister.call.catalog(with_details: options[:detail]).tap do |catalog|
      return catalog.keep_if { |k, _| File.fnmatch?(pattern, k) } if pattern
    end
  end

  protected

  # @return [Appifier::JsonPrinter]
  attr_reader :printer

  # @return [Appifier::BuildsLister]
  attr_reader :builds_lister

  class << self
    # Prepare options from given container.
    #
    # Pass some options from options to container values,
    # as a result options are removed.
    #
    # @param [Appifier::Conatiner] container
    # @param [Hash] options
    #
    # @return [Hash]
    # @api private
    def optionize(container, options = {})
      lambda do
        return options if container.frozen?

        # noinspection RubyScope
        options.transform_keys(&:to_sym).dup.tap do |options| # rubocop:disable Lint/ShadowingOuterLocalVariable
          # k: options key, v: container key
          { verbose: :verbose }.each do |k, v|
            next unless options.key?(k)

            -> { options.delete(k) }.tap { container[v] = options[k] }.call
          end
        end
      end.call.freeze
    end
  end
end
