# frozen_string_literal: true

typer = lambda do
  # @formatter:off
  {
    default: ::FileUtils,
    verbose: ::FileUtils::Verbose,
    dry_run: ::FileUtils::DryRun,
    no_write: ::FileUtils::NoWrite,
  }
  # @formatter:on
end

# @return [Hash{Symbol => Proc}]
#
# @see https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html#module-FileUtils-label-Module+Functions
methodifier = lambda do # rubocop:disable Metrics/BlockLength
  %(
FileUtils.cd(dir, **options)
FileUtils.cd(dir, **options) {|dir| block }
FileUtils.pwd()
FileUtils.mkdir(dir, **options)
FileUtils.mkdir(list, **options)
FileUtils.mkdir_p(dir, **options)
FileUtils.mkdir_p(list, **options)
FileUtils.rmdir(dir, **options)
FileUtils.rmdir(list, **options)
FileUtils.ln(target, link, **options)
FileUtils.ln(targets, dir, **options)
FileUtils.ln_s(target, link, **options)
FileUtils.ln_s(targets, dir, **options)
FileUtils.ln_sf(target, link, **options)
FileUtils.cp(src, dest, **options)
FileUtils.cp(list, dir, **options)
FileUtils.cp_r(src, dest, **options)
FileUtils.cp_r(list, dir, **options)
FileUtils.mv(src, dest, **options)
FileUtils.mv(list, dir, **options)
FileUtils.rm(list, **options)
FileUtils.rm_r(list, **options)
FileUtils.rm_rf(list, **options)
FileUtils.install(src, dest, **options)
FileUtils.chmod(mode, list, **options)
FileUtils.chmod_R(mode, list, **options)
FileUtils.chown(user, group, list, **options)
FileUtils.chown_R(user, group, list, **options)
FileUtils.touch(list, **options)
).strip.lines.sort.map do |line|
    line.strip.gsub(/^FileUtils\./, '').gsub(/\(.*$/, '').to_sym.yield_self do |name|
      [
        name,
        lambda do |instance, method|
          typer.call.values.uniq.reverse.each do |mod| # FileUtils must be last
            next unless instance.singleton_class.ancestors.include?(mod)

            return Class.new.new.tap do |o|
              o.singleton_class.__send__(:include, mod)
              o.singleton_class.__send__(:public, method)
            end.method(method)
          end

          raise "Can not get method #{method} on #{instance} (#{instance.singleton_class.ancestors})"
        end
      ]
    end
  end.to_h.freeze
end

# @formatter:off
{
  types: typer.call,
  module_methods: methodifier.call
}
# @formatter:on
