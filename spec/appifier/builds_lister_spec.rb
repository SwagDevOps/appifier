# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Appifier::BuildsLister, :'appifier/builds_lister' do
  # @formatter:off
  [
    :Build,
  ].each do |k|
    # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
