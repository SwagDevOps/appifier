# frozen_string_literal: true

require_relative '../appifier'

# Downloadable (executable) script
class Appifier::PkgScript < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/pkg2appimage'
    end

    def replacements
      # @formatter:off
      {
        /^(\s*)if \[ ! -z \$ARCH\]/ => '\\1if [ ! -z "$ARCH" ]',
        /^(\s*OPTIONS="\$OPTIONS -o APT::Architecture=)\$ARCH"/ => "\\1#{apt_arch}\""
      }
      # @formatter:on
    end

    def executable?
      true
    end

    protected

    # @api private
    #
    # @return [Symbol]
    def apt_arch
      Appifier::Config.new.fetch('build_arch').yield_self do |s|
        return :amd64 if ['x86_64'].include?(s)

        raise 'Add arch to match deb architectures (amd64 arm64 armhf i386 powerpc ppc64el)'
      end
    end
  end
end
