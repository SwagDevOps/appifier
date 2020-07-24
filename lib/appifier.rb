# frozen_string_literal: true

# Copyright (C) 2017-2020 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# Base module.
module Appifier
  # @formatter:off
  {
    # components --------------------------------------------------
    BaseCli: 'base_cli',
    Builder: 'builder',
    BuildsLister: 'builds_lister',
    Cli: 'cli',
    Config: 'config',
    Container: 'container',
    DownloadableString: 'downloadable_string',
    PkgFunctions: 'pkg_functions',
    PkgScriptDocker: 'pkg_script_docker',
    PkgScript: 'pkg_script',
    Dockerfile: 'dockerfile',
    Recipe: 'recipe',
    Integration: 'integration',
    JsonPrinter: 'json_printer',
    Mixins: 'mixins',
    Shell: 'shell',
    # system ------------------------------------------------------
    Bundled: 'bundled',
    VERSION: 'version',
  }.each { |s, fp| autoload(s, "#{__dir__}/appifier/#{fp}") }
  # @formatter:on

  include(Bundled).tap do
    require 'bundler/setup' if bundled?

    if Gem::Specification.find_all_by_name('kamaze-project').any?
      require 'kamaze/project/core_ext/pp' if development?
    end
  end

  class << self
    # Get container (inversion of control), almost a service locator.
    #
    # @return [Appifier::Container]
    def container
      Appifier::Container.instance
    end
  end
end
