# frozen_string_literal: true

describe Appifier::Scripts::Runner, :'appifier/scripts/runner' do
  it { expect(described_class).to respond_to(:new).with_any_keywords }
  # instance methods ----------------------------------------------------------
  it { expect(subject).to respond_to(:call).with(1).arguments.and_keywords(:docker) }

  # @formatter:off
  {
    false => [Appifier::Scripts::Pkg2appimage, Appifier::Scripts::FunctionsSh],
    true => [
      Appifier::Scripts::Pkg2appimageWithDocker,
      Appifier::Scripts::Dockerfile,
      Appifier::Scripts::Pkg2appimage,
      Appifier::Scripts::FunctionsSh
    ],
  }.each do |k, v| # @formatter:on
    context "#sequence(#{k.inspect})" do
      it { expect(subject.__send__(:sequence, k)).to eq(v) }
    end
  end
end
