# frozen_string_literal: true

require_relative '../appifier'

# File supposed to be sourced by each Recipe
#
# @see https://github.com/AppImage/pkg2appimage/blob/678e5e14122f14a12c54847213585ea803e1f0e1/functions.sh
# @see https://github.com/AppImage/AppImageKit/issues/1060
class Appifier::PkgFunctions < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/functions.sh'
    end

    # Realease target.
    #
    # @return [String]
    # @see https://github.com/AppImage/AppImageKit/releases
    def release
      12.to_s
    end

    def replacements
      # rubocop:disable Layout/LineLength
      # @formatter:off
      {
        %r{(https://github\.com/AppImage/AppImageKit/releases/download)/continuous/(AppRun-|appimagetool-)} => "\\1/#{release}/\\2",
      }
      # @formatter:on
      # rubocop:enable Layout/LineLength
    end
  end
end
