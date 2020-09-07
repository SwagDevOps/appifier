# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Appifier::Cli::Runner, :'appifier/cli/runner' do
  it { expect(described_class).to respond_to(:new).with(0).arguments }
  it { expect(described_class).to respond_to(:new).with(0).arguments.and_any_keywords }
  it { expect(described_class).to respond_to(:new).with(1).arguments }
  it { expect(described_class).to respond_to(:new).with(1).arguments.and_any_keywords }
end

# rubocop:disable Metrics/BlockLength
describe Appifier::Cli::Runner, :'appifier/cli/runner' do
  let(:container) do
    # @formatter:off
    {
      verbose: false
    }.freeze
    # @formatter:on
  end

  let(:options) do
    # @formatter:off
    {
      verbose: true
    }
    # @formatter:on
  end

  let(:optionizer) do
    -> { described_class.__send__(:optionize, container, options) }
  end

  context '.optionize' do
    it { expect(optionizer.call).to be_a(Hash) }
    it { expect(optionizer.call).to eq(options) }
    it { expect(optionizer.call).to be_frozen }

    it 'is expected to do not alter container' do
      container.object_id.tap do |id|
        optionizer.call

        expect(container).to be_frozen
        expect(container).to eq({ verbose: false })
        expect(container.object_id).to eq(id)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

describe Appifier::Cli::Runner, :'appifier/cli/runner' do
  let(:container) do
    # @formatter:off
    {
      verbose: false
    }
    # @formatter:on
  end

  let(:options) do
    # @formatter:off
    {
      verbose: true
    }
    # @formatter:on
  end

  let(:optionizer) do
    -> { described_class.__send__(:optionize, container, options) }
  end

  context '.optionize' do
    it { expect(optionizer.call).to be_a(Hash) }
    it { expect(optionizer.call).to eq({}) }
    it { expect(optionizer.call).to be_frozen }

    it 'is expected to alter container' do
      container.object_id.tap do |id|
        optionizer.call

        expect(container).to eq({ verbose: true })
        expect(container.object_id).to eq(id)
      end
    end
  end
end

# instance methods ---------------------------------------------------
describe Appifier::Cli::Runner, :'appifier/cli/runner' do
  it { expect(subject).to respond_to(:build).with(1).arguments }
  it { expect(subject).to respond_to(:config).with(0).arguments }
end
