# frozen_string_literal: true

[:Appifier, 'appifier'].tap do |args|
  # noinspection RubyResolve
  Dir.glob("#{__dir__}/../lib/*.rb").map { |req| require req }

  if Gem::Specification.find_all_by_name('sys-proc').any?
    require 'sys/proc'

    Sys::Proc.progname = 'rspec'
  end

  require_relative('helper/local').tap do
    Object.class_eval { include Local }
  end

  # @formmatter:off
  [
    :constants,
    :configure,
  ].each do |req|
    require_relative '%<dir>s/%<req>s' % {
      dir: __FILE__.gsub(/\.rb$/, ''),
      req: req.to_s,
    }
  end
  # @formmatter:on

  autoload(*args)
end
