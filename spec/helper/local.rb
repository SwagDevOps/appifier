# frozen_string_literal: true

autoload(:FactoryStruct, "#{__dir__}/factory_struct")
autoload(:Sham, 'sham')

# Local (helper) methods
module Local
  protected

  # Retrieve ``sham`` by given ``name``
  #
  # @param [Symbol] name
  def sham!(name)
    FactoryStruct.sham!(name)
  rescue NoMethodError
    raise NameError, "no such sham - #{name}"
  end

  # Silences any stream for the duration of the block.
  #
  # @see https://apidock.com/rails/Kernel/silence_stream
  def silence_stream(stream) # rubocop:disable Metrics/MethodLength
    @silence_stream_mutex ||= Mutex.new

    @silence_stream_mutex.synchronize do
      old_stream = stream.dup
      # @formatter:off
      (RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
        .tap { |stream_null| stream.reopen(stream_null) }
      # @formatter:on
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
      old_stream.close
    end
  end

  # @param env [Hash]
  def with_env(env)
    @env_mutex ||= Mutex.new

    @env_mutex.synchronize do
      original_env = ENV.to_hash
      ENV.replace(env)

      yield if block_given?
    ensure
      ENV.replace(original_env)
    end
  end
end
