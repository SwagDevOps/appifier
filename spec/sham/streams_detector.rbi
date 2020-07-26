# frozen_string_literal: true

# Create a mock for ``Ambix::Inspector::StreamsDetector``
#
# @see Ambix::Inspector::StreamsDetector#capture
# @see Ambix::Inspector::StreamsDetector#prepare_outputs
mocker = lambda do |info_name|
  Class.new(Ambix::Inspector::StreamsDetector).tap do |klass|
    klass.define_method(:capture) do |_file|
      # @formatter:off
      return sham!(:samples)
             .info
             .fetch(info_name.to_sym)
             .text
             .lines
             .keep_if { |line| line =~ /^\s*Stream\s+#[0-9]/ }
             .map(&:strip)
      # @formatter:on
    end

    klass.define_method(:prepare_outputs) do |container|
      {}.tap do |cache|
        cache.singleton_class.define_method(:[]) do |key|
          cache[key.to_s] = container.__send__(:capture, key)
        end
      end
    end
  end.tap(&:new).new
end

Sham.config(FactoryStruct, File.basename(__FILE__, '.*').to_sym) do |c|
  c.attributes do
    # @formatter:off
    {
      mocker: mocker
    }
    # @formatter:on
  end
end
