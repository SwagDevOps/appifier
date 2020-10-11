# frozen_string_literal: true

# @formatter:off
{
  verbose: false,
  dry_run: false,
  'utils.dupper': lambda do
    autoload(:DeepDup, 'deep_dup')

    ->(instance) { DeepDup.deep_dup(instance) }
  end,
  config: -> { Appifier::Config.new },
  desktop_database_updater: -> { Appifier::DesktopDatabaseUpdater.new },
  fs: lambda do
    {
      false => Appifier::FileSystem.new(self[:verbose] ? :verbose : :default),
      true => Appifier::FileSystem.new(:dry_run)
    }.fetch(self[:dry_run])
  end,
  builds_lister: lambda do
    self[:config].fetch('cache_dir').join('out').yield_self do |builds_dir|
      Appifier::BuildsLister.new(builds_dir)
    end
  end,
  'build.scripts_runner': -> { Appifier::Scripts::Runner.new },
  logged_runner: lambda do
    self[:config].fetch('cache_dir').yield_self do |cache_dir|
      # @formatter:off
      Appifier::LoggedRunner.new(cache_dir.join('logs'), env: {
        ARCH: self[:config].fetch('build_arch'),
        LC_ALL: 'C.UTF-8',
        LANG: 'C.UTF-8',
        LANGUAGE: 'C.UTF-8',
        FUNCTIONS_SH: cache_dir.join('functions.sh'),
      }.dup.map { |k, v| [k.to_s.freeze, v.to_s.freeze] }.freeze)
      # @formatter:off
    end
  end,
  uninstaller: -> { Appifier::Uninstaller.new },
  'uninstaller.lister': -> { Appifier::Uninstaller::Lister.new },
  printer: -> { Appifier::JsonPrinter.new },
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
