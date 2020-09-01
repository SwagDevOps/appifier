# frozen_string_literal: true

# constants -------------------------------------------------------------------
describe Appifier::Scripts, :'appifier/scripts' do
  # @formatter:off
  [
    :Downloadables,
    :Runner,
    :Sequence,
  ].each do |k| # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
