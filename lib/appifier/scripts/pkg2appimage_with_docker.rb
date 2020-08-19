# frozen_string_literal: true

require_relative '../scripts'
autoload(:Pathname, 'pathname')

# Downloadable (executable) script
class Appifier::Scripts::Pkg2appimageWithDocker < Appifier::DownloadableString
  class << self
    def url
      Pathname.new(__FILE__).yield_self do |fp|
        "file://#{fp.dirname.join('resources', fp.basename('.*').to_s.gsub('_', '-'))}"
      end
    end

    def executable?
      true
    end
  end
end
