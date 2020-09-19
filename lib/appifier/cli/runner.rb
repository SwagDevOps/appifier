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
      uninstaller: kwargs[:uninstaller],
    }.yield_self { |injection| inject(options, **injection) }.tap do |injection|
      injection.container.freeze
      injection.result.assert { !values.include?(nil) }
      super(injection.options)
    end
    # @formatter:on
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
      return pattern ? catalog.glob(pattern) : catalog
    end
  end

  def uninstall(pattern = nil)
    uninstaller.call(pattern)
  end

  protected

  # @return [Appifier::JsonPrinter]
  attr_reader :printer

  # @return [Appifier::BuildsLister]
  attr_reader :builds_lister

  # @return [Appifier::Uninstaller]
  attr_reader :uninstaller

  # Process injection with given options.
  #
  # @param [Hash{String => Object}] options
  #
  # @return [Struct]
  def inject(options, **definition)
    (definition[:container] || Appifier.container).yield_self do |container|
      # @formatter:off
      {
        container: container,
        options: self.class.__send__(:optionize, container, options),
        result: super(**definition)
      }.yield_self { |h| Struct.new(*h.keys).new(*h.values) }
      # @formatter:on
    end
  end

  class << self
    protected

    # Get options stored on container
    #
    # k: options key, v: container key
    #
    # @api private
    #
    # @return [Hash{Symbol => Symbol}]
    def container_options
      # @formatter:off
      {
        verbose: :verbose,
        dry_run: :dry_run,
      }
      # @formatter:on
    end

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
        # rubocop:disable Lint/ShadowingOuterLocalVariable
        options.transform_keys(&:to_sym).dup.tap do |options|
          # k: options key, v: container key
          container_options.each do |k, v|
            next unless options.key?(k)

            -> { options.delete(k) }.tap { container[v] = options[k] }.call
          end
        end
        # rubocop:enable Lint/ShadowingOuterLocalVariable
      end.call.freeze
    end
  end
end
