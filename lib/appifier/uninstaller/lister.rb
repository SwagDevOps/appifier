# frozen_string_literal: true

require_relative '../uninstaller'

# List builds.
#
# Builds are indexed by name and sorted by mtime.
class Appifier::Uninstaller::Lister
  include(Appifier::Mixins::Inject)

  def initialize(**kwargs)
    inject(config: kwargs[:config]).assert { !values.include?(nil) }
  end

  def call
    index
  end

  protected

  attr_reader :config

  # Get symlinks from config.
  #
  # @return [Array<Pathname>]
  def symlinks # rubocop:disable Metrics/AbcSize
    [config['desktops_dir'], config['bin_dir']].map do |dir|
      Dir.chdir(dir) do
        Pathname.new(dir).entries.reject(&:directory?).keep_if(&:symlink?).map { |fname| Pathname.new(dir).join(fname) }
      end
    end.flatten.sort.keep_if do |fp|
      /^#{config['applications_dir']}.*/.match(File.readlink(fp.to_s))
    end.sort_by { |fp| File.readlink(fp.to_s) }
  end

  # Get uninstallable items indexed by application name.
  #
  # @return [Hash{String => Array<Pathname>}]
  def index
    {}.tap do |result|
      symlinks.each do |fp|
        Pathname.new(File.readlink(fp.to_s)).dirname.basename.to_s.tap do |k|
          result[k] ||= [Pathname.new(File.readlink(fp.to_s)).dirname]
          result[k].push(fp)
        end
      end
    end
  end
end
