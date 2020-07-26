# frozen_string_literal: true

require_relative '../appifier'
autoload(:ERB, 'erb')
autoload(:URI, 'uri')

# Describe a file or directory conforming to the file URI scheme.
#
# The file URI scheme is defined in RFC 8089, typically used to retrieve files from within one's own computer.
# @see https://en.wikipedia.org/wiki/File_URI_scheme
#
# Sample of use:
#
# ```ruby
# url = Appifier::FileUrl.new('/etc/fstab')
# { path: u.to_path, url: u.to_url, uri: u.to_uri }
# ```
#
# @todo Add to autoload
# @todo Use in Appifier::DownloadableString
class Appifier::FileUrl < Pathname
  def initialize(path)
    super(path)

    raise ArgumentError, 'must be an absolute path' unless self.absolute?
  end

  # @return [String]
  def to_url
    wield(:to_path).call.yield_self do |path|
      path.split('/').map { |s| s ? ERB::Util.url_encode(s) : s }.join('/').yield_self do |url|
        "file://#{url}"
      end
    end
  end

  # @return [URI::Generic]
  def to_uri
    URI.parse(to_url)
  end

  # @return [String]
  def to_path
    to_uri.tap do |uri|
      [:fragment, :query].each { |m| uri.public_send("#{m}=", nil) }
    end.to_s.gsub(%r{^file://}, '')
  end

  alias to_s to_url

  protected

  # Call method from parent.
  #
  # @api private
  # @param [Symbol] method
  #
  # @return [Method]
  # @raise [NameError]
  def wield(method, from: Pathname)
    from.instance_method(method).bind(self)
  end
end
