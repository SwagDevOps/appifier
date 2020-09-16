# frozen_string_literal: true

require_relative '../appifier'
autoload(:FileUtils, 'fileutils')

# Minimal wrapper build on top of ``FileUtils``.
#
#  Module Functions
#
# ```
# FileUtils.cd(dir, **options)
# FileUtils.cd(dir, **options) {|dir| block }
# FileUtils.pwd()
# FileUtils.mkdir(dir, **options)
# FileUtils.mkdir(list, **options)
# FileUtils.mkdir_p(dir, **options)
# FileUtils.mkdir_p(list, **options)
# FileUtils.rmdir(dir, **options)
# FileUtils.rmdir(list, **options)
# FileUtils.ln(target, link, **options)
# FileUtils.ln(targets, dir, **options)
# FileUtils.ln_s(target, link, **options)
# FileUtils.ln_s(targets, dir, **options)
# FileUtils.ln_sf(target, link, **options)
# FileUtils.cp(src, dest, **options)
# FileUtils.cp(list, dir, **options)
# FileUtils.cp_r(src, dest, **options)
# FileUtils.cp_r(list, dir, **options)
# FileUtils.mv(src, dest, **options)
# FileUtils.mv(list, dir, **options)
# FileUtils.rm(list, **options)
# FileUtils.rm_r(list, **options)
# FileUtils.rm_rf(list, **options)
# FileUtils.install(src, dest, **options)
# FileUtils.chmod(mode, list, **options)
# FileUtils.chmod_R(mode, list, **options)
# FileUtils.chown(user, group, list, **options)
# FileUtils.chown_R(user, group, list, **options)
# FileUtils.touch(list, **options)
# ```
#
# @see https://ruby-doc.org/stdlib-2.4.2/libdoc/fileutils/rdoc/FileUtils.html
# @see https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils/Verbose.html
# @see https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils/DryRun.html
# @see https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils/NoWrite.html
class Appifier::FileSystem
  # @!parse include FileUtils

  # @param [Symbol, nil] type
  def initialize(type = nil)
    self.class.__send__(:apply, type, self)
  end

  class << self
    protected

    # Create a ``FileUtils`` descendant from given instance.
    #
    # @api private
    #
    # @param [Symbol] type in ``[nil, :base, :verbose, :dry_run, no_write]``
    # @param [Object] instance
    #
    # @return [Module]
    def apply(type, instance)
      types.fetch(type).tap do |mod|
        (mod.public_methods - Module.public_methods - (instance.methods + instance.private_methods)).sort.tap do |methods| # rubocop:disable Layout/LineLength
          instance.singleton_class.__send__(:include, mod)

          methods.each do |m|
            instance.singleton_class.__send__(:public, m)
          rescue NameError # collect_method and commands
            next
          end
        end
      end
    end

    # @api private
    #
    # @return [Hash<Symbol => Module>]
    # @return [Hash<nil => Module>]
    def types
      # @formatter:off
      {
        nil => ::FileUtils,
        base: ::FileUtils,
        verbose: ::FileUtils::Verbose,
        dry_run: ::FileUtils::DryRun,
        no_write: ::FileUtils::NoWrite,
      }
      # @formatter:on
    end
  end
end
