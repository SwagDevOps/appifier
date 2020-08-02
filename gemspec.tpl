# frozen_string_literal: true
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all
<?rb
[
  '.yardopts',
  'lib/**/*.rb',
  'lib/**/resources/**/**',
  'lib/**/version.yml',
  'lib/**/recipes/*.yml',
  'lib/**/Dockerfile',
  'bin/appifier',
].tap do |patterns|
  self.singleton_class.define_method(:files) do
    patterns.map { |m| Dir.glob(m) }.flatten.keep_if { |f| File.file?(f) }.sort
  end
end

self.singleton_class.define_method(:quote) { |input| input.to_s.inspect }
?>

Gem::Specification.new do |s|
  s.name        = #{quote(@name)}
  s.version     = #{quote(@version)}
  s.date        = #{quote(@date)}
  s.summary     = #{quote(@summary)}
  s.description = #{quote(@description)}

  s.licenses    = #{@licenses}
  s.authors     = #{@authors}
  s.email       = #{quote(@email)}
  s.homepage    = #{quote(@homepage)}

  # MUST follow the higher required_ruby_version
  # requires version >= 2.3.0 due to safe navigation operator &
  # requires version >= 2.5.0 due to yield_self
  s.required_ruby_version = ">= 2.5.0"
  s.require_paths = ["lib"]
  s.files         = [
    <?rb for file in files.uniq ?>
    #{"%s," % quote(file)}
    <?rb end ?>
  ]

  #{@dependencies.keep(:runtime).to_s.lstrip}

  s.bindir = "bin"
  s.executables = [
    <?rb for file in files.keep_if { |fp| fp.match(%r{^bin/}) } ?>
    #{"%s," % File.basename(file).yield_self { |s| quote(s) } }
    <?rb end ?>
  ]
end

# Local Variables:
# mode: ruby
# End:
