# frozen_string_literal: true

describe Appifier, :appifier do
  # @formatter:off
  [
    :Bundled,
    :VERSION,
  ].each do |k| # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
