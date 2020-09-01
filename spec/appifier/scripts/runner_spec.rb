# frozen_string_literal: true

describe Appifier::Scripts::Runner, :'appifier/scripts/runner' do
  # instance methods ----------------------------------------------------------
  it { expect(subject).to respond_to(:call).with(1).arguments.and_keywords(:docker) }

  # inject --------------------------------------------------------------------
  it { expect(subject).to be_a(Appifier::Mixins::Inject) }
  it { expect(described_class).to respond_to(:new).with_any_keywords }

  context '#logged_runner' do
    it { expect(subject.__send__(:logged_runner)).to be_a(Appifier::LoggedRunner) }
  end
end
