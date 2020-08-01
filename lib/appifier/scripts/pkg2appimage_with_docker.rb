# frozen_string_literal: true

require_relative '../scripts'

# Downloadable (executable) script
class Appifier::Scripts::Pkg2appimageWithDocker < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/pkg2appimage-with-docker'
    end

    def replacements
      # @formatter:off
      {
        /^(\s*)(\$ARGS)\s*\\/ => [
          '\\1-v "$(readlink -f functions.sh):/workspace/functions.sh:ro" \\',
          '\\1-e ARCH="${ARCH:-x86_64}" \\',
          '\\1\\2 \\',
        ].join("\n"),
      }
      # @formatter:on
    end

    def executable?
      true
    end
  end
end
