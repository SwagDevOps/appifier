# frozen_string_literal: true

require_relative '../builds_lister'
autoload(:Pathname, 'pathname')

# Describe a scan result.
#
# @see Appifier::BuildsLister#call
class Appifier::BuildsLister::ScanResult < ::Hash
  # @param [Array<Appifier::BuildsLister::Build>] builds
  def initialize(builds)
    builds.keep_if(&:version?).each do |item|
      self[item.name] = self[item.name].to_a.concat([item])
    end
  end

  # Get builds indexed by names with versions.
  #
  # Versions are used as indexes.
  # Get only arrays of versions, when ``paths`` is false.
  #
  # @return [Hash{String => Hash{String => Appifier::BuildsLister::Build}}]
  # @return [Hash{String => Array<String>}]
  def versionned(paths = true)
    {}.tap do |h|
      self.each do |k, v|
        h[k] ||= {}
        v.each do |build|
          h[k][build.version] = build.freeze
        end
      end

      h.each { |k, v| h[k] = v.keys.freeze } unless paths
    end
  end
end
