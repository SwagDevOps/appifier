# frozen_string_literal: true

autoload(:ERB, 'erb')

# Builder
builder = lambda do |file = nil, described_class: nil|
  file ||= caller_locations.map(&:absolute_path).compact.fetch(0)

  Class.new(described_class || __send__(:described_class)) do
    singleton_class.class_eval do
      autoload(:URI, 'uri')

      define_method('url') do
        file.split('/').map { |s| s ? ERB::Util.url_encode(s) : s }.join('/').yield_self do |url|
          "file://#{url}"
        end
      end
    end
  end
end

# Return samples as a Hash with results indexed by name
sampler = lambda do
  {}.tap do |samples|
    SAMPLES_PATH.join('downloadable_strings').realpath.children.select(&:directory?).sort.each do |path|
      # @formatter:off
      samples[path.basename.to_s] = {
        input: path.join('input').realpath,
        output: path.join('output').realpath,
        builder: ->(klass = nil) { builder.call(path.join('input').realpath.to_s, described_class: klass) },
      }.yield_self { |v| Struct.new(*v.keys).new(*v.values) }
      # @formatter:on
    end
  end
end

# @formatter:off
{
  samples: sampler.call,
  builder: builder,
}
# @formatter:on
