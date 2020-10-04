# frozen_string_literal: true

require_relative '../appifier'

# Command wrapper on top of ``update-desktop-database`` binary executable.
#
# @see http://transit.iut2.upmf-grenoble.fr/cgi-bin/man/man2html?1+update-desktop-database
# @see Appifier::Uninstaller#call
# @see Appifier::Integration::Install#call
class Appifier::DesktopDatabaseUpdater
  include(Appifier::Mixins::Inject)

  def initialize(**kwargs)
    # @formatter:off
    {
      shell: kwargs[:shell],
      config: kwargs[:config],
      logged_runner: kwargs[:logged_runner],
    }.yield_self { |injection| inject(**injection) }.assert { !values.include?(nil) }
    # @formatter:on
  end

  def call(logname: nil)
    ['update-desktop-database', '-q', config.fetch('desktops_dir').to_s].yield_self do |command|
      logname ? logged_runner.call({ logname => [command] }) : shell.sh(*command)
    rescue Exception => e # rubocop:disable Lint/RescueException
      warn(e)
    end
  end

  protected

  # @return [Hash]
  # @return [Appifier::Config]
  attr_reader :config

  # @return [Appifier::LoggedRunner]
  attr_reader :logged_runner

  # @return [Appifier:Shell]
  attr_reader :shell
end
