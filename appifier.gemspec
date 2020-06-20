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
    "bin/appify",
    "lib/appifier.rb",
    "lib/appifier/Dockerfile",
    "lib/appifier/builder.rb",
    "lib/appifier/bundled.rb",
    "lib/appifier/cli.rb",
    "lib/appifier/config.rb",
    "lib/appifier/dockerfile.rb",
    "lib/appifier/downloadable_string.rb",
    "lib/appifier/pkg_script.rb",
    "lib/appifier/pkg_script_docker.rb",
    "lib/appifier/recipes/caprine.yml",
    "lib/appifier/recipes/chromium_canary.yml",
    "lib/appifier/recipes/gitkraken.yml",
    "lib/appifier/recipes/insomnia.yml",
    "lib/appifier/recipes/mailspring.yml",
    "lib/appifier/recipes/rocketchat.yml",
    "lib/appifier/recipes/rubymine.yml",
    "lib/appifier/shell.rb",
    "lib/appifier/version.rb",
    "lib/appifier/version.yml",
  ]

  

  s.bindir = "bin"
  s.executables = [
    "appify",
  ]
end

# Local Variables:
# mode: ruby
# End:
