# frozen_string_literal: true

require_relative '../integration'

autoload(:Pathname, 'pathname')

# Describe a desktop file.
class Appifier::Integration::Desktop < Pathname
  autoload(:IniParser, 'iniparser')

  # @param [String|Pathname] dir
  def initialize(dir)
    Dir.glob("#{dir}/*.desktop").fetch(0).yield_self { |fp| super(fp) }
  end

  # @return [Hash]
  def parse
    IniParser::Parser.new(read).parse
  end

  alias to_h parse

  # @return [Hash]
  def entry
    parse.fetch('Desktop Entry')
  end

  # rubocop:disable Metrics/MethodLength

  # Alter original content with given values.
  #
  # @return [String]
  def alter(dir:, icon:, exec_params:)
    [].tap do |lines|
      self.to_h.each do |section_title, section|
        lines << "[#{section_title}]"
        section.each do |k, v|
          if %w[Exec Icon TryExec].include?(k)
            lines << "#{k}=#{dir.join('app')} #{exec_params.join(' ')}".rstrip if k == 'Exec'
            lines << "#{k}=#{icon.realpath}" if k == 'Icon'
            lines << nil if k == 'TryExec'

            next
          end

          lines << "#{k}=#{v}"
        end
      end
    end.compact.join("\n")
  end

  # rubocop:enable Metrics/MethodLength
end
