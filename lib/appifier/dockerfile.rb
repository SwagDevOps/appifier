# frozen_string_literal: true

require_relative '../appifier'

# Downloadable Dockerfile
class Appifier::Dockerfile < Appifier::DownloadableString
  class << self
    def url
      "file://#{Pathname.new(__dir__).join('Dockerfile')}"
    end
  end
end
