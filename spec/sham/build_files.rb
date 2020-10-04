# frozen_string_literal: true

autoload(:Pathname, 'pathname')
autoload(:SecureRandom, 'securerandom')

filename_pattern = '%<app_name>s-4.2.2.glibc2.16-x86_64.AppImage'

# @formatter:off
{
  randomizer: lambda do |app_name = 'App'|
    (filename_pattern % { app_name: app_name }).yield_self do |filename|
      Pathname.new('/').join(SecureRandom.hex, filename)
    end
  end,
}
# @formatter:on
