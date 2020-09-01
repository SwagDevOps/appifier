# frozen_string_literal: true

require_relative '../scripts'

# Namespace module (grouping downloadables).
module Appifier::Scripts::Downloadables
  # @formatter:off
  {
    Pkg2appimage: 'pkg2appimage',
    FunctionsSh: 'functions_sh',
    Pkg2appimageWithDocker: 'pkg2appimage_with_docker',
    Dockerfile: 'dockerfile',
  }.each { |s, fp| autoload(s, "#{__dir__}/downloadables/#{fp}") }
  # @formatter:on
end
