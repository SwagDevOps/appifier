# frozen_string_literal: true

describe Appifier::Scripts::Downloadables, :'appifier/scripts/downloadables' do
  # @formatter:off
  [
    :Pkg2appimage,
    :FunctionsSh,
    :Pkg2appimageWithDocker,
    :Dockerfile,
  ].each do |k| # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
