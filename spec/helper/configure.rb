# frozen_string_literal: true

RSpec.configure do |rspec|
  # @see https://github.com/rspec/rspec-core/issues/2246
  rspec.around(:example) do |example|
    example.run
  rescue SystemExit => e
    raise "Unhandled SystemExit (#{e.status})"
  end
end
