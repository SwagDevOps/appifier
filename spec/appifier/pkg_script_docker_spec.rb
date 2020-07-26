# frozen_string_literal: true

describe Appifier::PkgScriptDocker, :'appifier/pkg_script_docker' do
  # class methods -------------------------------------------------------------
  it { expect(described_class).to respond_to(:url).with(0).arguments }
  it { expect(described_class).to respond_to(:executable?).with(0).arguments }
end

describe Appifier::PkgScriptDocker, :'appifier/pkg_script_docker' do
  sham(:downloadable_strings).samples['pkg2appimage-with-docker'].tap do |sample|
    let(:described_class) { sample.builder.call }
    let(:subject) { described_class.new(verbose: false) }

    context '#verbose?' do
      it { expect(subject.verbose?).to be(false) }
    end

    # Ensure builder has replaced `url` class method
    { '.url': :described_class, '#url': :subject }.each do |k, v|
      context k do
        it { expect(__send__(v).url).to match(%r{^file://}) }
      end
    end

    context '.executable?' do
      it { expect(described_class.executable?).to be(true) }
    end

    # Compare sample with expected output
    context '#to_s' do
      it { expect(subject.to_s).to eq(sample.output.read) }
    end
  end
end
