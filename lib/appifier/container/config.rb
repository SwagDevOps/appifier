# frozen_string_literal: true

# @formatter:off
{
  config: -> { Appifier::Config.new },
  verbose: false,
  fs: lambda do
    autoload(:FileUtils, 'fileutils')

    self[:verbose] ? FileUtils::Verbose : FileUtils
  end,
  shell: -> { Appifier::Shell.new(verbose: self[:verbose]) },
  template: lambda do
    # @return [String]
    # @raise [Liquid::Error]
    # @see https://github.com/Shopify/liquid/blob/70c45f8cd84c753298dd47488b85169458692875/README.md
    lambda do |str, variables = {}|
      autoload(:Liquid, 'liquid')

      Liquid::Template.parse(str, { error_mode: :strict }).yield_self do |template|
        template.render(variables, { strict_variables: true }).tap do
          raise template.errors.first unless template.errors.empty?
        end
      end
    end
  end
}
# @formatter:on
