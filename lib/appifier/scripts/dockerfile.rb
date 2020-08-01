# frozen_string_literal: true

require_relative '../scripts'

# Downloadable Dockerfile
class Appifier::Scripts::Dockerfile < Appifier::DownloadableString
  class << self
    def url
      "file://#{Pathname.new(__dir__).join('resources', 'Dockerfile')}"
    end
  end
end
