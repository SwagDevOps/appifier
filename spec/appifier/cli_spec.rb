# frozen_string_literal: true

describe Appifier::Cli, :'appifier/cli' do
  # @formatter:off
  [
    :Runner,
  ].each do |k|
    # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end

  it { expect(described_class).to respond_to(:commands).with(0).arguments }

  context '.commands' do
    it { expect(described_class.commands).to be_a(Hash) }
  end

  [:build, :config].each do |command_name|
    context ".commands[#{command_name.inspect}]" do
      it { expect(described_class.commands[command_name]).to be_a(Hash) }
    end
  end
end
