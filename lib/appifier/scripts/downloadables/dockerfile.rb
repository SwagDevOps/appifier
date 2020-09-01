# frozen_string_literal: true

require_relative '../downloadables'

# Downloadable Dockerfile
class Appifier::Scripts::Downloadables::Dockerfile < Appifier::DownloadableString
  class << self
    def url
      "file://#{Pathname.new(__dir__).join('..', 'resources', 'Dockerfile')}"
    end
  end
end
