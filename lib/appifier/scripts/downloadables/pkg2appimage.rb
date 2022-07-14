# frozen_string_literal: true

require_relative '../downloadables'

# Downloadable (executable) script
class Appifier::Scripts::Downloadables::Pkg2appimage < Appifier::DownloadableString
  class << self
    def url
      'https://raw.githubusercontent.com/AppImage/pkg2appimage/master/pkg2appimage'
    end

    def replacements
      # @formatter:off
      {
        /^(\s*)if \[ ! -z \$ARCH\]/ => '\\1if [ ! -z "$ARCH" ]',
        /^(\s*OPTIONS="\$OPTIONS -o APT::Architecture=)\$ARCH"/ => "\\1#{apt_arch}\"",
        /^(\s+wget -c)\s+/ => '\\1 --no-check-certificate ',
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
      Appifier.container[:config].fetch('build_arch').yield_self do |s|
        arch_transformer(s).yield_self { |f| ensure_arch!(f.call) }
      end
    end

    # @api private
    #
    # @return [Proc]
    def arch_transformer(arch)
      lambda do
        arch.tap do
          return :amd64 if ['x86_64'].include?(arch)
        end
      end
    end

    # @api private
    #
    # @return [Symbol]
    def ensure_arch!(arch)
      arch.tap do
        %w[amd64 arm64 armhf i386 powerpc ppc64el].tap do |archs|
          raise "Unsupported deb architecture #{s.to_s.inspect}" unless archs.include?(arch.to_s)
        end
      end.to_sym
    end
  end
end
