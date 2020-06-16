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
    Builder: 'builder',
    Cli: 'cli',
    Config: 'config',
    DownloadableString: 'downloadable_string',
    PkgScriptDocker: 'pkg_script_docker',
    PkgScript: 'pkg_script',
    Dockerfile: 'dockerfile',
    Shell: 'shell',
    # system ------------------------------------------------------
    Bundled: 'bundled',
    VERSION: 'version',
  }.each { |s, fp| autoload(s, "#{__dir__}/appifier/#{fp}") }
  # @formatter:on

  include(Bundled).tap do
    require 'bundler/setup' if bundled?
    require 'kamaze/project/core_ext/pp' if development?
  end
end
