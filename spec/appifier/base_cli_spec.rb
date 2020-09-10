# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Appifier::BaseCli, :'appifier/base_cli' do
  # @formatter:off
  [
    :Core,
  ].each do |k|
    # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end

  :commands.tap do |method|
    it { expect(described_class).to respond_to(method).with(0).arguments }

    context ".#{method}" do
      it { expect(described_class.public_send(method)).to be_a(Hash) }
    end
  end
end
