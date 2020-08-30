# frozen_string_literal: true

# class methods -----------------------------------------------------
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

# instance methods --------------------------------------------------
describe Appifier::Cli, :'appifier/cli' do
  [0, 1, 2].each do |n|
    it { expect(subject).to respond_to(:call).with(n).arguments }
  end

  context '#method(:call)' do
    it { expect(subject.method(:call)).to eq(subject.method(:start)) }
  end

  context '#commands' do
    it { expect(subject.__send__(:commands)).to be_a(Hash) }
  end

  context '#commands.keys' do
    it { expect(subject.__send__(:commands).keys).to eq(described_class.commands.keys) }
  end

  described_class.commands.each_key do |k|
    # @formatter:off
    {
      usage: String,
      desc: String,
      options: Hash,
      method: Proc,
    }.each do |name, type| # @formatter:on
      context "#commands.fetch(#{k.inspect})[:usage]" do
        it { expect(subject.__send__(:commands).fetch(k)[name]).to be_a(type) }
      end
    end
  end
end
