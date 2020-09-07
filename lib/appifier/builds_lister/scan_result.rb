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
  # Get only arrays of versions, when ``with_details`` is false.
  #
  # @return [Hash{String => Hash{String => Appifier::BuildsLister::Build}}]
  # @return [Hash{String => Array<String>}]
  def catalog(with_details: true)
    {}.tap do |h|
      self.each do |k, v|
        h[k] ||= {}
        v.each do |build|
          h[k][build.version.freeze] = build.freeze
        end
      end

      h.each { |k, v| h[k] = v.keys.freeze } unless with_details
    end.sort.to_h.transform_values(&:freeze)
  end
end