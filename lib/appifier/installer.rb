# frozen_string_literal: true

require_relative '../appifier'

# Installer
class Appifier::Installer
  # @param [String] pattern
  #
  # @return [Hash{String => Array}, nil]
  # @return [Hash]
  def call(pattern)
    lister.call.glob(pattern).tap do |result|
      result.map { |_, v| v }.flatten.each do |fp|
        fs.public_send("rm_#{fp.directory? ? :r : nil}f", fp)
      end
    end.tap do |result|
      return nil if result.empty?
    end
  end

  protected

  # @return [Appifier::FileSystem]
  # @return [FileUtils]
  attr_reader :fs

  # @return [Appifier::Uninstaller::Lister]
  attr_reader :lister
end
