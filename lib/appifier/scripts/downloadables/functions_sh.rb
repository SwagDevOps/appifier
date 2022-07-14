# frozen_string_literal: true

require_relative '../downloadables'

# File supposed to be sourced by each Recipe
#
# @see https://github.com/AppImage/pkg2appimage/blob/678e5e14122f14a12c54847213585ea803e1f0e1/functions.sh
# @see https://github.com/AppImage/AppImageKit/issues/1060
class Appifier::Scripts::Downloadables::FunctionsSh < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/functions.sh'
    end

    # Realease target.
    #
    # @return [String]
    # @return [Integer, Symbol]
    # @see https://github.com/AppImage/AppImageKit/releases
    # @see https://github.com/AppImage/AppImageKit/issues/1060
    def release
      Appifier.container[:config].fetch('appimagekit_release')
    end

    def replacements
      # rubocop:disable Layout/LineLength
      # @formatter:off
      {
        %r{(https://github\.com/AppImage/AppImageKit/releases/download)/continuous/(AppRun-|appimagetool-)} => "\\1/#{release}/\\2",
        /^(\s+wget -c)\s+/ => '\\1 --no-check-certificate ',
      }
      # @formatter:on
      # rubocop:enable Layout/LineLength
    end
  end
end
