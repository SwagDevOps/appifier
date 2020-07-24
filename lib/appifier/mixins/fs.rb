# frozen_string_literal: true

require_relative '../mixins'
autoload(:FileUtils, 'fileutils')

# Mixin to expose ``FileUtils`` verbose (or note) depending on container status.
module Appifier::Mixins::Fs
  protected

  # @return [FileUtils]
  def fs
    (self.respond_to?(:container) ? container : Appifier.container).resolve(:fs)
  end
end
