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
    Bundleable: 'bundleable',
    Cli: 'cli',
    Config: 'config',
    Container: 'container',
    DesktopDatabaseUpdater: 'desktop_database_updater',
    DownloadableString: 'downloadable_string',
    Filesize: 'filesize',
    FileSystem: 'file_system',
    Recipe: 'recipe',
    Scripts: 'scripts',
    Integration: 'integration',
    JsonPrinter: 'json_printer',
    LoggedRunner: 'logged_runner',
    Mixins: 'mixins',
    Uninstaller: 'uninstaller',
    Shell: 'shell',
    # system ------------------------------------------------------
    Bundled: 'bundled',
    VERSION: 'version',
  }.each { |s, fp| autoload(s, "#{__dir__}/appifier/#{fp}") }
  # @formatter:on

  include(Bundleable)

  class << self
    # Get container (inversion of control), almost a service locator.
    #
    # @return [Appifier::Container]
    def container
      Appifier::Container.instance
    end
  end
end
