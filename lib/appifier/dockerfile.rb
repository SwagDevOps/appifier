# frozen_string_literal: true

require_relative '../appifier'

# Downloadable Dockerfile
class Appifier::Dockerfile < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/Dockerfile'
    end
  end
end
