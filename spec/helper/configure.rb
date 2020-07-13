# frozen_string_literal: true

autoload(:Pathname, 'pathname')
autoload(:Sham, 'sham')
require_relative 'local'

Sham::Config.activate!(Pathname.new(__dir__).join('..').realpath)

Object.class_eval { include Local }

RSpec.configure do |rspec|
  # @see https://github.com/rspec/rspec-core/issues/2246
  rspec.around(:example) do |example|
    example.run
  rescue SystemExit => e
    raise "Unhandled SystemExit (#{e.status})"
  end
end
