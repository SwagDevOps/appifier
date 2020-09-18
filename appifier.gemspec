# frozen_string_literal: true
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all

Gem::Specification.new do |s|
  s.name        = "appifier"
  s.version     = "0.0.1"
  s.date        = "2020-06-15"
  s.summary     = "Simple wrapper built on top of pkg2appimage"
  s.description = "Simplify AppImage creation with a wrapper on top of pkg2appimage"

  s.licenses    = ["GPL-3.0"]
  s.authors     = ["Dimitri Arrigoni"]
  s.email       = "dimitri@arrigoni.me"
  s.homepage    = "https://github.com/SwagDevOps/appifier"

  # MUST follow the higher required_ruby_version
  # requires version >= 2.3.0 due to safe navigation operator &
  # requires version >= 2.5.0 due to yield_self
  s.required_ruby_version = ">= 2.5.0"
  s.require_paths = ["lib"]
  s.files         = [
    ".yardopts",
    "bin/appifier",
    "lib/appifier.rb",
    "lib/appifier/base_cli.rb",
    "lib/appifier/base_cli/core.rb",
    "lib/appifier/builder.rb",
    "lib/appifier/builds_lister.rb",
    "lib/appifier/builds_lister/build.rb",
    "lib/appifier/builds_lister/scan_result.rb",
    "lib/appifier/bundled.rb",
    "lib/appifier/cli.rb",
    "lib/appifier/cli/runner.rb",
    "lib/appifier/config.rb",
    "lib/appifier/container.rb",
    "lib/appifier/container/config.rb",
    "lib/appifier/downloadable_string.rb",
    "lib/appifier/file_system.rb",
    "lib/appifier/file_url.rb",
    "lib/appifier/integration.rb",
    "lib/appifier/integration/builds_list.rb",
    "lib/appifier/integration/desktop.rb",
    "lib/appifier/integration/extraction.rb",
    "lib/appifier/integration/install.rb",
    "lib/appifier/integration/install/desktop_builder.rb",
    "lib/appifier/json_printer.rb",
    "lib/appifier/logged_runner.rb",
    "lib/appifier/mixins.rb",
    "lib/appifier/mixins/hash_glob.rb",
    "lib/appifier/mixins/inject.rb",
    "lib/appifier/mixins/jsonable.rb",
    "lib/appifier/mixins/shell.rb",
    "lib/appifier/mixins/verbose.rb",
    "lib/appifier/recipe.rb",
    "lib/appifier/recipes/caprine.yml",
    "lib/appifier/recipes/chromium_canary.yml",
    "lib/appifier/recipes/ffmpeg.yml",
    "lib/appifier/recipes/ffmpeg_git.yml",
    "lib/appifier/recipes/gitkraken.yml",
    "lib/appifier/recipes/insomnia.yml",
    "lib/appifier/recipes/mailspring.yml",
    "lib/appifier/recipes/molotov.yml",
    "lib/appifier/recipes/notes.yml",
    "lib/appifier/recipes/rocketchat.yml",
    "lib/appifier/recipes/rubymine.yml",
    "lib/appifier/scripts.rb",
    "lib/appifier/scripts/downloadables.rb",
    "lib/appifier/scripts/downloadables/dockerfile.rb",
    "lib/appifier/scripts/downloadables/functions_sh.rb",
    "lib/appifier/scripts/downloadables/pkg2appimage.rb",
    "lib/appifier/scripts/downloadables/pkg2appimage_with_docker.rb",
    "lib/appifier/scripts/resources/Dockerfile",
    "lib/appifier/scripts/resources/pkg2appimage-with-docker",
    "lib/appifier/scripts/runner.rb",
    "lib/appifier/scripts/sequence.rb",
    "lib/appifier/shell.rb",
    "lib/appifier/uninstaller.rb",
    "lib/appifier/uninstaller/lister.rb",
    "lib/appifier/version.rb",
    "lib/appifier/version.yml",
  ]

  s.add_runtime_dependency("deep_dup", ["~> 0.0.3"])
  s.add_runtime_dependency("dry-container", ["~> 0.4"])
  s.add_runtime_dependency("iniparser", ["~> 1.0"])
  s.add_runtime_dependency("kamaze-version", ["~> 1.0"])
  s.add_runtime_dependency("liquid", ["~> 4.0"])
  s.add_runtime_dependency("rouge", ["~> 3.21"])
  s.add_runtime_dependency("sys-proc", ["~> 1.1"])
  s.add_runtime_dependency("thor", ["~> 1.0"])

  s.bindir = "bin"
  s.executables = [
    "appifier",
  ]
end

# Local Variables:
# mode: ruby
# End:
