# frozen_string_literal: true

require_relative '../appifier'

# Downloadable (executable) script
class Appifier::PkgScript < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/pkg2appimage'
    end

    def executable?
      true
    end
  end
end
