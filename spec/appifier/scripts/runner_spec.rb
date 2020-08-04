# frozen_string_literal: true

describe Appifier::Scripts::Runner, :'appifier/scripts/runner' do
  it { expect(described_class).to respond_to(:new).with_any_keywords }
  # instance methods ----------------------------------------------------------
  it { expect(subject).to respond_to(:call).with(1).arguments.and_keywords(:docker) }
end
