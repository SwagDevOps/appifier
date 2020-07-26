# frozen_string_literal: true

autoload(:ERB, 'erb')

# class methods -------------------------------------------------------------
describe Appifier::DownloadableString, :'appifier/downloadable_string' do
  it { expect(described_class).to respond_to(:url).with(0).arguments }
  it { expect(described_class).to respond_to(:executable?).with(0).arguments }
  it { expect(described_class).to respond_to(:replacements).with(0).arguments }
end

describe Appifier::DownloadableString, :'appifier/downloadable_string' do # rubocop:disable Metrics/BlockLength
  # @type [Appifier::DownloadableString] subject
  # @type [Class<Appifier::DownloadableString>] fake_class
  sham(:downloadable_strings).builder.tap do |builder|
    let(:fake_class) { builder.call }
    let(:subject) { fake_class.new }
  end

  it { expect(subject).to respond_to(:call).with(0).arguments }

  { '.url': :fake_class, '#url': :subject }.each do |k, v|
    k.to_s.gsub(/^\.|#/, '').to_sym.tap do |method|
      it { expect(public_send(v)).to respond_to(method).with(0).arguments }
      context k do
        it { expect(public_send(v).public_send(method)).to be_a(String) }
        it do
          "file://#{__FILE__.split('/').map { |s| s ? ERB::Util.url_encode(s) : s }.join('/')}".yield_self do |url|
            expect(public_send(v).public_send(method)).to eq(url)
          end
        end
      end
    end
  end

  { '.executable?': :fake_class, '#executable?': :subject }.each do |k, v|
    k.to_s.gsub(/^\.|#/, '').to_sym.tap do |method|
      it { expect(public_send(v)).to respond_to(method).with(0).arguments }
      context k do
        it { expect(public_send(v).public_send(method)).to be(false) }
      end
    end
  end

  :replacements.tap do |method|
    it { expect(fake_class).to respond_to(method).with(0).arguments }
    context ".#{method}" do
      it { expect(fake_class.public_send(method)).to be_a(Hash) }
      it { expect(fake_class.public_send(method)).to be_empty }
    end
  end
end
