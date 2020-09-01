# frozen_string_literal: true

# rubocop:disable Layout/LineLength
autoload(:Pathname, 'pathname')

describe Appifier::Scripts::Downloadables::Pkg2appimageWithDocker, :'appifier/scripts/downloadables/pkg2appimage_with_docker' do
  # class methods -------------------------------------------------------------
  it { expect(described_class).to respond_to(:url).with(0).arguments }
  it { expect(described_class).to respond_to(:executable?).with(0).arguments }

  context '.executable?' do
    it { expect(described_class.executable?).to be(true) }
  end

  context '.url' do
    it { expect(described_class.url).to be_a(String) }
  end

  context '.replacements' do
    it { expect(described_class.replacements).to be_a(Hash) }
    it { expect(described_class.replacements).to be_empty }
  end
end

describe Appifier::Scripts::Downloadables::Pkg2appimageWithDocker, :'appifier/scripts/downloadables/pkg2appimage_with_docker' do
  sham(:downloadable_strings).samples['pkg2appimage-with-docker'].tap do |sample|
    let(:fake_class) { sample.builder.call }
    let(:subject) { fake_class.new }
    let(:output) { sample.output }
  end

  # Ensure builder has replaced `url` class method
  { '.url': :fake_class, '#url': :subject }.each do |k, v|
    context k do
      it { expect(__send__(v).url).to match(%r{^file://}) }
    end
  end

  # Compare sample with expected output
  context '#to_s' do
    it { expect(subject.to_s).to eq(output.read) }
  end
end

describe Appifier::Scripts::Downloadables::Pkg2appimageWithDocker, :'appifier/scripts/downloadables/pkg2appimage_with_docker' do
  sham(:downloadable_strings).samples['pkg2appimage-with-docker'].tap do |sample|
    let(:fake_class) { sample.builder.call }
    let(:subject) { fake_class.new }
    let(:output) { sample.output }
  end

  context '#verbose?' do
    it { expect(subject.verbose?).to be(false) }
  end

  context '#executable?' do
    it { expect(subject.executable?).to eq(described_class.executable?) }
  end

  context '#url' do
    it { expect(subject.url).to eq(fake_class.url) }
  end

  context '#to_path' do
    it { expect(subject.to_path).to be_a(String) }

    it do
      'pkg2appimage-with-docker'.tap do |fname|
        expect(subject.to_path).to match(%r{/#{fname}$})
        expect(subject.to_path).to eq(Pathname.new(Dir.pwd).join(fname).to_s)
      end
    end
  end
end
# rubocop:enable Layout/LineLength
