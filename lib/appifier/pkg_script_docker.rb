# frozen_string_literal: true

require_relative '../appifier'

# Downloadable (executable) script
class Appifier::PkgScriptDocker < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/pkg2appimage-with-docker'
    end

    def executable?
      true
    end
  end
end
