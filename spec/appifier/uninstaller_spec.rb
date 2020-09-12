# frozen_string_literal: true

describe Appifier::Uninstaller, :'appifier/uninstaller' do
  # @formatter:off
  [
    :Lister,
  ].each do |k|
    # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
