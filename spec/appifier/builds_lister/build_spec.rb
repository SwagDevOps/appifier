# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Appifier::BuildsLister::Build, :'appifier/builds_lister/build' do
  it { expect(described_class).to respond_to(:new).with(1).arguments }
end

# instance ----------------------------------------------------------
describe Appifier::BuildsLister::Build, :'appifier/builds_lister/build' do # rubocop:disable Metrics/BlockLength
  let(:subject) do
    sham!(:build_files).randomizer.call.yield_self do |fp|
      described_class.new(fp)
    end
  end

  it { expect(subject).to be_a(Appifier::Mixins::Jsonable) }

  # @formatter:off
  [
    :detail,
    :to_json,
    :as_json,
    :to_path,
    :version?,
    :exist?,
    # attributes
    :name,
    :version,
    :mtime,
    :path,
  ].each do |method|
    # @formatter:on
    it { expect(subject).to respond_to(method) }
  end

  # @formatter:off
  [
    :name,
    :version,
    :mtime,
    :path,
  ].each do |method|
    # @formatter:on
    context "##{method}" do
      it { expect(subject.public_send(method)).to be_frozen }
    end
  end

  context '#path' do
    it { expect(subject.path).to be_a(Pathname) }
  end

  # @formatter:off
  [
    :name,
    :version,
  ].each do |method|
    # @formatter:on
    context "##{method}" do
      it { expect(subject.public_send(method)).to be_a(String) }
    end
  end

  # @formatter:off
  [
    :version?,
    :exist?,
  ].each do |method|
    # @formatter:on
    context "##{method}" do
      it { expect(subject.public_send(method)).to be_boolean }
    end
  end
end
