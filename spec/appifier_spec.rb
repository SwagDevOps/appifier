# frozen_string_literal: true

describe Appifier, :appifier do
  # @formatter:off
  [
    # components --------------------------------------------------
    :BaseCli,
    :Builder,
    :BuildsLister,
    :Cli,
    :Config,
    :Container,
    :DownloadableString,
    :Recipe,
    :Scripts,
    :Integration,
    :JsonPrinter,
    :LoggedRunner,
    :Mixins,
    :Shell,
    # system ------------------------------------------------------
    :Bundled,
    :VERSION,
  ].each do |k| # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
