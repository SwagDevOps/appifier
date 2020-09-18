# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Appifier::FileSystem, :'appifier/file_system' do
  # dynamic include class SHOULD not include any module
  [:ancestors, :included_modules].each do |method|
    sham!(:fs).types.each do |_, mod|
      context ".#{method}" do
        it { expect(described_class.public_send(method)).not_to include(mod) }
      end
    end
  end

  [0, 1].each do |n|
    it { expect(described_class).to respond_to(:new).with(n).arguments }
  end

  sham!(:fs).types.merge({ nil => FileUtils }).each do |type, mod|
    context ".new(#{type.inspect})" do
      it { expect(described_class.new(type)).to be_a(mod) }
    end
  end

  context '.types' do
    it { expect(described_class.__send__(:types)).to be_a(Hash) }
    it { expect(described_class.__send__(:types)).to eq(sham!(:fs).types) }
  end
end

# instance methods --------------------------------------------------
describe Appifier::FileSystem, :'appifier/file_system' do
  sham!(:fs).types.each do |type, _|
    sham(:fs).module_methods.each do |k, f|
      context ".new(#{type.inspect})#method(#{k.inspect}).parameters" do
        let(:subject) { described_class.new(type) }
        let(:expected) { f.call(subject, k).parameters }

        it { expect(subject.method(k).parameters).to eq(expected) }
      end
    end
  end
end
