# frozen_string_literal: true

require_relative '../downloadables'
autoload(:Pathname, 'pathname')

# Downloadable (executable) script
class Appifier::Scripts::Downloadables::ExcludeList < Appifier::DownloadableString
  class << self
    def url
      Pathname.new(__FILE__).yield_self do |fp|
        "file://#{fp.dirname.join('..', 'resources', 'excludelist')}"
      end
    end

    def executable?
      false
    end
  end
end
