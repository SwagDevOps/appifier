# frozen_string_literal: true

describe Appifier::Scripts::Sequence, :'appifier/scripts/sequence' do
  # @formatter:off
  {
    false => [
      Appifier::Scripts::Downloadables::Pkg2appimage,
      Appifier::Scripts::Downloadables::FunctionsSh,
      Appifier::Scripts::Downloadables::ExcludeList,
    ],
    true => [
      Appifier::Scripts::Downloadables::Pkg2appimageWithDocker,
      Appifier::Scripts::Downloadables::Dockerfile,
      Appifier::Scripts::Downloadables::Pkg2appimage,
      Appifier::Scripts::Downloadables::FunctionsSh,
      Appifier::Scripts::Downloadables::ExcludeList,
    ],
  }.each do |k, v|
    # @formatter:on
    context ".new(#{k.inspect})" do
      it { expect(described_class.new(k)).to eq(v) }
    end
  end
end
