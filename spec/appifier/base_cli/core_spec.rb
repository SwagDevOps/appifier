# frozen_string_literal: true

autoload(:Thor, 'thor')

# class methods -----------------------------------------------------
describe Appifier::BaseCli::Core, :'appifier/base_cli', :'appifier/base_cli/core' do
  # @formatter:off
  [
    :ErrorHandler,
  ].each do |k|
    # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end

  # SHOULD be a (direct) descendant of Thor
  context '.ancestors' do
    it { expect(described_class.ancestors).to include(Thor) }
  end

  :exit_on_failure?.tap do |method|
    it { expect(described_class).to respond_to(method).with(0).arguments }

    context ".#{method}" do
      it { expect(described_class.public_send(method)).to be(true) }
    end
  end
end
